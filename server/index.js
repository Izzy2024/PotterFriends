const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');
const { randomUUID } = require('crypto');
require('dotenv').config();

const app = express();

const PORT = process.env.PORT || 3001;
const DATABASE_URL = process.env.DATABASE_URL || 'postgres://admin@localhost:5432/postgres';
const JWT_SECRET = process.env.JWT_SECRET || 'dev-only-secret-change-me';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

const pool = new Pool({ connectionString: DATABASE_URL });

app.use(cors({ origin: true, credentials: true }));
app.use(express.json({ limit: '1mb' }));

app.post('/client-log', (req, res) => {
  try {
    const payload = req.body || {};
    console.log('[client-log]', JSON.stringify(payload));
  } catch (err) {
    console.log('[client-log] invalid payload');
  }
  return res.json({ ok: true });
});

function signToken(user) {
  return jwt.sign(
    {
      sub: user.id,
      email: user.email,
      role: user.role || 'authenticated'
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
}

function authMiddleware(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'Missing auth token' });
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.user = payload;
    return next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

function optionalAuthMiddleware(req, _res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return next();
  try {
    req.user = jwt.verify(token, JWT_SECRET);
  } catch (_err) {
    // Ignore invalid tokens for optional-auth routes
  }
  return next();
}

async function getUserByEmail(client, email) {
  const { rows } = await client.query(
    `SELECT id, email, encrypted_password, raw_user_meta_data, role
     FROM auth.users
     WHERE lower(email) = lower($1) AND is_sso_user = false
     LIMIT 1`,
    [email]
  );
  return rows[0] || null;
}

async function getUserById(client, id) {
  const { rows } = await client.query(
    `SELECT id, email, raw_user_meta_data, role
     FROM auth.users
     WHERE id = $1
     LIMIT 1`,
    [id]
  );
  return rows[0] || null;
}

async function upsertUserStat(client, userId, statName, increment = 1) {
  const safeIncrement = Number.isFinite(Number(increment)) ? Number(increment) : 1;
  const { rows } = await client.query(
    `INSERT INTO public.user_statistics (user_id, stat_name, stat_value, updated_at)
     VALUES ($1, $2, $3, NOW())
     ON CONFLICT (user_id, stat_name)
     DO UPDATE SET
       stat_value = public.user_statistics.stat_value + EXCLUDED.stat_value,
       updated_at = NOW()
     RETURNING stat_value`,
    [userId, statName, safeIncrement]
  );

  return rows[0]?.stat_value ?? 0;
}

async function checkAndAwardAchievements(client, userId) {
  const [achievementsResult, statsResult, profileResult, existingResult] = await Promise.all([
    client.query(
      `SELECT id, name, trigger_condition, points_reward
       FROM public.achievement_types
       WHERE COALESCE(auto_award, true) = true
       AND COALESCE(is_active, true) = true`
    ),
    client.query(
      `SELECT stat_name, stat_value
       FROM public.user_statistics
       WHERE user_id = $1`,
      [userId]
    ),
    client.query(
      `SELECT house, COALESCE(house_points, 0) AS house_points, COALESCE(display_name, '') AS display_name
       FROM public.user_profiles
       WHERE id = $1
       LIMIT 1`,
      [userId]
    ),
    client.query(
      `SELECT achievement_type_id
       FROM public.user_achievements
       WHERE user_id = $1`,
      [userId]
    )
  ]);

  const stats = new Map(statsResult.rows.map((r) => [r.stat_name, Number(r.stat_value) || 0]));
  const profile = profileResult.rows[0] || { house: null, house_points: 0, display_name: '' };
  const existing = new Set(existingResult.rows.map((r) => Number(r.achievement_type_id)));

  let awardedCount = 0;
  let pointsAdded = 0;
  const awardedNames = [];

  const shouldAward = (achievement) => {
    const trigger = achievement.trigger_condition;
    if (!trigger) return false;

    const triggerStat = stats.get(`trigger_${trigger}`) || 0;
    if (triggerStat > 0) return true;

    switch (trigger) {
      case 'user_registration':
        return true;
      case 'posts_count_50':
        return (stats.get('forum_posts') || 0) >= 50 || (stats.get('posts_count') || 0) >= 50;
      case 'daily_visits_7':
        return (stats.get('consecutive_days') || 0) >= 7;
      case 'active_days_30':
        return (stats.get('active_days') || 0) >= 30 || (stats.get('consecutive_days') || 0) >= 30;
      case 'house_points_100':
        return Number(profile.house_points || 0) >= 100;
      case 'house_selection':
        return !!profile.house;
      case 'profile_completion':
        return String(profile.display_name || '').trim().length > 0;
      default:
        return false;
    }
  };

  for (const achievement of achievementsResult.rows) {
    if (existing.has(Number(achievement.id))) continue;
    if (!shouldAward(achievement)) continue;

    const insertResult = await client.query(
      `INSERT INTO public.user_achievements (user_id, achievement_type_id, awarded_by, reason, awarded_at)
       VALUES ($1, $2, $1, $3, NOW())
       ON CONFLICT (user_id, achievement_type_id) DO NOTHING
       RETURNING id`,
      [userId, achievement.id, `Logro automático (${achievement.trigger_condition || 'sin_trigger'})`]
    );

    if (insertResult.rowCount > 0) {
      awardedCount += 1;
      pointsAdded += Number(achievement.points_reward) || 0;
      awardedNames.push(achievement.name);
      existing.add(Number(achievement.id));
    }
  }

  if (pointsAdded > 0) {
    await client.query(
      `UPDATE public.user_profiles
       SET house_points = COALESCE(house_points, 0) + $2
       WHERE id = $1`,
      [userId, pointsAdded]
    );
  }

  return {
    success: true,
    achievements_awarded: awardedCount,
    points_added: pointsAdded,
    achievements: awardedNames,
    message: awardedCount > 0 ? `¡${awardedCount} logro(s) desbloqueado(s)!` : 'No hay nuevos logros disponibles'
  };
}

app.get('/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    return res.json({ ok: true });
  } catch (err) {
    return res.status(500).json({ ok: false, error: 'db_unreachable' });
  }
});

