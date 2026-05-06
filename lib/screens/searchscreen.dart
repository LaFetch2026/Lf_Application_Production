// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/other/common_widget.dart';
import 'package:lafetch/common/widget/other/lf_loader_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/lists/dummy_catalog_list.dart';
import '../common/widget/lists/dummy_container.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/catalog_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/search_controller.dart';
import '../core/constant/constants.dart';
import '../screens/Brands/categoryproduct.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late SearchScreenController controller;
  late CatalogController _catalogController;
  late TabController _categoryTabController;
  final RxInt _selectedGenderId = 0.obs;

  final RxString _query = ''.obs;
  Timer? _debounceSuggest;

  static const _prefsKeyRecent = 'recent_search_list';
  final RxList<String> _recent = <String>[].obs;

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    _recent.assignAll(prefs.getStringList(_prefsKeyRecent) ?? const []);
  }

  Future<void> _saveRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKeyRecent, _recent);
  }

  void _addRecent(String q) {
    final query = q.trim();
    if (query.isEmpty) return;
    final idx =
        _recent.indexWhere((e) => e.toLowerCase() == query.toLowerCase());
    if (idx != -1) _recent.removeAt(idx);
    _recent.insert(0, query);
    if (_recent.length > 12) _recent.removeRange(12, _recent.length);
    _saveRecent();
  }

  void _removeRecentAt(int i) {
    if (i < 0 || i >= _recent.length) return;
    _recent.removeAt(i);
    _saveRecent();
  }

  void _clearAllRecent() {
    _recent.clear();
    _saveRecent();
  }

  List<Map<String, dynamic>> _normalizeSuggestions(
      Iterable<Map<String, dynamic>> raw, String query) {
    final out = <Map<String, dynamic>>[];
    final seen = <String>{};
    final q = query.trim();
    final qLower = q.toLowerCase();

    for (final item in raw) {
      final keyword = (item['keyword'] ?? '').toString().trim();
      if (keyword.isEmpty) continue;
      final key = keyword.toLowerCase();
      if (seen.contains(key)) continue;
      seen.add(key);
      out.add(item);
      if (out.length >= 10) break;
    }

    if (q.isNotEmpty &&
        !out.any(
            (e) => (e['keyword'] ?? '').toString().toLowerCase() == qLower)) {
      out.insert(0, {'keyword': q, 'count': 0});
    }
    return out;
  }

  void _onChanged(String value) {
    _query.value = value;
    _debounceSuggest?.cancel();

    if (value.trim().isEmpty) {
      controller.suggestions.clear();
      return;
    }

    _debounceSuggest = Timer(const Duration(milliseconds: 300), () {
      controller.getProductSuggestions();
    });
  }

  Future<void> _openResults(String keyword) async {
    final q = keyword.trim();
    if (q.isEmpty) return;
    _addRecent(q);
    FocusScope.of(context).unfocus();

    controller.searchController.text = q;
    controller.resetFilters();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: LfLoaderWidget(
        size: 48,
        brandColor: Colors.grey,
      )),
    );

    await controller.getSearchData();
    if (mounted) Navigator.of(context).pop();

    final items = controller.searchList;
    if (items.isEmpty) {
      getSnackBar("No product found");
      return;
    }

    Get.to(() => SearchResultsScreen(
          searchQuery: q,
          searchResults: items,
        ));
  }

  void _clearSearch() {
    controller.searchController.clear();
    _query.value = '';
    controller.suggestions.clear();
    FocusScope.of(context).unfocus();
  }

  // ---- Category tab handlers ----

  void _onCategoryTabChanged(int index) {
    final tabs = Get.find<HomeController>().genderTabs;
    if (index < 0 || index >= tabs.length) return;
    final tab = tabs[index];
    final int genderId = tab['id'] is int
        ? tab['id'] as int
        : int.tryParse(tab['id']?.toString() ?? '') ?? 1;
    _selectedGenderId.value = genderId;
    _catalogController.selectCategoryGender.value = genderId;
    _catalogController.categoryName.value = tab['name']?.toString() ?? '';
    _catalogController.getCatalogData(genderId);
    if (_categoryTabController.index != index) {
      _categoryTabController.animateTo(index);
    }
  }

  void _onCategorySwipe(DragEndDetails details) {
    const double sensitivity = 300;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > sensitivity) {
      // Swipe right → previous tab
      if (_categoryTabController.index > 0) {
        _onCategoryTabChanged(_categoryTabController.index - 1);
      }
    } else if (velocity < -sensitivity) {
      // Swipe left → next tab
      if (_categoryTabController.index < _categoryTabController.length - 1) {
        _onCategoryTabChanged(_categoryTabController.index + 1);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Safe registration: reuse existing instance if still alive, otherwise create fresh.
    if (Get.isRegistered<SearchScreenController>()) {
      controller = Get.find<SearchScreenController>();
    } else {
      controller = Get.put(SearchScreenController());
    }
    // Clear any stale text/state from a previous session so the field
    // starts empty and the query observable matches.
    controller.searchController.clear();
    controller.suggestions.clear();
    _query.value = '';

    // CatalogController lifecycle: reuse if registered, create otherwise.
    if (Get.isRegistered<CatalogController>()) {
      _catalogController = Get.find<CatalogController>();
    } else {
      _catalogController = Get.put(CatalogController());
    }

    final homeController = Get.find<HomeController>();
    final tabCount =
        homeController.genderTabs.isNotEmpty ? homeController.genderTabs.length : 1;
    _categoryTabController = TabController(length: tabCount, vsync: this);

    // Seed selected gender from first tab
    if (homeController.genderTabs.isNotEmpty) {
      final firstTab = homeController.genderTabs.first;
      final int firstId = firstTab['id'] is int
          ? firstTab['id'] as int
          : int.tryParse(firstTab['id']?.toString() ?? '') ?? 1;
      _selectedGenderId.value = firstId;
    }

    // Listen for genderTabs loading after screen open
    ever(homeController.genderTabs, (tabs) {
      if (tabs.isNotEmpty && mounted) {
        final newLength = tabs.length;
        if (_categoryTabController.length != newLength) {
          _categoryTabController.dispose();
          _categoryTabController =
              TabController(length: newLength, vsync: this);
          setState(() {});
        }
        // Seed selected gender if not yet set
        if (_selectedGenderId.value == 0) {
          final firstTab = tabs.first;
          final int firstId = firstTab['id'] is int
              ? firstTab['id'] as int
              : int.tryParse(firstTab['id']?.toString() ?? '') ?? 1;
          _selectedGenderId.value = firstId;
        }
      }
    });

    // Fetch catalog data if not already loaded
    final int defaultGenderId = homeController.genderTabs.isNotEmpty
        ? (homeController.genderTabs.first['id'] is int
            ? homeController.genderTabs.first['id'] as int
            : int.tryParse(
                    homeController.genderTabs.first['id']?.toString() ?? '') ??
                1)
        : 1;

    if (_catalogController.catalogList.isEmpty) {
      _catalogController.getCatalogData(defaultGenderId);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadRecent();
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        systemNavigationBarColor: statusBarColor,
      ));
    });
  }

  @override
  void dispose() {
    _debounceSuggest?.cancel();
    _categoryTabController.dispose();
    // Reset state but do NOT delete the controller — deleting it disposes
    // the TextEditingController inside it, which causes a "disposed
    // TextEditingController" crash the next time SearchScreen opens and
    // tries to reuse the same controller instance.
    controller.resetFilters();
    controller.suggestions.clear();
    _query.value = '';
    // Do NOT dispose CatalogController — cached data must persist.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            // ---------------- APP BAR AREA ----------------
            Container(
              color: statusBarColor,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(12.sp, 8.sp, 12.sp, 8.sp),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Get.back(),
                            child: SvgPicture.asset(
                              arrowBack,
                              height: 16.sp,
                              width: 16.sp,
                              fit: BoxFit.fill,
                            ),
                          ),
                          SizedBox(width: 8.sp),
                          Expanded(
                            child: SizedBox(
                              height: 36.sp,
                              child: TextField(
                                controller: controller.searchController,
                                textCapitalization: TextCapitalization.words,
                                maxLines: 1,
                                style: TextStyle(
                                  color: homeAppBarColor,
                                  fontFamily: "Clash Display Regular",
                                  fontSize: 14.sp,
                                ),
                                onChanged: _onChanged,
                                onSubmitted: _openResults,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  isDense: true,
                                  suffixIconConstraints: BoxConstraints(
                                    minHeight: 20.sp,
                                    minWidth: 20.sp,
                                  ),
                                  suffixIcon: Obx(() => _query.value.isNotEmpty
                                      ? IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: SvgPicture.asset(
                                            crossSearchImage,
                                            color: homeAppBarColor,
                                            height: 14.sp,
                                            width: 14.sp,
                                            fit: BoxFit.fill,
                                          ),
                                          onPressed: _clearSearch,
                                        )
                                      : const SizedBox.shrink()),
                                  filled: true,
                                  fillColor: statusBarColor,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10.sp, vertical: 8.sp),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: statusBarColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide:
                                        const BorderSide(color: statusBarColor),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  hintText: "Search to Explore More",
                                  hintStyle: const TextStyle(
                                    color: subtitleColor,
                                    fontSize: 14,
                                    fontFamily: "Clash Display Regular",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1, color: dividerColor),
                  ],
                ),
              ),
            ),

            // ---------------- BODY ----------------
            Expanded(
              child: Obx(() {
                final hasQuery = _query.value.isNotEmpty;
                final children = <Widget>[];

                if (hasQuery) {
                  if (controller.isSuggesting.value) {
                    children.add(_buildSuggestShimmer());
                  } else {
                    final terms = _normalizeSuggestions(
                      controller.suggestions,
                      _query.value,
                    );
                    if (terms.isNotEmpty) {
                      children.add(_buildSuggestionsList(terms));
                    }
                  }

                  if (_recent.isNotEmpty) {
                    if (children.isNotEmpty) {
                      children.add(Divider(
                        height: 1,
                        thickness: 0.6,
                        color: dividerColor,
                        indent: 16.sp,
                        endIndent: 16.sp,
                      ));
                    }
                    children.add(_buildRecentSection(compact: true));
                  }
                } else {
                  if (_recent.isNotEmpty) {
                    children.add(_buildRecentSection());
                  }
                  // Show category section when query is empty
                  children.add(_buildCategorySection());
                }

                return ListView(
                  padding: EdgeInsets.zero,
                  children: children,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(List<Map<String, dynamic>> terms) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.sp, 0, 16.sp, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(terms.length, (i) {
          final item = terms[i];
          final keyword = (item['keyword'] ?? '').toString();
          final count = item['count'] ?? 0;
          return Column(
            children: [
              InkWell(
                onTap: () => _openResults(keyword),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.sp),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: AppText(
                                text: "Search for '$keyword'",
                                maxLines: 1,
                                fontFamily: "Clash Display Regular",
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: homeAppBarColor,
                              ),
                            ),
                            if (count > 0)
                              Padding(
                                padding: EdgeInsets.only(left: 8.sp),
                                child: AppText(
                                  text: "($count)",
                                  fontFamily: "Clash Display Regular",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: subtitleColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      SvgPicture.asset(
                        arrowSearchImage,
                        color: homeAppBarColor,
                        height: 12.sp,
                        width: 12.sp,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                ),
              ),
              if (i < terms.length - 1) SizedBox(height: 2.sp),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSuggestShimmer() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.sp, 0, 16.sp, 8.sp),
      child: Column(
        children: List.generate(
          3,
          (i) => Padding(
            padding: EdgeInsets.symmetric(vertical: 4.sp),
            child: Row(
              children: [
                Expanded(child: DummyContainer(height: 14, width: 120)),
                SizedBox(width: 12.sp),
                DummyContainer(height: 12, width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------ CATEGORY SECTION ------------------
  Widget _buildCategorySection() {
    final homeController = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gender chip row
        Obx(() {
          final tabs = homeController.genderTabs;
          if (tabs.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: EdgeInsets.fromLTRB(12.sp, 12.sp, 12.sp, 8.sp),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final tab = tabs[index];
                  final int tabId = tab['id'] is int
                      ? tab['id'] as int
                      : int.tryParse(tab['id']?.toString() ?? '') ?? 0;
                  final String tabName = tab['name']?.toString() ?? '';
                  return Obx(() {
                    final isSelected = _selectedGenderId.value == tabId;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.sp),
                      child: GestureDetector(
                        onTap: () => _onCategoryTabChanged(index),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.sp, vertical: 8.sp),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? homeAppBarColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: homeAppBarColor,
                              width: 1,
                            ),
                          ),
                          child: AppText(
                            text: tabName.toUpperCase(),
                            fontFamily: 'Clash Display Semibold',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: isSelected ? whiteColor : homeAppBarColor,
                          ),
                        ),
                      ),
                    );
                  });
                }),
              ),
            ),
          );
        }),

        // Category list with swipe support
        GestureDetector(
          onHorizontalDragEnd: _onCategorySwipe,
          behavior: HitTestBehavior.translucent,
          child: Obx(() {
            if (_catalogController.isCatalog.value) {
              return const DummyCatalogList();
            }

            if (_catalogController.catalogList.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 40.sp),
                child: const Center(
                  child: AppText(
                    text: 'No Categories Found',
                    fontFamily: 'Clash Display Regular',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              );
            }

            return ListView.builder(
              primary: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                  horizontal: 16.sp, vertical: 8.sp),
              itemCount: _catalogController.catalogList.length,
              itemBuilder: (context, index) {
                final item = _catalogController.catalogList[index]
                    as Map<String, dynamic>;

                final int categoryId = item['id'] is int
                    ? item['id'] as int
                    : int.tryParse(
                            '${item['id'] ?? item['catId'] ?? item['categoryId']}') ??
                        0;

                final String categoryName =
                    (item['name'] ?? item['title'] ?? '').toString();

                return Container(
                  margin: EdgeInsets.only(bottom: 12.sp),
                  decoration: BoxDecoration(
                    color: whiteBack,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await _catalogController
                            .getSubCategoryProducts(categoryId);

                        if (!context.mounted) return;

                        Navigator.push(
                          context,
                          scaleIn(
                            CategoryProductScreen(
                              categoryName: categoryName,
                              screen: 'category',
                              genderName:
                                  _catalogController.categoryName.value,
                              categoryId: categoryId,
                              brandId: 0,
                              genderType: _catalogController
                                  .selectCategoryGender.value,
                              categoryList: const [],
                              collectionIds: const [],
                              title: '',
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(12.sp),
                        child: Row(
                          children: [
                            // Name + Explore hint
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: categoryName.toUpperCase(),
                                    fontFamily: 'Clash Display Semibold',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  SizedBox(height: 6.sp),
                                  Row(
                                    children: [
                                      AppText(
                                        text: 'Explore',
                                        fontFamily: 'Clash Display Regular',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: textHintColor,
                                      ),
                                      SizedBox(width: 4.sp),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 10.sp,
                                        color: textHintColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Category image
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      (item['image'] ?? '').toString(),
                                  width: 100.sp,
                                  height: 110.sp,
                                  fit: BoxFit.fill,
                                  fadeInDuration:
                                      const Duration(milliseconds: 200),
                                  placeholder: (_, __) => Container(
                                    width: 100.sp,
                                    height: 110.sp,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    width: 100.sp,
                                    height: 110.sp,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.category_outlined,
                                      size: 24,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // ------------------ RECENT ------------------
  Widget _buildRecentSection({bool compact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: compact ? 4.sp : 6.sp,
            left: 16.sp,
            right: 12.sp,
            bottom: 2.sp,
          ),
          child: Row(
            children: [
              const AppText(
                text: "Recent Searches",
                fontFamily: "Clash Display Semibold",
                fontWeight: FontWeight.w400,
                color: blackColor,
                fontSize: 16,
              ),
              const Spacer(),
              if (_recent.isNotEmpty)
                TextButton(
                  onPressed: _clearAllRecent,
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.sp, vertical: 0),
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const AppText(
                    text: "Clear all",
                    fontFamily: "Clash Display Regular",
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 4.sp),
          child: Obx(() => ListView.builder(
                primary: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recent.length,
                padding: EdgeInsets.zero,
                itemBuilder: (ctx, i) {
                  final text = _recent[i];
                  return InkWell(
                    onTap: () => _openResults(text),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.sp),
                      child: SizedBox(
                        height: 32.sp,
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    EdgeInsets.only(left: 16.sp, right: 8.sp),
                                child: AppText(
                                  text: text,
                                  maxLines: 1,
                                  color: appBarColor,
                                  fontSize: 14.sp,
                                  fontFamily: "Clash Display Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(
                                minHeight: 24.sp,
                                minWidth: 24.sp,
                              ),
                              icon: SvgPicture.asset(
                                crossSearchImage,
                                color: subtitleColor,
                                height: 12.sp,
                                width: 12.sp,
                                fit: BoxFit.fill,
                              ),
                              onPressed: () => _removeRecentAt(i),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )),
        ),
      ],
    );
  }
}
