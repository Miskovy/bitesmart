---
name: Vitality Flow
colors:
  surface: '#f6fbee'
  surface-dim: '#d6dccf'
  surface-bright: '#f6fbee'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f6e9'
  surface-container: '#eaf0e3'
  surface-container-high: '#e4eadd'
  surface-container-highest: '#dfe4d8'
  on-surface: '#171d15'
  on-surface-variant: '#3f4a3b'
  inverse-surface: '#2c322a'
  inverse-on-surface: '#edf3e6'
  outline: '#6f7a6a'
  outline-variant: '#bfcab7'
  surface-tint: '#006e0a'
  primary: '#006c0a'
  on-primary: '#ffffff'
  primary-container: '#258622'
  on-primary-container: '#f8fff0'
  inverse-primary: '#7bdc6d'
  secondary: '#0058be'
  on-secondary: '#ffffff'
  secondary-container: '#2170e4'
  on-secondary-container: '#fefcff'
  tertiary: '#755800'
  on-tertiary: '#ffffff'
  tertiary-container: '#936f00'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#97f986'
  primary-fixed-dim: '#7bdc6d'
  on-primary-fixed: '#002201'
  on-primary-fixed-variant: '#005306'
  secondary-fixed: '#d8e2ff'
  secondary-fixed-dim: '#adc6ff'
  on-secondary-fixed: '#001a42'
  on-secondary-fixed-variant: '#004395'
  tertiary-fixed: '#ffdf9a'
  tertiary-fixed-dim: '#f7be1d'
  on-tertiary-fixed: '#251a00'
  on-tertiary-fixed-variant: '#5a4300'
  background: '#f6fbee'
  on-background: '#171d15'
  surface-variant: '#dfe4d8'
typography:
  display-hero:
    fontFamily: Epilogue
    fontSize: 36px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Epilogue
    fontSize: 20px
    fontWeight: '700'
    lineHeight: '1.4'
  headline-md:
    fontFamily: Epilogue
    fontSize: 18px
    fontWeight: '700'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Epilogue
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  body-md:
    fontFamily: Epilogue
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: Epilogue
    fontSize: 10px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: 0.1em
  stat-main:
    fontFamily: Epilogue
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-padding: 1.25rem
  section-gap: 1.5rem
  element-gap-sm: 0.5rem
  element-gap-md: 1rem
  glass-blur: 12px
---

## Brand & Style

Vitality Flow is a health and wellness design system that balances editorial sophistication with approachable coaching. The brand personality is optimistic, disciplined, and modern, targeting individuals who value both data-driven insights and gentle encouragement. 

The visual style is a hybrid of **Modern Corporate** and **Glassmorphism**. It utilizes clean, systematic layouts with high-quality whitespace, layered with frosted-glass headers and soft, organic background blurs. This creates a sense of "digital lightness," making the act of health tracking feel less like a chore and more like a premium lifestyle experience.

## Colors

The palette is rooted in a "Fresh Growth" green primary (#3a9933), symbolizing health and vitality. This is supported by a functional triadic set used specifically for macro-nutrient and biological tracking: Protein (Blue), Carbs (Yellow), and Fats (Red).

The background uses a tinted off-white (#f6f8f6) to reduce eye strain compared to pure white, while surfaces utilize pure white for maximum elevation contrast. A dark mode is supported using deep forest-charcoal tones (#151e14) to maintain the botanical connection even in low-light environments.

## Typography

The system exclusively uses **Epilogue**, a geometric sans-serif with a distinct editorial feel. 

- **Headlines:** Use tight letter-spacing and heavy weights (700) to create a commanding presence.
- **Labels:** Secondary information and category headers use an "all-caps" style with wide tracking (0.1em) to differentiate from interactive body text.
- **Stats:** Numerical data is rendered with high weight to ensure immediate readability at a glance.

## Layout & Spacing

The system follows a **Dynamic Margin** approach tailored for mobile-first views. 
- **The Grid:** A single-column vertical stack with a maximum width of 448px (max-w-md).
- **Margins:** A standard 20px (1.25rem) horizontal padding for the main container.
- **Vertical Rhythm:** Sections are separated by 24px (1.5rem) to ensure the UI feels airy and un-cluttered.
- **Safe Areas:** The sticky header and bottom navigation utilize backdrop blurs to allow content to scroll underneath while maintaining legibility via `glass-effect` (blur-md).

## Elevation & Depth

Depth is communicated through three specific layers:
1.  **The Canvas:** The base background level (#f6f8f6).
2.  **Raised Surfaces:** Main content cards use a "soft shadow" (0 4px 20px -2px rgba(0, 0, 0, 0.05)) and no borders, creating a clean, floating appearance.
3.  **Floating Elements:** Elements like the Scanner FAB and active buttons use more aggressive shadows (shadow-lg) with color-tinted glows (primary/30) to signal high interactivity.
4.  **Interactive States:** "Ghost" borders (1px transparent) transition to primary-colored borders on hover or focus to provide tactile feedback without shifting layout.

## Shapes

The shape language is organic and highly rounded to evoke a "friendly health" feel.
- **Primary Cards:** Use a generous 1.5rem (24px) corner radius (rounded-3xl).
- **Secondary Items:** Use a 1rem (16px) radius (rounded-2xl) for meal items and tip cards.
- **Small Elements:** Icons and small buttons use a 0.75rem (12px) radius (rounded-xl).
- **Functional Circles:** Progress rings, profile avatars, and FABs are strictly `rounded-full`.

## Components

### Buttons
- **Primary FAB:** Large, circular, high-contrast (Black background in light mode, Primary in dark mode) with a 3XL icon.
- **Action Buttons:** Small circular buttons (8px - 10px) with subtle background tints and icon-only labels for secondary actions like "Edit" or "Add".

### Cards
- **Stat Cards:** Feature a background decorative "blob" (opacity 10%) to break geometric monotony.
- **Meal Cards:** A horizontal layout with a fixed-size image (64px) with a 12px border radius.
- **Empty States:** Use dashed borders (border-dashed) with centered iconography to encourage user input.

### Progress Indicators
- **Donut Charts:** Use a 12px stroke for the main calorie ring and a 4px stroke for micro-stats. Terminals must be rounded (`stroke-linecap: round`).

### Navigation
- **Bottom Bar:** A persistent fixed element with a "dock" for the central FAB. Icons use a 24px sizing, transitioning from Gray-400 (inactive) to Primary (active).