app.post('/auth/signup', async (req, res) => {
  const { email, password, wizard_name, first_name, last_name, house } = req.body || {};
  if (!email || !password) {
    return res.status(400).json({ error: 'email_and_password_required' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const existing = await getUserByEmail(client, email);
    if (existing) {
      await client.query('ROLLBACK');
      return res.status(409).json({ error: 'email_already_registered' });
    }

    const id = randomUUID();
    const passwordHash = await bcrypt.hash(password, 10);
    const now = new Date();
    const meta = {
      wizard_name: wizard_name || 'Mago',
      first_name: first_name || '',
      last_name: last_name || '',
      house: house || null
    };

    await client.query(
      `INSERT INTO auth.users (
        id, email, encrypted_password, raw_user_meta_data, raw_app_meta_data,
        aud, role, email_confirmed_at, created_at, updated_at
      ) VALUES (
        $1, $2, $3, $4::jsonb, $5::jsonb,
        'authenticated', 'authenticated', $6, $6, $6
      )`,
      [
        id,
        email,
        passwordHash,
        JSON.stringify(meta),
        JSON.stringify({ provider: 'email', providers: ['email'] }),
        now
      ]
    );

    await client.query(
      `INSERT INTO public.user_profiles (id, display_name, house)
       VALUES ($1, $2, $3)
       ON CONFLICT (id) DO NOTHING`,
      [id, wizard_name || email.split('@')[0], house || null]
    );

    // Best effort: registrar evento de alta y otorgar logros automáticos iniciales
    try {
      await upsertUserStat(client, id, 'trigger_user_registration', 1);
      await checkAndAwardAchievements(client, id);
    } catch (achievementError) {
      console.warn('[achievements] signup bootstrap failed:', achievementError.message);
    }

    await client.query('COMMIT');

    const user = await getUserById(client, id);
    const token = signToken(user);

    return res.json({
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        user_metadata: user.raw_user_meta_data || {}
      },
      session: { access_token: token, token_type: 'bearer' }
    });
  } catch (err) {
    await client.query('ROLLBACK');
    return res.status(500).json({ error: 'signup_failed', detail: err.message });
  } finally {
    client.release();
  }
});

app.post('/auth/login', async (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password) {
    return res.status(400).json({ error: 'email_and_password_required' });
  }

  const client = await pool.connect();
  try {
    const user = await getUserByEmail(client, email);
    if (!user || !user.encrypted_password) {
      return res.status(401).json({ error: 'invalid_credentials' });
    }

    if (!user.encrypted_password.startsWith('$2')) {
      return res.status(401).json({
        error: 'password_hash_incompatible',
        message: 'La cuenta existe pero la contraseña no es compatible. Usa reset para crear una nueva.'
      });
    }

    const ok = await bcrypt.compare(password, user.encrypted_password);
    if (!ok) {
      return res.status(401).json({ error: 'invalid_credentials' });
    }

    const token = signToken(user);
    return res.json({
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        user_metadata: user.raw_user_meta_data || {}
      },
      session: { access_token: token, token_type: 'bearer' }
    });
  } catch (err) {
    return res.status(500).json({ error: 'login_failed', detail: err.message });
  } finally {
    client.release();
  }
});

