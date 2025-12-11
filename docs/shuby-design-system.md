# Shuby Design System

Complete design system implementation based on Figma design tokens and screenshot analysis.

## Overview

The Shuby design system is implemented as a DaisyUI/Tailwind CSS theme named `shuby`. It provides:
- Complete color palette (Primary, Accent, Success, Warning, Danger, Neutrals)
- Typography system with Nunito font
- Component classes for buttons, tabs, cards, badges, etc.
- Spacing and border-radius systems

**Theme Files:**
- `app/assets/tailwind/themes/shuby.css` - Color variables and theme mappings
- `app/assets/tailwind/components/shuby.css` - Component utility classes

**Demo Page:** `/design_system` (development only)

---

## Color Tokens

### Primary Blue Scale

| Token | HEX | CSS Variable | Usage |
|-------|-----|--------------|-------|
| Blue 50 | `#F0F7FF` | `--color-shuby-blue-50` | Hover states, subtle backgrounds |
| Blue 100 | `#D4EDFF` | `--color-shuby-blue-100` | Section backgrounds (AI-helper, quiz) |
| Blue 200 | `#A8DBFF` | `--color-shuby-blue-200` | Light accents |
| Blue 300 | `#E5F2FF` | `--color-shuby-blue-300` | Card borders |
| Blue 500 | `#3B9EE8` | `--color-shuby-blue-500` | Mid-tone blue |
| Blue 700 | `#0D6EBF` | `--color-shuby-blue-700` | Hover on primary |
| Blue 800 | `#0159B5` | `--color-shuby-blue-800` | **Primary brand color** |
| Blue 900 | `#004488` | `--color-shuby-blue-900` | Dark blue |

### Accent Colors

| Token | HEX | CSS Variable | Usage |
|-------|-----|--------------|-------|
| Cyan 400 | `#4FC3C3` | `--color-shuby-cyan-400` | Character illustrations |
| Green 500 | `#2ECC71` | `--color-shuby-green-500` | Success, positive metrics |
| Orange 500 | `#F39C12` | `--color-shuby-orange-500` | Warnings, "Aggiorna" badge |
| Red 500 | `#E74C3C` | `--color-shuby-red-500` | Danger, "Elimina Account" |

### Magenta/Pink Scale (Selection Accent)

Used for date pickers, week selectors, and other selection states.

| Token | HEX | CSS Variable | Usage |
|-------|-----|--------------|-------|
| Magenta 50 | `#FDF4FF` | `--color-shuby-magenta-50` | Light selection background |
| Magenta 100 | `#FAE8FF` | `--color-shuby-magenta-100` | Hover backgrounds |
| Magenta 400 | `#E879F9` | `--color-shuby-magenta-400` | Selection borders |
| Magenta 500 | `#D946EF` | `--color-shuby-magenta-500` | **Primary selection color** |
| Magenta 600 | `#C026D3` | `--color-shuby-magenta-600` | Hover on selection |
| Purple 300 | `#A5B4FC` | `--color-shuby-purple-300` | Outline borders, today marker |

### Selection Theme Variables

| Variable | Maps To | Description |
|----------|---------|-------------|
| `--bg-selection` | Magenta 500 | Selected pill/week backgrounds |
| `--bg-selection-hover` | Magenta 600 | Hover on selected items |
| `--text-on-selection` | White | Text on selected items |
| `--border-selection` | Magenta 400 | Selection borders |
| `--text-selection` | Magenta 500 | Selection text color |
| `--bg-selection-light` | Magenta 50 | Light selection backgrounds |
| `--border-selection-outline` | Purple 300 | Today marker border |

### Neutral Colors

| Token | HEX | CSS Variable | Usage |
|-------|-----|--------------|-------|
| White | `#FFFFFF` | `--color-shuby-white` | Card backgrounds |
| Gray 100 | `#F3F4F6` | `--color-shuby-gray-100` | Light backgrounds |
| Gray 200 | `#E5E7EB` | `--color-shuby-gray-200` | Borders, dividers |
| Gray 400 | `#9CA3AF` | `--color-shuby-gray-400` | Placeholder text |
| Gray 500 | `#6B7280` | `--color-shuby-gray-500` | Secondary text, inactive |
| Gray 700 | `#374151` | `--color-shuby-gray-700` | Secondary headings |
| Black | `#000000` | `--color-shuby-black` | Body text |

---

## Typography System

### Font Family

**Nunito** - A rounded, child-friendly sans-serif font from Google Fonts.

```css
--font-sans: "Nunito", ui-sans-serif, system-ui, sans-serif;
```

