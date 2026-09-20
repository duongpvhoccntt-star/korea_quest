---
name: K-Journal
colors:
  surface: '#FFFFFF'
  surface-dim: '#d0d9f9'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#e9edff'
  surface-container-high: '#e1e8ff'
  surface-container-highest: '#d9e2ff'
  on-surface: '#111b32'
  on-surface-variant: '#544247'
  inverse-surface: '#263048'
  inverse-on-surface: '#edf0ff'
  outline: '#877277'
  outline-variant: '#d9c0c6'
  surface-tint: '#9b3e60'
  primary: '#9b3e60'
  on-primary: '#ffffff'
  primary-container: '#ff8fb3'
  on-primary-container: '#792445'
  inverse-primary: '#ffb1c7'
  secondary: '#00658b'
  on-secondary: '#ffffff'
  secondary-container: '#77cdfd'
  on-secondary-container: '#005777'
  tertiary: '#266a51'
  on-tertiary: '#ffffff'
  tertiary-container: '#7cbfa2'
  on-tertiary-container: '#004e38'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffd9e2'
  primary-fixed-dim: '#ffb1c7'
  on-primary-fixed: '#3e001c'
  on-primary-fixed-variant: '#7d2648'
  secondary-fixed: '#c4e7ff'
  secondary-fixed-dim: '#7dd0ff'
  on-secondary-fixed: '#001e2c'
  on-secondary-fixed-variant: '#004c69'
  tertiary-fixed: '#acf1d1'
  tertiary-fixed-dim: '#91d4b6'
  on-tertiary-fixed: '#002115'
  on-tertiary-fixed-variant: '#01513a'
  background: '#faf8ff'
  on-background: '#111b32'
  surface-variant: '#d9e2ff'
  page-bg: '#FFF8F1'
  pale-pink: '#FFDCE8'
  sky-light: '#DDF4FF'
  butter-yellow: '#FFD96A'
  korean-red: '#EF646B'
  korean-blue: '#5876D8'
  border-soft: '#E8E2DB'
  success-green: '#63C59A'
  locked-gray: '#BBC1CC'
  text-secondary: '#667085'
typography:
  display-hero:
    fontFamily: Be Vietnam Pro
    fontSize: 48px
    fontWeight: '800'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.3'
  headline-lg-mobile:
    fontFamily: Be Vietnam Pro
    fontSize: 28px
    fontWeight: '700'
    lineHeight: '1.3'
  title-md:
    fontFamily: Be Vietnam Pro
    fontSize: 20px
    fontWeight: '700'
    lineHeight: '1.4'
  korean-sub:
    fontFamily: Noto Sans KR
    fontSize: 18px
    fontWeight: '500'
    lineHeight: '1.4'
  body-main:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-bold:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: 0.05em
  caption:
    fontFamily: Be Vietnam Pro
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1.4'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-padding: 24px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 40px
---

## Brand & Style

The design system embodies a **Modern Travel Journal** aesthetic, specifically tailored for a Vietnamese audience exploring Korean culture. It blends contemporary digital interfaces with tactile, analog scrapbook elements. 

The personality is **cheerful, hospitable, and culturally immersive**. It seeks to evoke the feeling of a crisp spring day in Seoul—filled with cherry blossoms, soft light, and the excitement of discovery. 

The design style is a hybrid of **Minimalism** (for structure) and **Tactile/Skeuomorphic** elements (for charm). 
- **The Journal Base:** Uses layered white surfaces over a warm, parchment-like background to simulate paper.
- **Illustrated Playfulness:** Incorporates digital "stickers," passport stamps, and organic cloud motifs to break the rigidity of the grid.
- **Soft Modernism:** High-quality rounded typography and pill-shaped interactive elements ensure the "cute" factor remains sophisticated and professional rather than juvenile.

## Colors

The palette is rooted in **Korean Pastels**, contrasting soft background tones with vibrant functional accents.