app.post('/auth/logout', (_req, res) => {
  return res.json({ ok: true });
});

app.get('/auth/user', authMiddleware, async (req, res) => {
  const client = await pool.connect();
  try {
    const user = await getUserById(client, req.user.sub);
    if (!user) return res.status(404).json({ error: 'user_not_found' });

    const { rows } = await client.query(
      `SELECT * FROM public.user_profiles WHERE id = $1 LIMIT 1`,
      [req.user.sub]
    );

    return res.json({
      user: {
        ...user,
        user_metadata: user.raw_user_meta_data || {},
        profile: rows[0] || null
      }
    });
  } catch (err) {
    return res.status(500).json({ error: 'user_fetch_failed', detail: err.message });
  } finally {
    client.release();
  }
});

app.post('/auth/request-reset', async (req, res) => {
  const { email } = req.body || {};
  if (!email) return res.status(400).json({ error: 'email_required' });

  const token = randomUUID();
  const client = await pool.connect();
  try {
    const result = await client.query(
      `UPDATE auth.users
       SET recovery_token = $1, recovery_sent_at = NOW()
       WHERE lower(email) = lower($2) AND is_sso_user = false
       RETURNING id, email`,
      [token, email]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'user_not_found' });
    }

    return res.json({ ok: true, reset_token: token });
  } catch (err) {
    return res.status(500).json({ error: 'reset_request_failed', detail: err.message });
  } finally {
    client.release();
  }
});

app.post('/auth/reset', async (req, res) => {
  const { token, new_password } = req.body || {};
  if (!token || !new_password) {
    return res.status(400).json({ error: 'token_and_password_required' });
  }

  const passwordHash = await bcrypt.hash(new_password, 10);
  const client = await pool.connect();
  try {
    const result = await client.query(
      `UPDATE auth.users
       SET encrypted_password = $1, updated_at = NOW(), recovery_token = NULL, recovery_sent_at = NULL
       WHERE recovery_token = $2
       RETURNING id, email`,
      [passwordHash, token]
    );

    if (result.rowCount === 0) {
      return res.status(400).json({ error: 'invalid_or_expired_token' });
    }

    return res.json({ ok: true });
  } catch (err) {
    return res.status(500).json({ error: 'reset_failed', detail: err.message });
  } finally {
    client.release();
  }
});

app.post('/auth/update', authMiddleware, async (req, res) => {
  const { password } = req.body || {};
  if (!password) return res.status(400).json({ error: 'password_required' });

  const passwordHash = await bcrypt.hash(password, 10);
  const client = await pool.connect();
  try {
    await client.query(
      `UPDATE auth.users
       SET encrypted_password = $1, updated_at = NOW()
       WHERE id = $2`,
      [passwordHash, req.user.sub]
    );

    return res.json({ ok: true });
  } catch (err) {
    return res.status(500).json({ error: 'update_failed', detail: err.message });
  } finally {
    client.release();
  }
});

function validateIdent(name) {
  return /^[a-zA-Z_][a-zA-Z0-9_]*$/.test(name);
}

function validateQualifiedIdent(name) {
  return name
    .split('.')
    .every((part) => validateIdent(part));
}

function quoteIdent(name) {
  return `"${name.replace(/"/g, '""')}"`;
}

function quoteQualifiedIdent(name) {
  return name
    .split('.')
    .map((part) => quoteIdent(part))
    .join('.');
}