### Typography Classes

| Class | Size | Weight | Line-Height | Usage |
|-------|------|--------|-------------|-------|
| `.shuby-d1` | 28px | Bold | 34px | Hero text |
| `.shuby-d2` | 20px | Bold | 24px | Card titles |
| `.shuby-h1` | 24px | Bold | 30px | Page titles |
| `.shuby-h2` | 20px | Semibold | 26px | Section titles |
| `.shuby-h3` | 16px | Semibold | 22px | Subsection titles |
| `.shuby-p1` | 14px | Regular | 150% | Main body text |
| `.shuby-p2` | 12px | Regular | 150% | Secondary text |
| `.shuby-caption` | 11px | Semibold | 14px | Labels (uppercase) |
| `.shuby-overline` | 12px | Semibold | 16px | Tags (uppercase) |

### Usage Example

```erb
<h1 class="shuby-d1">Il tempo speciale con il tuo bambino</h1>
<span class="shuby-overline">0–36 MESI</span>
<p class="shuby-p1">Un dono reciproco di attenzione esclusiva...</p>
```

---

## Spacing System

Based on an 8px unit system:

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Tight gaps |
| `--space-2` | 8px | Small gaps |
| `--space-3` | 12px | Element gaps |
| `--space-4` | 16px | Component padding |
| `--space-5` | 20px | Section gaps |
| `--space-6` | 24px | Card padding |
| `--space-8` | 32px | Section margins |
| `--space-10` | 40px | Large spacing |

---

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `--radius-sm` | 8px | Buttons, small elements |
| `--radius-md` | 12px | Cards, containers |
| `--radius-lg` | 16px | Large cards |
| `--radius-xl` | 24px | Pill buttons, inputs |
| `--radius-full` | 9999px | Circles, avatars |

---

## Component Classes

### Buttons

```erb
<%# Primary filled button %>
<button class="shuby-btn shuby-btn-lg shuby-btn-primary">Comincia</button>

<%# Outlined button %>
<button class="shuby-btn shuby-btn-lg shuby-btn-outline">Sì</button>

<%# Secondary button %>
<button class="shuby-btn shuby-btn-lg shuby-btn-secondary">No</button>

<%# Danger button %>
<button class="shuby-btn shuby-btn-lg shuby-btn-danger">Elimina</button>

<%# Icon button %>
<button class="shuby-icon-btn">+</button>
<button class="shuby-icon-btn shuby-icon-btn-outline">✏️</button>
```

**Button Sizes:**
- `.shuby-btn-lg` - Large (12px 24px padding, 16px font)
- `.shuby-btn-md` - Medium (10px 20px padding, 14px font)
- `.shuby-btn-sm` - Small (8px 16px padding, 14px font)

### Tabs

```erb
<div class="shuby-tabs">
  <button class="shuby-tab active">Famiglia</button>
  <button class="shuby-tab">Impostazioni</button>
  <button class="shuby-tab">Piano</button>
</div>
```

### Cards

```erb
<%# Standard card %>
<div class="shuby-card">
  <span class="shuby-overline">0–36 MESI</span>
  <h3 class="shuby-d2">Card Title</h3>
  <p class="shuby-p1">Card content...</p>
</div>

<%# Metric card (light blue background) %>
<div class="shuby-card-metric">
  <p class="shuby-h3">Peso</p>
  <span class="shuby-metric-value-success">3900</span>
  <span class="shuby-metric-unit">gr</span>
</div>
```

### Info Boxes

```erb
<%# Info box (RICORDA style) %>
<div class="shuby-info-box">
  <div class="shuby-info-box-header">
    <div class="shuby-info-box-icon">ℹ️</div>
    <span class="shuby-info-box-title">RICORDA:</span>
  </div>
  <p class="shuby-info-box-content">Important message here...</p>
</div>

<%# Warning box %>
<div class="shuby-warning-box">
  <p class="shuby-p1">Warning message...</p>
</div>

<%# Success box %>
<div class="shuby-success-box">
  <p class="shuby-p1">Success message...</p>
</div>
```

### Badges

```erb
<span class="shuby-badge shuby-badge-primary">Primary</span>
<span class="shuby-badge shuby-badge-outline">Outline</span>
<span class="shuby-badge shuby-badge-success">Success</span>
<span class="shuby-badge shuby-badge-warning">Aggiorna</span>
<span class="shuby-badge shuby-badge-info">Info</span>
```

### Tags (with Icon)

Pill-shaped tags with optional icon (footprint icon for child tracking features).