- **Primary (Cherry Blossom Pink):** Reserved for the most important calls to action and active states.
- **Secondary (Seoul Sky Blue):** Used for navigation, sky-themed illustrations, and informational links.
- **Background Strategy:** The `page-bg` (#FFF8F1) acts as the canvas, while `surface` (#FFFFFF) is used for cards and interactive components to create a "layered paper" effect.
- **Cultural Accents:** `korean-red` and `korean-blue` are used sparingly for traditional motifs (Taegeuk) or high-priority markers to maintain cultural authenticity without overwhelming the pastel harmony.

## Typography

The typography system relies on **Be Vietnam Pro** for its friendly, rounded terminals which match the "cute" aesthetic while remaining highly legible for Vietnamese text.

- **Scale:** High contrast between display headings and body text to help users navigate dense travel information.
- **Hangul Integration:** Use **Noto Sans KR** specifically for secondary labels or subtitles that feature Korean characters (e.g., location names like 서울).
- **Styling:** Headings should use tight letter-spacing to feel impactful, while body text uses a generous line-height (1.6) to ensure the journal content is easy to read.

## Layout & Spacing

The layout uses a **Fluid Grid** with fixed maximum widths for content containers to maintain a "journal page" feel.

- **Desktop (1200px+):** 12-column grid. The map occupies the left 7 columns, while the journey panel or info cards occupy the right 5 columns.
- **Mobile (<768px):** Single-column stack. Content transitions from a map-focused view to a full-screen "postcard" view for journey stages.
- **Spacing Rhythm:** Based on an 8px scale. Use generous padding inside cards (24px - 32px) to prevent elements from feeling cramped, reinforcing the airy, pastel mood.
- **Bojagi Layouts:** For decorative sections, use asymmetrical placements (like a patchwork quilt) to create visual interest.

## Elevation & Depth

Hierarchy is established through **Soft Layered Shadows** rather than high-contrast borders.

- **Level 1 (Base):** Map markers and decorative stickers. No shadows, or very tight 2px blurs.
- **Level 2 (Postcards/Cards):** Used for journey information. Shadow: `0 8px 24px rgba(40, 50, 74, 0.08)`. These should feel like they are resting lightly on the page.
- **Level 3 (Modals/Active Detail):** Significant depth. Shadow: `0 16px 48px rgba(40, 50, 74, 0.12)`. 
- **Backdrop:** When a journey stage is active, the background map is softened with a `blur(4px)` and a warm overlay (`#FFF8F1` at 60% opacity) to focus the user on the current task.

## Shapes

The shape language is defined by **pronounced, friendly curves**.

- **Containers:** Cards and primary panels use a 24px - 28px radius (`rounded-xl`).
- **Interactive Elements:** Buttons and filter chips must be **Pill-shaped** (fully rounded) to maximize the "soft" tactile feel.
- **Decorative Masks:** Images of Korean landmarks should use organic, slightly irregular rounded shapes (reminiscent of cloud motifs) rather than perfect rectangles.

## Components

### Buttons & Chips
- **Primary Button:** Pill-shaped, `primary-color` background, white text. On hover, shifts to a slightly darker pink with a small bounce animation.
- **Secondary Button:** Pill-shaped, `sky-light` background, `secondary-color` text.
- **Filter Chips:** Small pill shapes using `pale-pink` or `sky-light`. Active states use a 2px solid border of the corresponding main color.

### Interactive Map
- **Markers:** Illustrated icons inside circles. 
  - *Completed:* Green ring with a small "stamp" icon.
  - *In-progress:* Pulsing `secondary-color` ring.
  - *Locked:* `locked-gray` with a padlock icon.
- **Tooltips:** Sky-blue containers with a 20px radius and a small arrow pointing to the pin.

### Journey Progress (The 9-Stage System)
- **Progress Track:** A dotted line connecting 9 points, styled like a flight path on a map.
- **Stage Cards:** Vertical cards with a "Ticket" aesthetic—incorporate a perforated edge graphic on one side and a Vietnamese label (e.g., "Chặng 01").

### Cards & Modals
- **Fact Cards:** White surface, 24px radius, featuring a "Travel Stamp" in the top-right corner as a decorative element.
- **Input Fields:** Soft `border-soft` outlines, 12px radius, with a focus state that uses `korean-blue`.

### UI Labels (Vietnamese)
- **Start:** "Bắt đầu hành trình"
- **Explore:** "Khám phá ngay"
- **Completed:** "Đã hoàn thành"
- **Stage X of 9:** "Chặng X/9"
- **Fun Fact:** "Bạn có biết?"