function parseTable(input) {
  const parts = input.split('.');
  if (parts.length === 1) {
    return { schema: 'public', table: parts[0] };
  }
  if (parts.length === 2) {
    return { schema: parts[0], table: parts[1] };
  }
  throw new Error('invalid_table');
}

function normalizeColumns(columns) {
  if (!columns || columns.trim() === '*' || columns.trim() === '') return '*';
  if (/[!()]/.test(columns)) return '*';
  const list = columns.split(',').map((c) => c.trim()).filter(Boolean);
  const safe = list.map((c) => {
    if (!validateQualifiedIdent(c)) throw new Error(`invalid_column:${c}`);
    return quoteQualifiedIdent(c);
  });
  return safe.join(', ');
}

function parseOrFilter(orString, params) {
  if (!orString) return '';
  const parts = String(orString).split(',').map((p) => p.trim()).filter(Boolean);
  const clauses = [];

  for (const part of parts) {
    const pieces = part.split('.');
    if (pieces.length < 3) {
      throw new Error('invalid_or_syntax');
    }
    const column = pieces[0];
    const op = pieces[1];
    const value = pieces.slice(2).join('.');

    if (!validateQualifiedIdent(column)) throw new Error(`invalid_column:${column}`);
    const col = quoteQualifiedIdent(column);

    if (op === 'ilike') {
      params.push(value);
      clauses.push(`${col} ILIKE $${params.length}`);
    } else if (op === 'like') {
      params.push(value);
      clauses.push(`${col} LIKE $${params.length}`);
    } else if (op === 'eq') {
      params.push(value);
      clauses.push(`${col} = $${params.length}`);
    } else {
      throw new Error(`unsupported_or_op:${op}`);
    }
  }

  if (clauses.length === 0) return '';
  return `(${clauses.join(' OR ')})`;
}

function buildWhere(filters, params, orString) {
  // Handle filters being undefined, null, empty array, or empty object
  if (!filters || (Array.isArray(filters) && filters.length === 0) || (typeof filters === 'object' && Object.keys(filters).length === 0)) {
    // Still process OR filter if present
    const orClause = parseOrFilter(orString, params);
    if (orClause) {
      return { clause: `WHERE ${orClause}`, params };
    }
    return { clause: '', params };
  }
  const clauses = [];

  for (const f of filters) {
    const { column, op, value } = f;
    if (!validateQualifiedIdent(column)) throw new Error(`invalid_column:${column}`);
    const col = quoteQualifiedIdent(column);

    switch (op) {
      case 'eq':
        params.push(value);
        clauses.push(`${col} = $${params.length}`);
        break;
      case 'neq':
        params.push(value);
        clauses.push(`${col} <> $${params.length}`);
        break;
      case 'gt':
        params.push(value);
        clauses.push(`${col} > $${params.length}`);
        break;
      case 'gte':
        params.push(value);
        clauses.push(`${col} >= $${params.length}`);
        break;
      case 'lt':
        params.push(value);
        clauses.push(`${col} < $${params.length}`);
        break;
      case 'lte':
        params.push(value);
        clauses.push(`${col} <= $${params.length}`);
        break;
      case 'like':
        params.push(value);
        clauses.push(`${col} LIKE $${params.length}`);
        break;
      case 'ilike':
        params.push(value);
        clauses.push(`${col} ILIKE $${params.length}`);
        break;
      case 'in':
        if (!Array.isArray(value)) throw new Error('in_requires_array');
        params.push(value);
        clauses.push(`${col} = ANY($${params.length})`);
        break;
      case 'is':
        clauses.push(value === null ? `${col} IS NULL` : `${col} IS NOT NULL`);
        break;
      default:
        throw new Error(`unsupported_op:${op}`);
    }
  }

  const orClause = parseOrFilter(orString, params);
  if (orClause) {
    clauses.push(orClause);
  }

  return { clause: `WHERE ${clauses.join(' AND ')}`, params };
}

