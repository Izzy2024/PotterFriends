module.exports = {
  content: ["./pages/*.{html,js}", "./index.html", "./js/*.js"],
  theme: {
    extend: {
      colors: {
        // Primary Colors - Gryffindor courage, primary action confidence
        primary: {
          50: "#FEF2F2", // red-50
          100: "#FEE2E2", // red-100
          500: "#EF4444", // red-500
          600: "#DC2626", // red-600
          700: "#B91C1C", // red-700
          800: "#991B1B", // red-800
          900: "#740001", // custom red-900
          DEFAULT: "#740001", // red-900
        },
        
        // Secondary Colors - Magical gold, achievement celebration moments
        secondary: {
          50: "#FFFBEB", // yellow-50
          100: "#FEF3C7", // yellow-100
          200: "#FDE68A", // yellow-200
          300: "#FCD34D", // yellow-300
          400: "#FBBF24", // yellow-400
          500: "#F59E0B", // yellow-500
          600: "#C9A961", // custom yellow-600
          DEFAULT: "#C9A961", // yellow-600
        },
        
        // Accent Colors - Ravenclaw wisdom, thoughtful interaction states
        accent: {
          50: "#EFF6FF", // blue-50
          100: "#DBEAFE", // blue-100
          500: "#3B82F6", // blue-500
          700: "#1D4ED8", // blue-700
          800: "#1E40AF", // blue-800
          900: "#0E1A40", // custom blue-900
          DEFAULT: "#0E1A40", // blue-900
        },
        
        // Background Colors
        background: "#F4F1E8", // stone-100 - Warm parchment, comfortable reading canvas
        surface: "#FEFCF7", // stone-50 - Subtle content elevation, card backgrounds
        
        // Text Colors
        text: {
          primary: "#2C2C2C", // gray-800 - Extended reading comfort, scholarly authority
          secondary: "#5D5D5D", // gray-600 - Clear hierarchy, supporting information
        },
        
        // Status Colors
        success: {
          50: "#F0FDF4", // green-50
          100: "#DCFCE7", // green-100
          500: "#22C55E", // green-500
          600: "#16A34A", // green-600
          700: "#15803D", // green-700
          800: "#1A472A", // green-800 - Slytherin achievement, positive reinforcement
          DEFAULT: "#1A472A", // green-800
        },
        
        warning: {
          50: "#FFFBEB", // yellow-50
          100: "#FEF3C7", // yellow-100
          400: "#FFD800", // custom yellow-400 - Hufflepuff attention, gentle urgency
          DEFAULT: "#FFD800", // yellow-400
        },
        
        error: {
          50: "#FEF2F2", // red-50
          100: "#FEE2E2", // red-100
          500: "#EF4444", // red-500
          600: "#DC2626", // red-600
          800: "#8B0000", // custom red-800 - Concerned guidance, helpful correction
          DEFAULT: "#8B0000", // red-800
        },
        
        // House Colors
        gryffindor: "#740001", // red-900
        hufflepuff: "#FFD800", // yellow-400
        ravenclaw: "#0E1A40", // blue-900
        slytherin: "#1A472A", // green-800
      },
      
      fontFamily: {
        headline: ['EB Garamond', 'serif'], // Scholarly elegance that evokes ancient texts and magical authority
        body: ['Lato', 'sans-serif'], // Clean readability that disappears into comfortable long-form reading
        cta: ['Open Sans', 'sans-serif'], // Modern confidence that makes actions feel trustworthy and clear
        accent: ['Cinzel', 'serif'], // Magical gravitas for house names and special ceremonial moments
        sans: ['Lato', 'sans-serif'],
        serif: ['EB Garamond', 'serif'],
      },
      
      boxShadow: {
        'subtle': '0 2px 8px rgba(44, 44, 44, 0.1)', // Candlelight casting gentle shadows on parchment
        'card': '0 4px 12px rgba(44, 44, 44, 0.08)', // Elevated content cards
        'elevated': '0 8px 24px rgba(44, 44, 44, 0.12)', // Interactive elements
      },
      
      transitionDuration: {
        'gentle': '300ms', // Magical reveals rather than digital effects
      },
      
      transitionTimingFunction: {
        'gentle': 'ease-out', // Smooth magical transitions
      },
      
      scale: {
        'hover': '1.02', // Subtle hover enchantment
      },
      
      borderWidth: {
        'house': '2px', // House-themed accent borders
      },
      
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
      },
      
      borderRadius: {
        'magical': '8px', // Consistent magical border radius
      },
      
      lineHeight: {
        'scholarly': '1.6', // Comfortable reading line height
        'headline': '1.3', // Headline line height
      },
    },
  },
  plugins: [],
}