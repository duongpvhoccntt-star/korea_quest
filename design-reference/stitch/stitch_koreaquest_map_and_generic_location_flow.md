# STITCH UI BRIEF — KOREAQUEST MAP & GENERIC LOCATION FLOW

> Dùng toàn bộ file này làm prompt cho Stitch.
> Thiết kế gồm **một trang chủ bản đồ Hàn Quốc** và **một template khám phá dùng chung cho mọi địa điểm**. Không xây dựng riêng nội dung cho Namsan, Jeju hay bất kỳ địa điểm cụ thể nào trong các chặng.

---

## MASTER PROMPT FOR STITCH

Create a polished, high-fidelity, responsive cultural exploration web app named **KoreaQuest**.

The app helps Vietnamese students, travelers, and general users discover destinations across South Korea through an interactive map and a reusable cultural-learning journey.

The product has two layers:

1. **Korea Map Home** — an interactive map of South Korea with discoverable destination markers.
2. **Generic Location Experience** — one reusable nine-stage template that receives content dynamically for whichever destination the user selects.

### Primary user flow

**Trang chủ bản đồ → Chọn một địa điểm → Media mở đầu → Tổng quan → Lịch sử → Điểm đến → Văn hóa / Trải nghiệm → Ẩm thực → Fun Facts → Quiz / Mini game → Thông tin du lịch → Hoàn thành → Trở về bản đồ**

### Required output

- Create one connected responsive web app, not unrelated mockups.
- Desktop-first artboard: **1440 × 900**, suitable for a 16:9 presentation.
- Also define coherent tablet and mobile layouts.
- All user-facing copy must be in natural Vietnamese.
- Use the app name **KoreaQuest** consistently.
- Keep the bright, cute, Korean-inspired pastel visual style defined below.
- Create a consistent reusable design system.
- Design every important interaction state.
- Make the map and location journey feel connected.

---

## STRICT GENERIC-TEMPLATE RULE

The homepage map may show real example destination names so users can understand where they can explore.

After a destination is selected, all location screens must remain **generic templates**.

### Allowed on the homepage map

Examples such as:

- Đảo Jeju
- Tháp Namsan
- Cung điện Gyeongbokgung
- Làng văn hóa Gamcheon
- Làng Hanok Jeonju
- Cố đô Gyeongju
- Vườn quốc gia Seoraksan
- Bãi biển Haeundae

### Not allowed inside the nine location stages

- Do not write a full page specifically about one real destination.
- Do not fill the timeline with real historical dates.
- Do not fill destination cards with real sub-locations.
- Do not generate real culture, food, facts, Quiz answers, prices, or opening hours.
- Do not make Namsan, Jeju, Seoul, or another place the default content of the template.

### Required placeholder approach

Use clear reusable variables and field labels, for example:

- `{{LOCATION_NAME}}`
- `{{LOCATION_NAME_KO}}`
- `{{LOCATION_NAME_EN}}`
- `{{LOCATION_REGION}}`
- `{{HERO_IMAGE_OR_VIDEO}}`
- `{{SHORT_DESCRIPTION}}`
- `{{DETAILED_DESCRIPTION}}`
- `{{HISTORY_ITEMS}}`
- `{{HIGHLIGHT_ITEMS}}`
- `{{CULTURE_ITEMS}}`
- `{{FOOD_ITEMS}}`
- `{{FUN_FACT_ITEMS}}`
- `{{QUIZ_ITEMS}}`
- `{{TRAVEL_INFO}}`

The UI should demonstrate layout, hierarchy, field placement, interaction, and states—not provide completed content for a specific destination.

---

## VISUAL DIRECTION

Create a bright, cute, contemporary Korean travel aesthetic. The app should feel youthful, cheerful, polished, and easy to explore without becoming childish.

### Mood

- Korean pastel travel journal
- playful illustrated map
- colorful postcard collection
- friendly cultural adventure
- soft, modern, and optimistic
- educational without resembling a school test

### Color palette