app.post('/api/db/select', async (req, res) => {
  const { table, columns, filters, order, limit, offset, count, head, or } = req.body || {};
  if (!table) return res.status(400).json({ error: 'table_required' });

  try {
    const { schema, table: tbl } = parseTable(table);
    if (!validateIdent(schema) || !validateIdent(tbl)) throw new Error('invalid_table');

    const cols = normalizeColumns(columns);
    const params = [];
    const where = buildWhere(filters, params, or);

    let orderClause = '';
    if (order) {
      const items = Array.isArray(order)
        ? order
        : (order.column ? [{ column: order.column, ascending: order.ascending }] : []);
      const parts = [];
      for (const item of items) {
        if (!item || !item.column) continue;
        const cols = String(item.column)
          .split(',')
          .map((c) => c.trim())
          .filter(Boolean);
        for (const col of cols) {
          if (!validateQualifiedIdent(col)) throw new Error(`invalid_column:${col}`);
          parts.push(`${quoteQualifiedIdent(col)} ${item.ascending === false ? 'DESC' : 'ASC'}`);
        }
      }
      if (parts.length > 0) {
        orderClause = `ORDER BY ${parts.join(', ')}`;
      }
    }

    const limitClause = Number.isInteger(limit) ? `LIMIT ${limit}` : '';
    const offsetClause = Number.isInteger(offset) ? `OFFSET ${offset}` : '';

    const client = await pool.connect();
    try {
      let total = null;
      if (count === 'exact') {
        const countResult = await client.query(
          `SELECT COUNT(*)::int AS count FROM ${quoteIdent(schema)}.${quoteIdent(tbl)} ${where.clause}`,
          where.params
        );
        total = countResult.rows[0]?.count ?? 0;
      }

      let data = [];
      if (!head) {
        const query = `SELECT ${cols} FROM ${quoteIdent(schema)}.${quoteIdent(tbl)} ${where.clause} ${orderClause} ${limitClause} ${offsetClause}`;
        const result = await client.query(query, where.params);
        data = result.rows;
      }

      return res.json({ data, count: total });
    } finally {
      client.release();
    }
  } catch (err) {
    return res.status(400).json({ error: 'select_failed', detail: err.message });
  }
});

app.post('/api/db/insert', authMiddleware, async (req, res) => {
  const { table, values, returning } = req.body || {};
  if (!table || !values) return res.status(400).json({ error: 'table_and_values_required' });

  try {
    const { schema, table: tbl } = parseTable(table);
    if (!validateIdent(schema) || !validateIdent(tbl)) throw new Error('invalid_table');

    const rows = Array.isArray(values) ? values : [values];
    if (rows.length === 0) return res.json({ data: [] });

    const columns = Object.keys(rows[0]);
    columns.forEach((c) => {
      if (!validateIdent(c)) throw new Error(`invalid_column:${c}`);
    });

    const colList = columns.map(quoteIdent).join(', ');
    const params = [];
    const valuesClause = rows
      .map((row) => {
        const placeholders = columns.map((c) => {
          params.push(row[c]);
          return `$${params.length}`;
        });
        return `(${placeholders.join(', ')})`;
      })
      .join(', ');

    const ret = returning ? normalizeColumns(returning) : '*';

    const query = `INSERT INTO ${quoteIdent(schema)}.${quoteIdent(tbl)} (${colList}) VALUES ${valuesClause} RETURNING ${ret}`;

    const client = await pool.connect();
    try {
      const result = await client.query(query, params);
      return res.json({ data: result.rows });
    } finally {
      client.release();
    }
  } catch (err) {
    return res.status(400).json({ error: 'insert_failed', detail: err.message });
  }
});

app.post('/api/db/update', authMiddleware, async (req, res) => {
  const { table, values, filters, returning } = req.body || {};
  if (!table || !values) return res.status(400).json({ error: 'table_and_values_required' });

  try {
    const { schema, table: tbl } = parseTable(table);
    if (!validateIdent(schema) || !validateIdent(tbl)) throw new Error('invalid_table');

    const columns = Object.keys(values);
    columns.forEach((c) => {
      if (!validateIdent(c)) throw new Error(`invalid_column:${c}`);
    });

    const params = [];
    const setClause = columns
      .map((c) => {
        params.push(values[c]);
        return `${quoteIdent(c)} = $${params.length}`;
      })
      .join(', ');

    const where = buildWhere(filters, params);
    const ret = returning ? normalizeColumns(returning) : '*';

    const query = `UPDATE ${quoteIdent(schema)}.${quoteIdent(tbl)} SET ${setClause} ${where.clause} RETURNING ${ret}`;

    const client = await pool.connect();
    try {
      const result = await client.query(query, where.params);
      return res.json({ data: result.rows });
    } finally {
      client.release();
    }
  } catch (err) {
    return res.status(400).json({ error: 'update_failed', detail: err.message });
  }
});