```erb
<%# Default gray tag %>
<span class="shuby-tag shuby-tag-default">
  <span class="shuby-tag-icon">
    <svg viewBox="0 0 24 24" fill="currentColor"><!-- footprint icon --></svg>
  </span>
  Tag
</span>

<%# Primary Blue tag %>
<span class="shuby-tag shuby-tag-primary">
  <span class="shuby-tag-icon"><!-- icon --></span>
  Tag
</span>

<%# Magenta tag %>
<span class="shuby-tag shuby-tag-magenta">
  <span class="shuby-tag-icon"><!-- icon --></span>
  Tag
</span>

<%# Info (Light Blue) tag %>
<span class="shuby-tag shuby-tag-info">
  <span class="shuby-tag-icon"><!-- icon --></span>
  Tag
</span>

<%# Yellow/Amber tag %>
<span class="shuby-tag shuby-tag-yellow">
  <span class="shuby-tag-icon"><!-- icon --></span>
  Tag
</span>

<%# Outline tag %>
<span class="shuby-tag shuby-tag-outline">
  <span class="shuby-tag-icon"><!-- icon --></span>
  Tag
</span>
```

**Tag Variants:**

| Class | Background | Text Color | Usage |
|-------|------------|------------|-------|
| `.shuby-tag-default` | Gray 100 | Gray 700 | Default state |
| `.shuby-tag-light` | White + border | Gray 700 | Light variant |
| `.shuby-tag-primary` | Blue 800 | White | Primary/active |
| `.shuby-tag-magenta` | Magenta 500 | White | Selection/highlight |
| `.shuby-tag-info` | Blue 100 | Blue 800 | Informational |
| `.shuby-tag-yellow` | Orange 500 | Gray 700 | Warning/attention |
| `.shuby-tag-outline` | Transparent | Blue 800 | Outlined variant |

**Size Variants:**
- Default: 6px 12px padding, 13px font
- `.shuby-tag-sm` - Small: 4px 10px padding, 11px font

**Interactive Tags:**
```erb
<%# Clickable tag with hover effect %>
<span class="shuby-tag shuby-tag-default shuby-tag-clickable">Tag</span>

<%# Selected state (turns magenta) %>
<span class="shuby-tag shuby-tag-default selected">Tag</span>
```

### Form Elements

```erb
<%# Input %>
<input type="text" class="shuby-input" placeholder="Fai una domanda">

<%# Toggle switch %>
<div class="shuby-toggle active">
  <div class="shuby-toggle-knob"></div>
</div>
```

### List Items

```erb
<div class="shuby-list-item">
  <div class="shuby-list-item-content">
    <img src="avatar.jpg" class="shuby-avatar">
    <div class="shuby-list-item-text">
      <span class="shuby-list-item-title">Name</span>
      <span class="shuby-list-item-subtitle">Subtitle</span>
    </div>
  </div>
  <button class="shuby-icon-btn shuby-icon-btn-outline">✏️</button>
</div>
```

### Progress Indicators

```erb
<div class="shuby-progress">
  <div class="shuby-progress-bar" style="width: 60%;"></div>
</div>

<%# Success variant %>
<div class="shuby-progress">
  <div class="shuby-progress-bar shuby-progress-bar-success" style="width: 100%;"></div>
</div>
```

### Section Backgrounds

```erb
<%# Light blue section background (AI-helper, quiz screens) %>
<div class="shuby-bg-section">
  <h2>Content here...</h2>
</div>
```

### Bottom Navigation (App Menu)

Mobile app bottom navigation bar with 4 menu items: Oggi, AI-helper, Archivio, Gestione.

```erb
<nav class="shuby-bottom-nav">
  <a href="/oggi" class="shuby-bottom-nav-item active">
    <div class="shuby-bottom-nav-icon">
      <svg><!-- Grid icon --></svg>
    </div>
    <span class="shuby-bottom-nav-label">Oggi</span>
  </a>
  <a href="/ai-helper" class="shuby-bottom-nav-item">
    <div class="shuby-bottom-nav-icon">
      <svg><!-- Chat/Robot icon --></svg>
    </div>
    <span class="shuby-bottom-nav-label">AI-helper</span>
  </a>
  <a href="/archivio" class="shuby-bottom-nav-item">
    <div class="shuby-bottom-nav-icon">
      <svg><!-- Folder icon --></svg>
    </div>
    <span class="shuby-bottom-nav-label">Archivio</span>
  </a>
  <a href="/gestione" class="shuby-bottom-nav-item">
    <div class="shuby-bottom-nav-icon">
      <svg><!-- Settings icon --></svg>
    </div>
    <span class="shuby-bottom-nav-label">Gestione</span>
  </a>
</nav>
```