| Role                 | Color       |
| -------------------- | ----------- |
| Warm page background | `#FFF8F1` |
| White surface        | `#FFFFFF` |
| Cherry blossom pink  | `#FF8FB3` |
| Pale pink            | `#FFDCE8` |
| Seoul sky blue       | `#79CFFF` |
| Pale sky blue        | `#DDF4FF` |
| Fresh mint           | `#9FE3C4` |
| Butter yellow        | `#FFD96A` |
| Korean red accent    | `#EF646B` |
| Korean blue accent   | `#5876D8` |
| Main text            | `#28324A` |
| Secondary text       | `#667085` |
| Soft border          | `#E8E2DB` |
| Completed green      | `#63C59A` |
| Unavailable gray     | `#BBC1CC` |

### Typography

- Main UI font: **Be Vietnam Pro** or another rounded sans-serif with full Vietnamese support.
- Korean labels: **Noto Sans KR**.
- Use bold, friendly display headings and highly readable body copy.
- Ensure Vietnamese diacritics render correctly.

### Shapes and surfaces

- Rounded corners: 20–28 px.
- Pill-shaped buttons and filters.
- Soft layered shadows.
- Thin colorful borders.
- Large media areas with organic rounded masks.
- Postcard cards with subtle layered depth.
- Generous spacing and clear hierarchy.

### Korean-inspired decorations

Use a small, balanced selection of:

- simplified Korean cloud motifs
- subtle bojagi patchwork
- dancheong-inspired geometric corners
- hanbok ribbon curves
- cherry blossom petals
- taegeuk-inspired red-and-blue accents
- travel tickets, passport stamps, map pins, postcards, and camera stickers
- verified Hangul stamps such as “한국”, “서울”, and “여행”

Do not use fake Korean writing. Decorations must frame content rather than cover it.

### Finished-product rule

Do not display internal labels such as theme names, redesign notes, UI explanations, or production comments in the app interface.

---

# SCREEN 0 — TRANG CHỦ BẢN ĐỒ HÀN QUỐC

This is the main entry screen and the central navigation hub of KoreaQuest.

## Purpose

- Introduce the app.
- Show which places can be explored.
- Let users choose a destination directly from the map.
- Show discovery progress across South Korea.
- Provide search, filters, recommendations, and recently viewed places.

## Desktop layout

Create a full-height dashboard-style homepage.

### Header

Include:

- KoreaQuest logo
- app name: **KoreaQuest**
- navigation: **Bản đồ**, **Bộ sưu tập**, **Hành trình**, **Hội nhóm**
- search action
- notification icon
- user avatar
- overall XP or badge count

Do not create a teacher or classroom navigation item.

### Intro panel

Place a compact welcoming panel beside or above the map.

Suggested copy:

Eyebrow:

**KHÁM PHÁ HÀN QUỐC**

Title:

**Bạn muốn bắt đầu từ đâu?**

Description:

**Chọn một điểm trên bản đồ để mở hành trình khám phá hình ảnh, lịch sử, văn hóa, ẩm thực và những thử thách thú vị.**

Progress example:

**Đã khám phá 3/12 địa điểm**

Primary action:

**Tiếp tục hành trình gần nhất**

Secondary action:

**Chọn ngẫu nhiên một địa điểm**

## Interactive South Korea map

Create a large illustrated map of South Korea as the visual focus.

### Geographic requirements

- Use a recognizable silhouette of South Korea.
- Show Jeju Island in approximately the correct position below the southwest of the peninsula.
- Add subtle province or regional boundaries without clutter.
- Keep coastlines recognizable.
- Do not distort geography merely to fit the markers.
- The map should remain legible on desktop, tablet, and mobile.

### Example markers

Place approximately 8–12 discoverable markers. Use these as homepage examples only:

| Marker                     | Region           | Suggested category            |
| -------------------------- | ---------------- | ----------------------------- |
| Tháp Namsan               | Seoul            | Biểu tượng thành phố     |
| Cung điện Gyeongbokgung  | Seoul            | Lịch sử / kiến trúc       |
| Đảo Jeju                 | Jeju             | Thiên nhiên / trải nghiệm |
| Làng văn hóa Gamcheon   | Busan            | Nghệ thuật / cộng đồng   |
| Bãi biển Haeundae        | Busan            | Biển / giải trí            |
| Cố đô Gyeongju          | Gyeongsangbuk-do | Di sản / lịch sử           |
| Làng Hanok Jeonju         | Jeonju           | Kiến trúc / văn hóa       |
| Vườn quốc gia Seoraksan | Gangwon-do       | Thiên nhiên / trekking      |

