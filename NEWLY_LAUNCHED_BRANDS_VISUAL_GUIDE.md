# Newly Launched Brands - Visual Guide

## Screen Layout

```
┌─────────────────────────────────────────────────────────┐
│                    HOME SCREEN                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [Gender Tabs: MEN | WOMEN | ACCESSORIES]              │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │         Section Video Banner                    │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  | More than 50+ Homegrown Brands | Fast...    │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ NEW IN                                          │   │
│  │ [Product Grid - 2 columns, 8 items]             │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ JUST IN                                         │   │
│  │ NEWLY LAUNCHED BRANDS          [◀] [▶]         │   │
│  │ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐            │   │
│  │ │ Logo │ │ Logo │ │ Logo │ │ Logo │            │   │
│  │ │Brand1│ │Brand2│ │Brand3│ │Brand4│            │   │
│  │ └──────┘ └──────┘ └──────┘ └──────┘            │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ SHOP BY CATEGORY                               │   │
│  │ [Category Grid]                                 │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ FEATURED BRANDS                                 │   │
│  │ [Brand Grid]                                    │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Brand Card Detail

```
┌──────────────────┐
│                  │
│   [Brand Logo]   │  ← 60sp height, 80sp width
│                  │
├──────────────────┤
│  Brand Name      │  ← Max 2 lines, truncated
│  (if long)       │
└──────────────────┘
  ↑
  └─ Tap to navigate to brand details
```

## Pagination Flow

### Page 1 (Initial Load)
```
API: GET /brands?sort=new&page=1&limit=20&gender=2
Response: 20 brands, totalPages=5, hasNextPage=true

UI:
NEWLY LAUNCHED BRANDS        [◀ disabled] [▶ enabled]
[Brand1] [Brand2] [Brand3] [Brand4] ...
```

### Page 2 (After Next Click)
```
API: GET /brands?sort=new&page=2&limit=20&gender=2
Response: 20 brands, totalPages=5, hasNextPage=true

UI:
NEWLY LAUNCHED BRANDS        [◀ enabled] [▶ enabled]
[Brand21] [Brand22] [Brand23] [Brand24] ...
```

### Last Page
```
API: GET /brands?sort=new&page=5&limit=20&gender=2
Response: 10 brands, totalPages=5, hasNextPage=false

UI:
NEWLY LAUNCHED BRANDS        [◀ enabled] [▶ disabled]
[Brand81] [Brand82] ... [Brand90]
```

## Loading State

```
┌─────────────────────────────────────────┐
│ ┌─────────────────────────────────────┐ │
│ │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │ │
│ │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │ │
│ │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │ │
│ └─────────────────────────────────────┘ │
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐    │
│ │▓▓▓▓▓▓│ │▓▓▓▓▓▓│ │▓▓▓▓▓▓│ │▓▓▓▓▓▓│    │
│ │▓▓▓▓▓▓│ │▓▓▓▓▓▓│ │▓▓▓▓▓▓│ │▓▓▓▓▓▓│    │
│ │▓▓▓▓▓▓│ │▓▓▓▓▓▓│ │▓▓▓▓▓▓│ │▓▓▓▓▓▓│    │
│ └──────┘ └──────┘ └──────┘ └──────┘    │
└─────────────────────────────────────────┘
```

## Empty State

```
┌─────────────────────────────────────────┐
│                                         │
│  (Section is hidden - no space taken)   │
│                                         │
└─────────────────────────────────────────┘
```

## Error States

### Timeout Error
```
┌─────────────────────────────────────────┐
│ ⚠️ Request timed out. Please try again. │
└─────────────────────────────────────────┘
```

### No Internet
```
┌─────────────────────────────────────────┐
│ ⚠️ No internet connection.               │
│    Please check your network.            │
└─────────────────────────────────────────┘
```

### Auth Failed
```
┌─────────────────────────────────────────┐
│ ⚠️ Session expired. Please log in again.│
│    [Redirects to login screen]          │
└─────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌──────────────────────────────────────────────────────────┐
│                   HomeScreen Init                        │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│  brandController.getNewlyLaunchedBrands(gender: 2)      │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│  API: GET /brands?sort=new&page=1&limit=20&gender=2    │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│  Response: { data: [...], pagination: {...} }           │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│  Update State:                                           │
│  - newlyLaunchedBrands = [...]                          │
│  - newlyLaunchedPage = 1                                │
│  - newlyLaunchedTotalPages = 5                          │
│  - isLoadingNewlyLaunched = false                       │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│  UI: _NewlyLaunchedBrandsSection renders                │
└──────────────────────────────────────────────────────────┘
```

## Pagination Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│  User taps "Next" button                                │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  brandController.nextNewlyLaunchedPage()                │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  Check: currentPage (1) < totalPages (5)?               │
│  Yes → Proceed                                          │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  getNewlyLaunchedBrands(page: 2, showLoader: false)    │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  API: GET /brands?sort=new&page=2&limit=20&gender=2   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  Response: { data: [...], pagination: {...} }          │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  Update State:                                          │
│  - newlyLaunchedBrands.addAll([...])  (append)         │
│  - newlyLaunchedPage = 2                               │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  UI: Carousel updates with new brands                  │
└─────────────────────────────────────────────────────────┘
```