**Structure:**
- `.shuby-bottom-nav` - Navigation container (flex, space-around)
- `.shuby-bottom-nav-item` - Individual nav link/button
- `.shuby-bottom-nav-icon` - Icon wrapper (24x24px)
- `.shuby-bottom-nav-label` - Text label (11px font)
- `.active` - Active state modifier

**States:**
| State | Color | Indicator |
|-------|-------|-----------|
| Inactive | Gray 500 (`#6B7280`) | None |
| Active | Blue 800 (`#0159B5`) | Dark underline bar |
| Hover | Blue 800 | Transition to blue |

**Fixed Position Variant:**
```erb
<%# For mobile app footer positioning %>
<nav class="shuby-bottom-nav shuby-bottom-nav-fixed">
  <!-- nav items -->
</nav>
```

### Date Picker Pills (Magenta Selection)

Horizontal scrollable date pills with magenta selection state.

```erb
<%# Date picker container %>
<div class="shuby-date-picker">
  <div class="shuby-date-pill">
    <span class="shuby-date-pill-day">Lu</span>
    <span class="shuby-date-pill-number">12</span>
  </div>
  <div class="shuby-date-pill selected">
    <span class="shuby-date-pill-day">Ma</span>
    <span class="shuby-date-pill-number">13</span>
  </div>
  <div class="shuby-date-pill">
    <span class="shuby-date-pill-day">Me</span>
    <span class="shuby-date-pill-number">14</span>
  </div>
  <div class="shuby-date-pill disabled">
    <span class="shuby-date-pill-day">Gi</span>
    <span class="shuby-date-pill-number">15</span>
  </div>
</div>
```

**States:**
- Default: White background with gray border
- Hover: Light magenta background
- Selected: Magenta background (`--bg-selection`)
- Disabled: Reduced opacity, not clickable

### Week/Step Selector (Magenta Selection)

For selecting weeks, months, or progress steps.

```erb
<%# Week selector %>
<div class="shuby-week-selector">
  <button class="shuby-week-item completed">1</button>
  <button class="shuby-week-item completed">2</button>
  <button class="shuby-week-item selected">3</button>
  <button class="shuby-week-item">4</button>
  <button class="shuby-week-item">5</button>
</div>
```

**States:**
- Default: Transparent background
- Hover: Light magenta background
- Selected: Magenta background (`--bg-selection`)
- Completed: Light magenta with checkmark

### Step Progress Dots

```erb
<div class="shuby-step-dots">
  <span class="shuby-step-dot completed"></span>
  <span class="shuby-step-dot completed"></span>
  <span class="shuby-step-dot active"></span>
  <span class="shuby-step-dot"></span>
</div>
```

### Calendar Grid

Full calendar component with magenta selection.

```erb
<div class="shuby-calendar-header">
  <span class="shuby-calendar-header-day">Lu</span>
  <span class="shuby-calendar-header-day">Ma</span>
  <span class="shuby-calendar-header-day">Me</span>
  <span class="shuby-calendar-header-day">Gi</span>
  <span class="shuby-calendar-header-day">Ve</span>
  <span class="shuby-calendar-header-day">Sa</span>
  <span class="shuby-calendar-header-day">Do</span>
</div>
<div class="shuby-calendar">
  <span class="shuby-calendar-day other-month">30</span>
  <span class="shuby-calendar-day">1</span>
  <span class="shuby-calendar-day today">2</span>
  <span class="shuby-calendar-day selected">3</span>
  <span class="shuby-calendar-day">4</span>
  <!-- ... more days -->
</div>
```

**Day States:**
- `.today` - Purple outline border
- `.selected` - Magenta background
- `.other-month` - Dimmed text
- `.disabled` - Not clickable

### Selection Badges

Magenta-colored badge variants.

```erb
<span class="shuby-badge shuby-badge-selection">Selected</span>
<span class="shuby-badge shuby-badge-selection-outline">Selection Outline</span>
```

---

## Timeline Components

The timeline components are used for navigating weeks and months in the child development tracking features.

### Timeline Container

Bordered container with lavender background for date pills.