Additional markers may be represented as “Sắp ra mắt”, but do not overcrowd the map.

### Marker design

Use illustrated pins with small category icons.

Create these states:

1. **Chưa khám phá** — normal colorful pin.
2. **Đang khám phá** — pin with progress ring.
3. **Đã hoàn thành** — pin with check or badge.
4. **Mới** — pin with small “Mới” ribbon.
5. **Sắp ra mắt** — soft gray pin with clock icon.
6. **Đang chọn** — enlarged pin with gentle pulse.

Do not use incorrect answers or scores to lock a location.

### Marker interaction

Desktop:

- Hover shows a small tooltip with name and region.
- Click selects the marker and opens a destination preview card.

Mobile:

- Tap selects the marker.
- Open the destination preview in a bottom sheet.

Keyboard:

- Every marker must be focusable.
- Enter or Space opens its preview.

### Destination preview card

The map preview may contain real marker metadata, but not the full nine-stage content.

Include:

- thumbnail image
- destination name
- Korean name when available
- region
- category tags
- one-sentence teaser
- journey progress
- estimated discovery time
- collected badge status
- primary button: **Khám phá địa điểm**
- secondary button: **Lưu vào hành trình**

Selecting **Khám phá địa điểm** opens the generic location template populated later by data.

## Map controls

Include:

- zoom in/out
- reset view
- locate region
- show/hide completed locations
- accessible list-view alternative

Avoid decorative controls with no function.

## Search and filters

### Search

Placeholder:

**Tìm địa điểm, thành phố hoặc trải nghiệm…**

Search result rows contain:

- small image
- destination name
- region
- category
- status

Selecting a result highlights the matching map marker.

### Filters

Create filter chips or a filter drawer for:

- Tất cả
- Seoul
- Jeju
- Busan
- Di sản
- Thiên nhiên
- Văn hóa
- Ẩm thực
- Đã hoàn thành
- Chưa khám phá

Filters must update both map pins and the location list.

## Content below the map

Add three compact modules:

### Tiếp tục khám phá

- one in-progress destination card
- current stage
- progress percentage
- button: **Tiếp tục**

### Gợi ý cho bạn

- 3 horizontally scrollable destination cards
- based on selected category or recent activity
- button: **Xem trên bản đồ**

### Bộ sưu tập huy hiệu

- recently earned badges
- empty slots for future destinations
- progress toward next collection milestone

## Homepage empty and loading states

Design:

- map loading skeleton
- no search results
- filter with zero destinations
- offline media fallback
- no journey started yet

Suggested empty-state action:

**Khám phá địa điểm đầu tiên**

---

# TRANSITION — MAP TO LOCATION EXPERIENCE

When a user chooses **Khám phá địa điểm**, create a short transition that visually connects the selected marker to the location journey.

Possible treatment:

- selected marker expands into a postcard
- map zooms gently toward the region
- postcard becomes the location hero media frame
- journey stepper appears

Use a brief 300–500 ms transition. Respect reduced-motion preferences.

On all location screens, provide a clear control:

**← Trở về bản đồ Hàn Quốc**

Preserve the selected location and current stage when the user returns.

---

# GENERIC LOCATION EXPERIENCE

The following is a reusable template. It must work for every destination selected from the homepage map.

## Location context variables

Use these variables throughout the UI:

```text
{{LOCATION_ID}}
{{LOCATION_NAME}}
{{LOCATION_NAME_KO}}
{{LOCATION_NAME_EN}}
{{LOCATION_REGION}}
{{LOCATION_ADDRESS}}
{{LOCATION_TYPE}}
{{LOCATION_TAGS}}
{{LOCATION_PROGRESS}}
{{LOCATION_BADGE}}
```

Do not replace these variables with the details of a real place in this design file.

## Location header

Create a sticky location header containing:

- **← Bản đồ**
- `{{LOCATION_NAME}}`
- `{{LOCATION_NAME_KO}}`
- region chip: `{{LOCATION_REGION}}`
- current stage: **Chặng X/9**
- journey progress bar
- current XP
- bookmark button

## Nine-stage navigation

Use this exact order:

1. Mở đầu
2. Tổng quan
3. Lịch sử
4. Điểm đến
5. Trải nghiệm
6. Ẩm thực
7. Fun Facts
8. Quiz
9. Du lịch

Desktop:

- horizontal stepper or compact travel route
- completed stage uses a check icon
- current stage uses a colorful pill
- available stage is neutral

Mobile:

- horizontally scrollable stepper or current-stage menu
- show **Chặng X/9** clearly

Do not create a separate “Nhiệm vụ” tab.

## Content-display rule

The nine stages below show only:

- which content fields exist
- where fields appear
- how users open detailed content
- required counts and word lengths
- interactions and states

They must not contain completed factual content for a real destination.

Use placeholder labels such as:

- `[Ảnh / video mở đầu]`
- `[Tagline ngắn]`
- `[Mô tả ngắn 20–40 từ]`
- `[Mô tả chi tiết 80–120 từ]`
- `[Mốc lịch sử 01]`
- `[Tên điểm đến]`
- `[Tên món ăn]`
- `[Fun fact 01]`
- `[Câu hỏi Quiz]`
- `[Giờ mở cửa — dữ liệu từ nguồn chính thức]`

---

# STAGE 1 — MEDIA MỞ ĐẦU / HOOK

## Purpose

Create an emotional visual hook for the currently selected destination without supplying destination-specific content.

## Displayed content

- `[Ảnh hero hoặc video 15–60 giây]`
- `{{LOCATION_NAME}}`
- `{{LOCATION_NAME_KO}}`
- `[Tagline ngắn 4–10 từ]`
- `[Caption một câu]`
- `[Câu hỏi gợi mở — không yêu cầu trả lời]`
- `[Nguồn media]`

## Layout

- large rounded hero media frame
- readable title overlay or adjacent title block
- play/pause, mute, captions, and full-screen controls for video
- subtle Korean travel decorations
- progress label: **Chặng 1/9**

## Actions

- **Xem media**
- **Bắt đầu khám phá**
- **Trở về bản đồ**

## States

- image loaded
- video ready
- video playing
- media viewed
- loading skeleton
- media error fallback with source action

## Transition

Use generic copy:

Title:

**Bạn đã bắt đầu hành trình!**

Button:

**Tiếp tục đến Tổng quan**

---

# STAGE 2 — THÔNG TIN TỔNG QUAN

## Displayed content

| Field                               | UI treatment              |
| ----------------------------------- | ------------------------- |
| `{{LOCATION_NAME}}`               | Primary title             |
| `{{LOCATION_NAME_KO}}`            | Korean subtitle           |
| `{{LOCATION_NAME_EN}}`            | English-name row          |
| `{{LOCATION_REGION}}`             | Region chip               |
| `{{LOCATION_ADDRESS}}`            | Location row with map pin |
| `{{LOCATION_TYPE}}`               | Category badge            |
| `[Mô tả ngắn 20–40 từ]`      | Visible summary card      |
| `[Mô tả chi tiết 80–120 từ]` | Expandable detail area    |
| `[3–5 thông tin nhanh]`         | Colorful fact cards       |
| `{{LOCATION_TAGS}}`               | Tag chips                 |
| `[Nguồn và ngày cập nhật]`   | Compact metadata row      |

## Layout

- two-column identity section
- media or mini-map on one side
- location identity card on the other
- quick-fact cards below
- “Xem chi tiết” for the long description

## Actions

- **Xem chi tiết**
- **Mở bản đồ vị trí**
- **Lưu địa điểm**
- **Tiếp tục đến Lịch sử**

Do not fill the fields with data from any example map marker.

---

# STAGE 3 — LỊCH SỬ HÌNH THÀNH

## Required quantity

Display **4–6 generic historical milestone components**.

## Fields in every milestone