## State Machine

```
                    ┌─────────────────┐
                    │   INITIAL       │
                    │ (No data)       │
                    └────────┬────────┘
                             │
                             ↓
                    ┌─────────────────┐
                    │   LOADING       │
                    │ (Fetching data) │
                    └────────┬────────┘
                             │
                ┌────────────┴────────────┐
                ↓                         ↓
        ┌──────────────┐         ┌──────────────┐
        │   SUCCESS    │         │    ERROR     │
        │ (Data ready) │         │ (Show error) │
        └──────┬───────┘         └──────┬───────┘
               │                        │
               └────────────┬───────────┘
                            ↓
                    ┌─────────────────┐
                    │   READY         │
                    │ (Show content)  │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    ↓                 ↓
            ┌──────────────┐  ┌──────────────┐
            │ NEXT PAGE    │  │ PREV PAGE    │
            │ (Loading)    │  │ (Loading)    │
            └──────┬───────┘  └──────┬───────┘
                   │                 │
                   └────────┬────────┘
                            ↓
                    ┌─────────────────┐
                    │   READY         │
                    │ (Updated data)  │
                    └─────────────────┘
```

## Component Hierarchy

```
HomeScreen
├── _SectionVideoBanner
├── _AnnouncementMarquee
├── _NewInSection
│   ├── Loading State (Skeleton)
│   ├── Product Grid (2 columns)
│   └── Navigation Buttons
├── _ShopByCategorySection
├── _FeaturedBrandsRow
├── _NewlyLaunchedBrandsSection  ← NEW
│   ├── Loading State (Skeleton)
│   ├── Header
│   │   ├── Subtitle: "JUST IN"
│   │   ├── Title: "NEWLY LAUNCHED BRANDS"
│   │   └── Navigation Buttons
│   └── Brand Carousel
│       └── Brand Cards (Logo + Name)
└── Other Sections...
```

## Responsive Design

### Mobile (360px)
```
┌──────────────────────────────┐
│ JUST IN                      │
│ NEWLY LAUNCHED BRANDS [◀][▶] │
│ ┌────┐ ┌────┐ ┌────┐ ┌────┐ │
│ │Logo│ │Logo│ │Logo│ │Logo│ │
│ │B1  │ │B2  │ │B3  │ │B4  │ │
│ └────┘ └────┘ └────┘ └────┘ │
└──────────────────────────────┘
```

### Tablet (768px)
```
┌────────────────────────────────────────────────────┐
│ JUST IN                                            │
│ NEWLY LAUNCHED BRANDS                    [◀] [▶]  │
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐     │
│ │ Logo │ │ Logo │ │ Logo │ │ Logo │ │ Logo │     │
│ │Brand1│ │Brand2│ │Brand3│ │Brand4│ │Brand5│     │
│ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘     │
└────────────────────────────────────────────────────┘
```

## Color Scheme

- **Subtitle "JUST IN"**: `#6B7280` (Gray)
- **Title "NEWLY LAUNCHED BRANDS"**: `#000000` (Black)
- **Brand Card Border**: `#E5E7EB` (Light Gray)
- **Brand Card Background**: `#FFFFFF` (White)
- **Navigation Button (Enabled)**: `#000000` (Black)
- **Navigation Button (Disabled)**: `#9CA3AF` (Gray)
- **Loading Skeleton**: `rgba(0, 0, 0, 0.04)` (Light Gray)

## Typography

- **Subtitle**: Clash Display Regular, 12sp, Gray
- **Title**: Clash Display Semibold, 18sp, Black
- **Brand Name**: Clash Display Regular, 10sp, Black

## Spacing

- **Section Padding**: 16sp horizontal
- **Header to Carousel**: 12sp
- **Between Brands**: 12sp
- **Section Bottom**: 16sp
- **Section Top**: 16sp (from NEW IN section)
