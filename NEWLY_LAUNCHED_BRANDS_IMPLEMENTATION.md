# Newly Launched Brands Implementation

## Overview
Implemented a new "NEWLY LAUNCHED BRANDS" section in the home screen that displays newly launched brands with proper pagination, state management, and clean data contracts.

## Changes Made

### 1. BrandController Updates (`lib/controllers/brand_controller.dart`)

#### New State Variables
```dart
/// ✅ Newly Launched Brands state
RxList<Map<String, dynamic>> newlyLaunchedBrands = <Map<String, dynamic>>[].obs;
RxBool isLoadingNewlyLaunched = false.obs;
RxInt newlyLaunchedPage = 1.obs;
RxInt newlyLaunchedTotalPages = 1.obs;
RxBool hasMoreNewlyLaunched = true.obs;
```

#### New Methods

**`getNewlyLaunchedBrands()`** - Fetches newly launched brands with pagination
- Parameters: `page`, `limit`, `gender`, `showLoader`
- Uses `sort=new` query parameter to get newly launched brands
- Handles pagination metadata from backend
- Proper error handling (timeout, socket, auth)
- Caches pagination state

**`nextNewlyLaunchedPage()`** - Navigate to next page
- Increments page and fetches new data
- Respects total pages limit

**`prevNewlyLaunchedPage()`** - Navigate to previous page
- Decrements page and fetches new data
- Prevents going below page 1

### 2. HomeScreen Updates (`lib/screens/home/women/homescreen.dart`)

#### Initialization
Added newly launched brands fetch to the initial data load:
```dart
await Future.wait([
  catalogController.getCatalogData(currentGender, forceRefresh: isFirstLoad),
  productController.getHomeProduct(currentGender, forceRefresh: isFirstLoad),
  productController.getCollectionBanners(forceRefresh: isFirstLoad),
  brandController.getBrandData("featured", currentGender),
  brandController.getNewlyLaunchedBrands(gender: currentGender),  // ✅ NEW
]);
```

#### Force Refresh
Added newly launched brands to the refresh data:
```dart
await Future.wait([
  homeController.initializeHomeData(currentGender, forceRefresh: true),
  catalogController.getCatalogData(currentGender, forceRefresh: true),
  productController.getHomeProduct(currentGender, forceRefresh: true),
  productController.getCollectionBanners(forceRefresh: true),
  brandController.getBrandData("featured", currentGender),
  brandController.getNewlyLaunchedBrands(gender: currentGender),  // ✅ NEW
  homeController.getAnnouncements(forceRefresh: true),
  newInController.fetchProducts(currentGender, forceRefresh: true),
]);
```

#### UI Section
Added `_NewlyLaunchedBrandsSection` widget right after the "NEW IN" section:
```dart
// ── NEWLY LAUNCHED BRANDS Section ──────────────────────────────
_NewlyLaunchedBrandsSection(
  brandController: brandController,
  analytics: analytics,
),
```

### 3. New Widget: `_NewlyLaunchedBrandsSection`

#### Features
- **Subtitle**: "JUST IN" (regular font, gray color)
- **Title**: "NEWLY LAUNCHED BRANDS" (bold font, black color)
- **Horizontal Carousel**: Scrollable list of brand cards
- **Pagination Controls**: Previous/Next navigation buttons
- **Loading State**: Skeleton loaders while fetching
- **Empty State**: Hides section if no brands available
- **Brand Cards**: Display logo, brand name, and tap interaction
- **Analytics**: Logs brand tap events with brand ID and page info

#### Brand Card Features
- Brand logo with fallback icon
- Brand name (truncated to 2 lines)
- Tap to navigate to brand details screen
- Border styling with consistent spacing
- Error handling for missing images

#### Navigation
- Previous button disabled on page 1
- Next button disabled on last page
- Smooth pagination without data duplication
- Maintains page state during navigation

## Data Contract

### API Endpoint
```
GET /brands?status=true&sort=new&page={page}&limit={limit}&gender={gender}
```

### Response Structure
```json
{
  "data": [
    {
      "id": 1,
      "name": "Brand Name",
      "logo": "https://...",
      "status": true
    }
  ],
  "pagination": {
    "totalPages": 5,
    "hasNextPage": true,
    "currentPage": 1,
    "limit": 20
  }
}
```

## State Management

### Reactive State
- `newlyLaunchedBrands`: List of brand objects
- `isLoadingNewlyLaunched`: Loading indicator
- `newlyLaunchedPage`: Current page number
- `newlyLaunchedTotalPages`: Total pages available
- `hasMoreNewlyLaunched`: Whether more pages exist

### Pagination Logic
- **First Page**: Clears and replaces data
- **Subsequent Pages**: Appends new data
- **Page Validation**: Respects total pages limit
- **Error Handling**: Shows snackbar on failure, silently uses cache on timeout

## Error Handling

### Timeout Exception
- Shows snackbar: "Request timed out. Please try again."
- Prevents UI freeze

### Socket Exception
- Shows snackbar: "No internet connection. Please check your network."
- Graceful degradation

### Auth Exception (401)
- Shows snackbar: "Session expired. Please log in again."
- Redirects to login screen

### Other Errors
- Shows snackbar: "Something went wrong while fetching brands."
- Logs error details for debugging

## Performance Considerations

1. **Pagination**: Prevents loading all brands at once
2. **Caching**: Stores pagination state to avoid duplicate requests
3. **Lazy Loading**: Only fetches when needed
4. **Skeleton Loaders**: Provides visual feedback during loading
5. **Image Optimization**: Uses WebP format via ImageHelper
6. **Memory Management**: Limits carousel items to prevent overflow

## Testing Checklist

- [ ] Newly launched brands load on home screen
- [ ] Pagination controls work (next/prev buttons)
- [ ] Brand cards display correctly with logos
- [ ] Tap on brand navigates to brand details
- [ ] Loading state shows skeleton loaders
- [ ] Empty state hides section when no brands
- [ ] Error handling works (timeout, no internet, auth)
- [ ] Analytics events log correctly
- [ ] Pull-to-refresh updates newly launched brands
- [ ] Gender switching updates brands correctly
- [ ] Pagination state persists during navigation

## Future Enhancements

1. **Infinite Scroll**: Replace pagination with infinite scroll
2. **Filtering**: Add sort options (popularity, rating, etc.)
3. **Favorites**: Allow users to favorite brands
4. **Search**: Add search within newly launched brands
5. **Animations**: Add entrance animations for brand cards
6. **Caching**: Implement local database caching for offline support