- `[Năm / giai đoạn]`
- `[Tiêu đề 4–10 từ]`
- `[Mô tả ngắn 20–35 từ]`
- `[Mô tả chi tiết 70–120 từ]`
- `[Nhân vật liên quan — nếu có]`
- `[Ảnh / tư liệu lịch sử]`
- `[Fun fact của mốc]`
- `[Nguồn tư liệu]`

## Layout

- curved interactive timeline on desktop
- vertical timeline or accordion on mobile
- short description visible by default
- detailed description opens in a side panel, modal, or accordion

## Placeholder milestone labels

Use only neutral structural labels:

- **Mốc lịch sử 01**
- **Mốc lịch sử 02**
- **Mốc lịch sử 03**
- **Mốc lịch sử 04**
- optional **Mốc lịch sử 05–06**

Do not insert real dates, people, events, or archival claims.

## Actions

- **Mở tư liệu**
- **Xem chi tiết**
- **Tiếp tục đến Điểm đến**

---

# STAGE 4 — ĐIỂM ĐẾN ĐÁNG CHÚ Ý

This stage represents notable sub-places or spaces belonging to the selected location.

## Required quantity

Display **4–6 generic highlight cards**.

## Fields in every card

- `[Ảnh / video]`
- `[Tên điểm đến]`
- `[Tên tiếng Hàn]`
- `[Tagline]`
- `[Mô tả ngắn 25–40 từ]`
- `[Mô tả chi tiết 70–110 từ]`
- `[Location / địa chỉ]`
- `[Hoạt động nổi bật]`
- `[Fun fact]`
- `[Nguồn]`

## Layout

- one featured card plus a responsive grid
- optional numbered mini-map
- filter chips for activity types
- short content on cards
- detailed content inside a modal or drawer

## Placeholder card labels

- **Điểm đến 01**
- **Điểm đến 02**
- **Điểm đến 03**
- **Điểm đến 04**
- optional **Điểm đến 05–06**

## Actions

- **Khám phá**
- **Xem vị trí**
- **Lưu vào hành trình**
- **Tiếp tục đến Trải nghiệm**

Do not use real sub-locations from any homepage marker.

---

# STAGE 5 — VĂN HÓA / TRẢI NGHIỆM ĐỘC ĐÁO

## Required quantity

Display **3–5 generic cultural or experiential story components**.

## Fields in every story

- `[Tên nội dung]`
- `[Tên tiếng Hàn]`
- `[Ảnh / video]`
- `[Mô tả ngắn 25–40 từ]`
- `[Mô tả chi tiết 70–120 từ]`
- `[Nguồn gốc / ý nghĩa]`
- `[Đặc điểm dễ nhận biết]`
- `[Điều nên làm — nếu có]`
- `[Điều không nên làm — nếu có]`
- `[Trải nghiệm thực tế liên quan]`
- `[Nguồn]`

## Layout

- alternating media-and-text storytelling blocks
- category chips
- “Nguồn gốc & ý nghĩa” detail panel
- “Dấu hiệu nhận biết” list
- friendly “Nên làm / Không nên làm” cards
- real-experience suggestion area

## Placeholder labels

- **Trải nghiệm 01**
- **Trải nghiệm 02**
- **Trải nghiệm 03**
- optional **Trải nghiệm 04–05**

## Actions

- **Tìm hiểu ý nghĩa**
- **Xem cách trải nghiệm**
- **Tiếp tục đến Ẩm thực**

Do not generate a real tradition, activity, or etiquette rule.

---

# STAGE 6 — ẨM THỰC

## Required quantity

Display **3–6 generic food cards**.

## Fields in every card

- `[Ảnh món ăn]`
- `[Tên món]`
- `[Tên tiếng Hàn]`
- `[Mô tả ngắn 20–30 từ]`
- `[Mô tả chi tiết 50–80 từ]`
- `[Nguyên liệu]`
- `[Hương vị]`
- `[Điểm đặc biệt]`
- `[Nơi có thể trải nghiệm]`
- `[Phân loại: tại địa điểm / gần địa điểm / gợi ý khu vực]`
- `[Nguồn]`

## Layout

- image-led responsive food grid
- flavor chips
- ingredient chips
- clear experience-location label
- detail modal or accordion

## Placeholder labels

