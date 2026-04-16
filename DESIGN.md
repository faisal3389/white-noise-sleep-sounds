# Design System Specification: Premium Relaxation & Audio Immersion

## 1. Overview & Creative North Star
The current landscape of relaxation apps is often cluttered with utilitarian lists and high-contrast dividers that disrupt the user's mental state. This design system departs from the "utility-first" approach to embrace **"The Ethereal Sanctuary."**

Our North Star is to create a digital environment that feels as quiet as the sounds it plays. We achieve this through a signature editorial layout: intentional asymmetry, large-scale immersive imagery that bleeds to the edges, and a "depth-first" hierarchy. By strictly adhering to Apple's Human Interface Guidelines (HIG) while pushing the boundaries of tonal layering, we move beyond the "app" feel into a bespoke, premium experience.

## 2. Colors & Tonal Depth
This system uses a foundation of deep, ink-like blacks and oceanic indigos. The goal is to eliminate visual noise by removing structural lines and replacing them with color-space transitions.

### Palette Highlights
- **Background (`#0c0e12`):** A rich, obsidian base that provides the ultimate canvas for relaxation.
- **Primary (`#7fe6db`):** A soft, glowing teal used for active states and critical calls to action.
- **Secondary (`#96a5ff`):** A calming indigo for secondary accents and tranquil depth.

### The "No-Line" Rule
**Explicit Instruction:** 1px solid borders are strictly prohibited for sectioning or list items. In the legacy UI, harsh lines were used to separate "Rain on Car Roof" from "Rain on Lake." In this system, boundaries must be defined solely through background color shifts. Use `surface-container-low` for secondary sections and `surface-container-high` for interactive cards.

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of semi-opaque materials. 
- Use `surface-dim` for the absolute base.
- Use `surface-container` for main content areas.
- Nest `surface-container-highest` for high-priority elements like "Now Playing" widgets. 

### The "Glass & Gradient" Rule
To achieve a premium feel, all overlays (modals, menus, bottom sheets) must utilize **Glassmorphism**. Apply a `surface` color at 60-80% opacity with a heavy `backdrop-blur` (20px+). 

## 3. Typography
We use a dual-font strategy to balance editorial sophistication with iOS-native legibility.

- **Display & Headlines (Manrope):** Chosen for its geometric purity and modern warmth. Use `display-lg` for hero headers (e.g., "Good Evening") to create an authoritative, calm presence.
- **Body & Labels (Inter/SF Pro):** Used for all functional text. The tight tracking and high legibility ensure that even at `body-sm`, the UI remains accessible.
- **Editorial Contrast:** Leverage high-contrast scales. Pair a `headline-lg` title with a `label-sm` metadata tag to create an "editorial" look that avoids the generic "list" feel of the original UI.

## 4. Elevation & Depth
Traditional drop shadows are too aggressive for a relaxation context. We use **Tonal Layering** to define space.

- **The Layering Principle:** Instead of a shadow, place a `surface-container-lowest` card on a `surface-container-low` background. The subtle 2% shift in color is enough for the human eye to perceive depth without creating visual clutter.
- **Ambient Shadows:** For floating elements like the Play/Pause button, use "Extra-Diffused" shadows. 
    - *Blur:* 32px to 64px.
    - *Opacity:* 6% - 10%.
    - *Color:* Tinted with `on-surface` (`#f6f6fc`) rather than pure black.
- **The "Ghost Border" Fallback:** If accessibility requires a container definition, use the `outline-variant` token at 15% opacity. It should be felt, not seen.

## 5. Components

### Elegant Cards (Replacing Lists)
The dated list view from the reference image is deprecated. 
- **Style:** Use `xl` (1.5rem) rounded corners. 
- **Imagery:** Cards must feature high-quality, full-bleed imagery. 
- **Interaction:** On tap, the card should subtly scale (0.98x) to provide tactile feedback without a jarring color flash.

### Buttons & Controls
- **Primary Action:** Use the `primary` to `primary-container` subtle vertical gradient. Avoid flat fills for main playback buttons to give them a "jewel-like" quality.
- **Glass Chips:** For filters (e.g., "Nature," "Focus"), use semi-transparent `surface-variant` backgrounds with no border.

### Checkboxes & Radios
- **States:** Use the `primary` teal for active states. Use a "Soft Glow" effect (a 4px blur of the primary color) behind the checkmark to signify activity in the dark theme.

### Forbidding Dividers
Vertical white space (using the `1.5rem` or `2rem` spacing scale) is the only acceptable separator. If content feels too close, increase the padding; do not add a line.

## 6. Do's and Don'ts

| Do | Don't |
| :--- | :--- |
| Use full-bleed imagery for sound categories to create immersion. | Use small, low-resolution thumbnails or icons in a list. |
| Use `full` (9999px) roundedness for pill-shaped play buttons. | Use sharp corners or subtle `sm` rounding on main controls. |
| Group related sounds into wide, horizontal-scrolling carousels. | Stack every sound in a single, infinite vertical list. |
| Use `glassmorphism` for the Tab Bar and Navigation Bar. | Use solid, opaque background colors for navigation elements. |
| Leverage `vibrant` colors only for active audio waves or accents. | Use high-saturation colors for background surfaces. |

## 7. Spacing Scale
Maintain a "Breathing" layout.
- **Gutter:** 24px (gives the UI a high-end, spacious feel).
- **Component Gap:** 16px.
- **Section Gap:** 40px+. 
*Note: Increasing whitespace reduces cognitive load, which is the primary functional goal of a relaxation app.*
