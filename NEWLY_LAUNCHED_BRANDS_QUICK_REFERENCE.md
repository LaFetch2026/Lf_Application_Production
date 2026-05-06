# Newly Launched Brands - Quick Reference

## What Was Built

A new "NEWLY LAUNCHED BRANDS" section on the home screen that displays newly launched brands in a horizontal carousel with pagination support.

## Key Files Modified

1. **`lib/controllers/brand_controller.dart`**
   - Added state variables for newly launched brands
   - Added `getNewlyLaunchedBrands()` method
   - Added `nextNewlyLaunchedPage()` and `prevNewlyLaunchedPage()` methods

2. **`lib/screens/home/women/homescreen.dart`**
   - Added newly launched brands fetch to initialization
   - Added newly launched brands fetch to force refresh
   - Added `_NewlyLaunchedBrandsSection` widget
   - Inserted section after "NEW IN" section

## How It Works

### Data Flow
```
HomeScreen Init
    ↓
brandController.getNewlyLaunchedBrands(gender: currentGender)
    ↓
API: GET /brands?sort=new&page=1&limit=20&gender={gender}
    ↓
Response: { data: [...], pagination: {...} }
    ↓
Update: newlyLaunchedBrands, newlyLaunchedPage, newlyLaunchedTotalPages
    ↓
UI: _NewlyLaunchedBrandsSection renders brands
```

### Pagination Flow
```
User taps "Next" button
    ↓
brandController.nextNewlyLaunchedPage()
    ↓
getNewlyLaunchedBrands(page: currentPage + 1)
    ↓
API: GET /brands?sort=new&page=2&limit=20&gender={gender}
    ↓
Response: { data: [...], pagination: {...} }
    ↓
Update: newlyLaunchedBrands (append), newlyLaunchedPage = 2
    ↓
UI: Carousel updates with new brands
```

## State Variables

```dart
// In BrandController
RxList<Map<String, dynamic>> newlyLaunchedBrands = [];
RxBool isLoadingNewlyLaunched = false;
RxInt newlyLaunchedPage = 1;
RxInt newlyLaunchedTotalPages = 1;
RxBool hasMoreNewlyLaunched = true;
```

## Methods

### `getNewlyLaunchedBrands()`
```dart
await brandController.getNewlyLaunchedBrands(
  page: 1,
  limit: 20,
  gender: 2,  // optional
  showLoader: true,
);
```

### `nextNewlyLaunchedPage()`
```dart
await brandController.nextNewlyLaunchedPage();
```

### `prevNewlyLaunchedPage()`
```dart
await brandController.prevNewlyLaunchedPage();
```

## UI Structure

```
┌─────────────────────────────────────────┐
│ JUST IN                                 │
│ NEWLY LAUNCHED BRANDS        [◀] [▶]   │
├─────────────────────────────────────────┤
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐   │
│ │ Logo │ │ Logo │ │ Logo │ │ Logo │   │
│ │Brand1│ │Brand2│ │Brand3│ │Brand4│   │
│ └──────┘ └──────┘ └──────┘ └──────┘   │
└─────────────────────────────────────────┘
```

## API Contract

### Request
```
GET /brands?status=true&sort=new&page=1&limit=20&gender=2
Authorization: Bearer {token}
```

### Response
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

## Error Handling

| Error | Behavior |
|-------|----------|
| Timeout | Show snackbar, prevent UI freeze |
| No Internet | Show snackbar, graceful degradation |
| Auth Failed (401) | Redirect to login |
| Other Error | Show snackbar, log error |

## Analytics Events

```dart
// Logged when user taps a brand
{
  "name": "newly_launched_brand_tap",
  "parameters": {
    "brand_id": 123,
    "brand_name": "Brand Name",
    "page": 1
  }
}
```

## Performance Notes

- ✅ Pagination prevents loading all brands at once
- ✅ Caching prevents duplicate API calls
- ✅ Skeleton loaders provide visual feedback
- ✅ WebP image optimization reduces bandwidth
- ✅ Horizontal scroll is smooth and responsive

## Common Tasks

### Fetch newly launched brands on init
```dart
await brandController.getNewlyLaunchedBrands(gender: currentGender);
```

### Go to next page
```dart
await brandController.nextNewlyLaunchedPage();
```

### Go to previous page
```dart
await brandController.prevNewlyLaunchedPage();
```

### Check if loading
```dart
if (brandController.isLoadingNewlyLaunched.value) {
  // Show loading state
}
```

### Check if brands available
```dart
if (brandController.newlyLaunchedBrands.isEmpty) {
  // No brands to show
}
```

### Get current page info
```dart
final page = brandController.newlyLaunchedPage.value;
final totalPages = brandController.newlyLaunchedTotalPages.value;
final canGoNext = page < totalPages;
final canGoPrev = page > 1;
```

## Debugging

### Enable debug logs
All methods print debug info:
```
➡️ Newly Launched Brands API URL: ...
⬅️ Status Code: 200
✅ Newly launched brands loaded: 20 brands (page 1 of 5)
🪪 Brand names: [Brand1, Brand2, Brand3, Brand4, Brand5]...
```

### Check state in UI
```dart
Obx(() {
  print('Loading: ${brandController.isLoadingNewlyLaunched.value}');
  print('Brands: ${brandController.newlyLaunchedBrands.length}');
  print('Page: ${brandController.newlyLaunchedPage.value}');
});
```

## Troubleshooting

### Brands not showing
1. Check if API returns data
2. Verify gender parameter is correct
3. Check if `isLoadingNewlyLaunched` is stuck true
4. Check network connectivity

### Pagination not working
1. Verify `newlyLaunchedTotalPages` is > 1
2. Check if page buttons are enabled
3. Verify API returns pagination metadata
4. Check console for errors

### Images not loading
1. Verify logo URLs are valid
2. Check if ImageHelper.toWebP() works
3. Verify image cache is not full
4. Check network connectivity

## Next Steps

1. Test on different devices
2. Monitor analytics events
3. Gather user feedback
4. Consider infinite scroll enhancement
5. Add filtering/sorting options