- **Món ăn 01**
- **Món ăn 02**
- **Món ăn 03**
- optional **Món ăn 04–06**

## Actions

- **Xem món ăn**
- **Lưu vào danh sách**
- **Xem nơi trải nghiệm**
- **Tiếp tục đến Fun Facts**

Do not insert the name or description of a real dish.

---

# STAGE 7 — FUN FACTS

## Required quantity

Display **4–6 generic collectible fact cards**.

## Fields in every card

- `[Fun fact 15–35 từ]`
- `[Chủ đề]`
- `[Ảnh / minh họa hỗ trợ]`
- `[Nguồn]`
- `[Trạng thái chưa mở / đã mở]`

## Layout

Use one coherent playful pattern:

- flip cards
- collectible stickers
- postcard carousel
- envelope reveal
- scrapbook wall

Show progress:

**Đã mở {{OPENED_FACTS}}/{{TOTAL_FACTS}} Fun Facts**

## Placeholder labels

- **Fun Fact 01**
- **Fun Fact 02**
- **Fun Fact 03**
- **Fun Fact 04**
- optional **Fun Fact 05–06**

## Actions

- **Mở Fun Fact**
- **Xem nguồn**
- **Bắt đầu Quiz**

Do not write a real fact about any map location.

---

# STAGE 8 — QUIZ / MINI GAME

## Required quantity

Display a Quiz system designed to receive **10–15 dynamic tasks**. Recommended default slot count: **12**.

## Supported task types

- multiple choice
- image question
- video question
- history question
- culture question
- experience question
- travel scenario
- True / False
- matching
- timeline ordering

## Generic question data

Each task component accepts:

```text
{{QUESTION_ID}}
{{QUESTION_TYPE}}
{{QUESTION_CATEGORY}}
{{QUESTION_TEXT}}
{{QUESTION_MEDIA}}
{{ANSWER_OPTIONS}}
{{CORRECT_ANSWER}}
{{ANSWER_EXPLANATION_25_TO_50_WORDS}}
{{XP_CORRECT}}
{{XP_INCORRECT}}
```

Do not populate these variables with questions about a real destination.

## Quiz home

Display:

- `{{LOCATION_NAME}}`
- **Thử thách khám phá**
- `{{TOTAL_QUESTIONS}} nhiệm vụ`
- estimated time
- possible XP
- category overview
- current progress
- button: **Bắt đầu thử thách**

## Learning behavior

- Correct answer: **+20 XP**.
- Incorrect answer: **+5 XP**.
- An incorrect answer still completes the task.
- Reveal the correct answer and a 25–50-word explanation.
- Never force a retry.
- Do not block journey completion based on score.

Correct state copy:

**Chính xác!**

Incorrect state copy:

**Chưa chính xác, nhưng nhiệm vụ vẫn được hoàn thành.**

## Question UI states

- default
- hover
- selected
- submitted
- correct
- incorrect
- correct answer revealed
- completed

## Matching and timeline responsiveness

- Desktop: drag-and-drop or click-to-connect.
- Mobile: tap-to-select or move-up/down controls.
- Always provide a keyboard-accessible alternative.

## Quiz completion panel

Use generic variables:

- `{{LOCATION_BADGE}}`
- `{{COMPLETED_QUESTIONS}}/{{TOTAL_QUESTIONS}}`
- `{{CORRECT_COUNT}} câu đúng`
- `{{TOTAL_XP}} XP`
- `[Lời động viên theo kết quả]`

Actions:

- **Xem thông tin du lịch**
- **Xem lại kiến thức**
- **Chơi lại Quiz**

Keep the Quiz result inside this stage. Do not create a separate Result stage.

---

# STAGE 9 — THÔNG TIN DU LỊCH THỰC TẾ

## Displayed content

- `[Giờ mở cửa]`
- `[Giá vé]`
- `[Cách di chuyển]`
- `[Thời gian tham quan gợi ý]`
- `[Thời điểm đẹp nhất]`
- `[Lưu ý khi tham quan]`
- `[Khả năng tiếp cận]`
- `[Nguồn chính thức]`
- `[Cập nhật lần cuối]`

## Dynamic travel-data variables

