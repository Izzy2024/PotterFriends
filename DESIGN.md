# Design System: Sorting Hat Selection Ceremony

**Project ID:** potter-friends-selection-portal

## 1. Visual Theme & Atmosphere

The Sorting Hat Selection Ceremony embodies an **ancient, mystical, and profoundly decisive** aesthetic. It strips away the playful, bright UI of typical quizzes and instead plunges the user into a deeply atmospheric ritual. The philosophy is "subtractive maximalism"—dense in texture, high in contrast, and rich in cinematic lighting, yet highly constrained in UI elements.

The overall mood is **weighty and dramatic**, making every interaction feel consequential. The interface feels less like a web page and more like peering into a meditative, shadow-drenched chamber where only the essential truth remains illuminated.

**Key Characteristics:**

- Extreme chiaroscuro (deep, crushing shadows contrasting with sharp, magical specular highlights).
- Ethereal floating elements that seem suspended by unseen forces.
- Interaction design based on "physical magic" (elements that glow, levitate, or hum upon attention).
- A profound sense of negative space that amplifies the importance of the text.
- Typography that demands respect, moving away from casual sans-serifs toward elegant, sharp serifs.

## 2. Color Palette & Roles

### Primary Foundation

- **Vantablack Void** (#050303) – Primary background. Acts as absolute darkness, creating infinite depth.
- **Ancient Obsidian** (#0F0A0A) – Secondary surface color for floating base layers. Barely distinct from true black, offering a whisper of materiality (wood or stone).

### Accent & Interactive

- **Incantation Gold** (#DFB15B) – The primary luminous accent. Used exclusively for active selections, progress indicators, and magical highlights. It cuts through the darkness like firelight.
- **Ember Red** (#8F1115) – A deep, blood-red accent used sparingly for primary actions (like beginning the ceremony) to invoke urgency and importance.

### Typography & Text Hierarchy

- **Parchment White** (#ECE1CD) – Primary text color. Not pure white; has a subtle aged warmth to prevent eye strain against the void.
- **Faded Ink** (#8A8172) – Secondary text. Used for instructions, unselected options, and atmospheric metadata. It retreats visually until focused upon.
- **Spectral Cyan** (#9FD4FF) – Tertiary, very rare accent used only for specific magical feedback or hover states (e.g., hovering over an unselected option).

## 3. Typography Rules

**Primary Font Family:** Cinzel (Headings) / EB Garamond (Body)
**Character:** Dramatic, classical, and slightly imposing.

### Hierarchy & Weights

- **Ceremonial Title (H1):** Cinzel, Regular weight (400), expansive letter-spacing (0.05em), 3.5-5rem size. Glows gently. The most important visual anchor.
- **Question Statements (H2):** Cinzel, Regular weight (400), moderate letter-spacing (0.03em), 2-3rem size. Serves as the authoritative voice of the Hat.
- **Option Text (Body):** EB Garamond, Medium weight (500), comfortable line-height (1.6), 1.25rem size. Designed for focused, deliberate reading.
- **Ritual Metadata (Progress):** Cinzel, Light weight (300), tight tracking, 0.875rem.

### Spacing Principles

- Massive vertical margins (10-15vh) isolating the question centrally on the screen.
- Options stacked with generous padding (1.5rem) to ensure each click feels intentional.

## 4. Component Stylings

### Interactive Plates (Form Options)

- **Shape:** Sharp, squared-off edges (0px to 2px radius maximum). No soft, modern pills.
- **Resting State:** A nearly transparent border (`1px solid rgba(138, 129, 114, 0.1)`) over the `Vantablack Void`. The text is `Faded Ink`.
- **Hover/Gaze State (Magnetic):** The plate physically lifts (translateY -3px). A sharp, linear gradient streak of `Spectral Cyan` flashes across the border. Text brightens to `Parchment White`.
- **Selected/Committed State:** The plate ignites. The border thickens and glows with `Incantation Gold` (`box-shadow: 0 0 20px rgba(223, 177, 91, 0.4)`). A subtle, slow-pulsing background of gold (10% opacity) fills the plate.

### The Progress Spire

- **Style:** Not a typical progress bar, but a vertical or razor-thin horizontal line of pure light.
- **Execution:** A 1px tall track of `rgba(236, 225, 205, 0.1)` (Faded Ink), filled smoothly by a laser-sharp core of `Incantation Gold` as the user answers. It features a bright "head" (like a comet) leading the progress.

### The Looming Artefact (Images/Centerpieces)

- **Image Treatment:** No square or raw rectangular images. The sorting hat imagery should fade to black at its edges (`mask-image: radial-gradient(circle, black 40%, transparent 70%)`).
- **Animation:** Continuous, imperceptibly slow levitation (a 12-second vertical sine wave).

## 5. Layout Principles

### Grid & Structure

- **Focus:** Absolute center weighting. Distractions are forbidden.
- **Width:** Constrained max-width (768px for the quiz content) forcing the text to act as a monolithic block in the center of the vast void.

### Whitespace Strategy (The "Silence")

- The void (`margin` and `padding`) is treated as physical silence.
- There are no sidebars, no visible structural containers. Elements simply exist in the darkness.

## 6. Design System Notes for Remotion/Implementation

### Language to Use in Prompts/Code

- **Atmosphere:** "Deep cinematic void with magical chiaroscuro."
- **Buttons (Options):** "Levitating ceremonial plates with sharp edges and luminescent hover states."
- **Shadows/Light:** "Incantation Gold glow" and "Infinite recursive shadow."

### Execution Directives

- **Transitions MUST be slow:** Minimum 400ms for state changes. This is a ritual, not a race. Snap transitions ruin the magic.
- **Particle Layering:** Introduce an isolated foreground layer of slow, out-of-focus cinematic dust (opacity < 5%) to establish scale and depth.
- **Audio-Visual Sync:** Design hover states to feel as physical as a sound effect (e.g., using a subtle `scale(1.02)` and a sharp initial flash that decays).