```erb
<%# Lavender bordered container (as seen in Figma row 1) %>
<div class="shuby-timeline-container">
  <div class="shuby-timeline-pill selected-outline">
    <span class="shuby-timeline-pill-label">Sett.</span>
    <span class="shuby-timeline-pill-number">6</span>
  </div>
  <div class="shuby-timeline-pill">
    <span class="shuby-timeline-pill-label">Sett.</span>
    <span class="shuby-timeline-pill-number">7</span>
  </div>
  <!-- more pills -->
</div>

<%# Gray background container (alternate style) %>
<div class="shuby-timeline-container-alt">
  <div class="shuby-timeline-pill selected">
    <span class="shuby-timeline-pill-label">Sett.</span>
    <span class="shuby-timeline-pill-number">6</span>
  </div>
  <!-- more pills -->
</div>
```

**Container Variants:**
- `.shuby-timeline-container` - Lavender background with purple border
- `.shuby-timeline-container-alt` - Gray background, no border

### Timeline Pill States

```erb
<%# Default pill (white) %>
<div class="shuby-timeline-pill">
  <span class="shuby-timeline-pill-label">Sett.</span>
  <span class="shuby-timeline-pill-number">3</span>
</div>

<%# Outline selected (purple border, white bg) %>
<div class="shuby-timeline-pill selected-outline">
  <span class="shuby-timeline-pill-label">Sett.</span>
  <span class="shuby-timeline-pill-number">6</span>
</div>

<%# Filled selected (magenta bg) %>
<div class="shuby-timeline-pill selected">
  <span class="shuby-timeline-pill-label">Sett.</span>
  <span class="shuby-timeline-pill-number">6</span>
</div>
```

**Pill States:**
- Default: White background
- `.selected-outline` - White background with purple/blue outline border
- `.selected` - Magenta filled background with white text

### Settimana (Week) Selector

Full text week labels with progressive selection.

```erb
<div class="shuby-settimana-selector">
  <button class="shuby-settimana-item active">Settimana 1</button>
  <button class="shuby-settimana-item">Settimana 2</button>
  <button class="shuby-settimana-item">Settimana 3</button>
  <button class="shuby-settimana-item">Settimana 4</button>
</div>
```

**States:**
- Default: Transparent background, dark text
- `.active` or `[aria-selected="true"]` - Magenta background, white text
- Hover: Light magenta background

### Timeline Theme Variables

| Variable | HEX | Description |
|----------|-----|-------------|
| `--bg-timeline-container` | `#F5F3FF` | Lavender container background |
| `--border-timeline-container` | `#A5B4FC` | Purple container border |
| `--bg-timeline-container-alt` | `#F3F4F6` | Gray container background |
| `--border-selection-outline` | `#A5B4FC` | Outline selection border |
| `--bg-selection` | `#D946EF` | Magenta filled selection |
| `--text-on-selection` | `#FFFFFF` | White text on selection |

---

## Theme Integration

### HTML Setup

The theme is applied via `data-theme="shuby"` on the HTML element:

```erb
<%# app/views/layouts/application.html.erb %>
<html data-theme="shuby">
```

### CSS Variables Usage

Use CSS variables directly in styles:

```css
.my-component {
  color: var(--text-primary);
  background-color: var(--bg-info);
  border-color: var(--base-border-primary);
}
```

### Theme Variable Mappings

| Variable | Maps To | Description |
|----------|---------|-------------|
| `--bg-primary` | Blue 800 | Primary button backgrounds |
| `--text-primary` | Blue 800 | Primary text color |
| `--bg-info` | Blue 100 | Info box backgrounds |
| `--base-bg-section` | Blue 100 | Section backgrounds |
| `--base-border-primary` | Blue 300 | Card borders |
| `--text-success` | Green 500 | Success text |
| `--text-danger` | Red 500 | Danger text |

---

## File Structure

```
app/assets/tailwind/
├── application.css           # Main CSS, imports theme + components
├── themes/
│   └── shuby.css             # Shuby theme color variables
└── components/
    └── shuby.css             # Shuby component utility classes

app/views/
├── application/
│   └── _head.html.erb        # Nunito font import
├── design_system/
│   └── show.html.erb         # Design system demo page
└── layouts/
    └── application.html.erb  # data-theme="shuby"

config/routes/
└── dev.rb                    # /design_system route

docs/
└── shuby-design-system.md    # This documentation
```

---

## Development

### View Design System Demo

Start the development server and visit:
```
http://localhost:3000/design_system
```

The demo page displays:
- Complete color palette swatches
- Typography examples
- All button variants and sizes
- Tab components
- Card examples
- Info boxes
- Badges
- Form elements
- List items
- Progress indicators
- CSS variables reference table

### Adding New Components

1. Add CSS to `app/assets/tailwind/components/shuby.css`
2. Use the `shuby-` prefix for class names
3. Use CSS variables for colors (e.g., `var(--bg-primary)`)
4. Add examples to the design system demo page
5. Update this documentation