```text
{{OPENING_HOURS}}
{{TICKET_PRICE}}
{{TRANSPORT_OPTIONS}}
{{SUGGESTED_DURATION}}
{{BEST_TIME_TO_VISIT}}
{{VISITOR_NOTES}}
{{ACCESSIBILITY_INFO}}
{{OFFICIAL_SOURCE_URL}}
{{LAST_UPDATED_DATE}}
```

Do not populate changing information with invented values.

## Layout

- travel planner dashboard
- four quick summary cards
- transport tabs or route cards
- visitor-notes checklist
- official-source panel
- last-updated status

Show this notice:

**Thông tin có thể thay đổi. Hãy kiểm tra nguồn chính thức trước khi đi.**

## Actions

- **Lưu kế hoạch chuyến đi**
- **Mở bản đồ**
- **Xem nguồn chính thức**
- **Hoàn thành địa điểm**

---

# LOCATION COMPLETION & RETURN TO MAP

After the user completes the location journey, show a centered celebration modal.

## Generic completion content

Title:

**Bạn đã hoàn thành {{LOCATION_NAME}}!**

Display:

- `{{LOCATION_BADGE}}`
- `{{COMPLETED_STAGES}}/9 chặng`
- `{{TOTAL_XP}} XP`
- `{{CORRECT_COUNT}}/{{TOTAL_QUESTIONS}} câu đúng`
- `[Lời động viên]`

Actions:

- **Trở về bản đồ Hàn Quốc**
- **Xem lại địa điểm**
- **Chia sẻ huy hiệu**

When the user returns home:

- the selected map marker changes to **Đã hoàn thành**
- the discovery counter updates
- the new badge appears in the homepage collection
- other available markers remain selectable

Do not require a perfect Quiz score to complete a destination.

---

## GENERIC SECTION-COMPLETION MODAL

After a content stage is viewed, the interface may show a light completion modal using variables.

### Content

- `{{STAGE_NUMBER}}`
- `{{STAGE_NAME}}`
- `[Lời động viên ngắn]`
- `{{LOCATION_PROGRESS}}`
- button: **Tiếp tục đến {{NEXT_STAGE_NAME}}**

### Visual design

- warm dimmed overlay with subtle blur
- white rounded card
- stage illustration
- small blossom/confetti animation
- clear next-step CTA

Do not add a question to this modal.

---

## MEDIA COMPONENTS

### Image component

Support:

- image placeholder
- Vietnamese alt text
- caption
- source
- photographer/owner label
- loading skeleton
- unavailable-media fallback

### Video component

Support:

- thumbnail
- duration
- title
- source
- caption/subtitle indicator
- play/pause
- mute
- full-screen
- loading and error states

Do not create fake source links.

---

## REUSABLE COMPONENT LIBRARY

### Homepage components

- Korea map
- destination marker
- marker tooltip
- destination preview card
- search result
- region/category filters
- continue-journey card
- recommendation card
- badge collection

### Location components

- location header
- nine-stage stepper
- hero media
- identity card
- quick-fact card
- history milestone
- highlight postcard
- culture story card
- etiquette card
- food card
- Fun Fact collectible
- Quiz question
- answer option
- feedback panel
- travel info card
- source/update card
- stage-completion modal
- location-completion modal

### Button variants

- primary pink gradient
- secondary blue outline
- soft ghost
- map action
- media action
- icon-only
- disabled
- loading

### Status variants

- available
- selected
- in progress
- viewed
- completed
- new
- coming soon
- correct
- incorrect
- media unavailable

---

## STATE AND DATA BEHAVIOR

The prototype should visually demonstrate:

- selected map destination
- location preview open
- new journey started
- current location stage
- viewed content cards
- completed stage
- Quiz progress
- XP updates
- completed location
- returned map with updated marker and badge

Suggested state model:

```text
Map destination status:
available | in_progress | completed | new | coming_soon

Location stage status:
not_started | current | viewed | completed

Quiz task status:
not_started | selected | correct | incorrect | completed
```

Do not make correctness control navigation access.

---

## RESPONSIVE BEHAVIOR

### Desktop