app.post('/api/db/delete', authMiddleware, async (req, res) => {
  const { table, filters, returning } = req.body || {};
  if (!table) return res.status(400).json({ error: 'table_required' });

  try {
    const { schema, table: tbl } = parseTable(table);
    if (!validateIdent(schema) || !validateIdent(tbl)) throw new Error('invalid_table');

    const params = [];
    const where = buildWhere(filters, params);
    const ret = returning ? normalizeColumns(returning) : '*';

    const query = `DELETE FROM ${quoteIdent(schema)}.${quoteIdent(tbl)} ${where.clause} RETURNING ${ret}`;

    const client = await pool.connect();
    try {
      const result = await client.query(query, where.params);
      return res.json({ data: result.rows });
    } finally {
      client.release();
    }
  } catch (err) {
    return res.status(400).json({ error: 'delete_failed', detail: err.message });
  }
});

app.post('/api/db/rpc', optionalAuthMiddleware, async (req, res) => {
  const { fn, args } = req.body || {};
  if (!fn) return res.status(400).json({ error: 'fn_required' });

  try {
    const parts = fn.split('.');
    const schema = parts.length === 2 ? parts[0] : 'public';
    const name = parts.length === 2 ? parts[1] : parts[0];
    if (!validateIdent(schema) || !validateIdent(name)) throw new Error('invalid_function');

    const entries = args ? Object.entries(args) : [];
    const values = entries.map(([, value]) => value);
    const placeholders = entries
      .map(([argName], i) => {
        if (!validateIdent(argName)) throw new Error(`invalid_arg:${argName}`);
        return `${quoteIdent(argName)} => $${i + 1}`;
      })
      .join(', ');

    const client = await pool.connect();
    try {
      // Debug: log auth info
      console.log(`[RPC] fn=${fn}, user.sub=${req.user?.sub || 'none'}, hasAuth=${!!req.headers.authorization}`);

      // Local fallback handlers for critical achievement RPCs.
      if (schema === 'public' && name === 'update_user_stat') {
        const userId = args?.p_user_id || req.user?.sub;
        const statName = args?.p_stat_name;
        const increment = args?.p_increment ?? 1;
        if (!userId || !statName) {
          return res.status(400).json({ error: 'rpc_failed', detail: 'p_user_id and p_stat_name are required' });
        }
        const newValue = await upsertUserStat(client, userId, statName, increment);
        return res.json({
          data: [{
            update_user_stat: {
              success: true,
              stat_name: statName,
              new_value: newValue
            }
          }]
        });
      }

      if (schema === 'public' && name === 'check_and_award_achievements') {
        const userId = args?.p_user_id || req.user?.sub;
        if (!userId) {
          return res.status(400).json({ error: 'rpc_failed', detail: 'p_user_id is required' });
        }
        const result = await checkAndAwardAchievements(client, userId);
        return res.json({ data: [{ check_and_award_achievements: result }] });
      }
      
      if (req.user?.sub) {
        // Emulate Supabase JWT context so auth.uid() works in SQL functions.
        await client.query(
          `SELECT
            set_config('request.jwt.claim.sub', $1, false),
            set_config('request.jwt.claim.role', $2, false)`,
          [req.user.sub, req.user.role || 'authenticated']
        );
      }

      let result;
      try {
        result = await client.query(
          `SELECT * FROM ${quoteIdent(schema)}.${quoteIdent(name)}(${placeholders})`,
          values
        );
      } catch (err) {
        result = await client.query(
          `SELECT ${quoteIdent(schema)}.${quoteIdent(name)}(${placeholders})`,
          values
        );
      }

      return res.json({ data: result.rows });
    } finally {
      client.release();
    }
  } catch (err) {
    return res.status(400).json({ error: 'rpc_failed', detail: err.message });
  }
});

app.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`Local API running on http://localhost:${PORT}`);
});