- 12-column grid.
- Maximum content width around 1200–1280 px.
- Map and intro panel can use a 7/5 or 8/4 split.
- Rich two-column location layouts.
- Sticky header and journey stepper.

### Tablet

- 8-column grid.
- Map remains large and usable.
- Preview card may overlay the lower map area.
- Stack complex location layouts.

### Mobile

- Single-column layout.
- Map fills most of the first screen below the header.
- Destination preview opens as a bottom sheet.
- Provide a switch between **Bản đồ** and **Danh sách**.
- Minimum 44 px touch targets.
- Use a compact horizontal stage stepper.
- Long details open in accordions or bottom sheets.
- Convert drag interactions to tap alternatives.

---

## ACCESSIBILITY

- Maintain readable color contrast.
- Do not communicate states using color alone.
- Make map markers keyboard accessible.
- Provide a destination list as an alternative to the visual map.
- Add visible focus states.
- Add Vietnamese alt-text placeholders.
- Caption video content.
- Trap focus correctly inside modals and bottom sheets.
- Respect reduced-motion preferences.
- Ensure Vietnamese and Korean text render correctly.

---

## CONTENT AND SOURCE RULES

- Homepage map markers may use real location names.
- All nine location stages must use generic variables and placeholders.
- Do not invent facts, dates, media, prices, hours, or routes.
- Keep short and detailed description slots separate.
- Use progressive disclosure for long descriptions.
- Show source fields in every detailed content type.
- Show update dates for changing travel information.
- Do not create a specific Namsan, Jeju, or other destination page in this template.

---

## FINAL QUALITY CHECK

Before completing the design, verify:

- [ ] There is a dedicated Korea map homepage before the location journey.
- [ ] The South Korea map is recognizable and includes Jeju Island.
- [ ] The map includes approximately 8–12 discoverable markers.
- [ ] Example markers include Đảo Jeju and Tháp Namsan.
- [ ] Markers support available, in-progress, completed, new, selected, and coming-soon states.
- [ ] Clicking a marker opens a useful destination preview.
- [ ] The homepage includes search, filters, progress, recommendations, and badges.
- [ ] Selecting a destination opens one reusable location template.
- [ ] A clear “Trở về bản đồ” control exists throughout the location journey.
- [ ] The exact nine-stage order is preserved.
- [ ] No separate “Nhiệm vụ” tab exists.
- [ ] The content stages use variables and field placeholders only.
- [ ] No stage is completed with real content for a specific location.
- [ ] History supports 4–6 generic milestones.
- [ ] Highlights support 4–6 generic sub-destinations.
- [ ] Culture supports 3–5 generic items.
- [ ] Food supports 3–6 generic items.
- [ ] Fun Facts support 4–6 generic cards.
- [ ] Quiz supports 10–15 dynamic tasks and several task types.
- [ ] Incorrect Quiz answers still complete tasks.
- [ ] Quiz result remains inside the Quiz stage.
- [ ] Travel information uses variables, sources, and update dates.
- [ ] Completing a location updates its homepage map marker and badge.
- [ ] The bright, cute, Korean-inspired pastel style is consistent.
- [ ] No theme-description or production-note text appears in the actual UI.
- [ ] Desktop, tablet, and mobile layouts are coherent.
- [ ] All user-facing interface copy is in Vietnamese.

Generate the complete high-fidelity KoreaQuest UI system now.

---

## OPTIONAL REFINEMENT PROMPT

Use this after Stitch creates the first version:

```text
Refine the current KoreaQuest UI without changing its architecture.

Make the South Korea map the visual focus of the homepage. Improve marker placement, map readability, destination preview cards, map/list switching, filters, discovery progress, and the transition from a selected marker into the location journey.

Preserve the bright pastel Korean travel style, rounded postcard cards, cute but subtle cultural decoration, and responsive layouts.

Keep every location stage generic. The homepage map may show real example place names, but the nine-stage destination template must use reusable variables and field placeholders only. Remove any factual content written specifically for Namsan, Jeju, Seoul, Busan, or another destination from the location stages.

Keep all Quiz tasks in the Quiz stage. Preserve the rule that incorrect answers reveal the correct answer and explanation but still complete the task. After a location is completed, update its map marker, overall progress, and badge collection.
```
