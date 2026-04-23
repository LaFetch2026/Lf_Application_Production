// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/other/common_widget.dart';
import 'package:lafetch/common/widget/other/lf_loader_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/lists/dummy_container.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/search_controller.dart';
import '../core/constant/constants.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final controller = Get.put(SearchScreenController());
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

  @override
  void initState() {
    super.initState();
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
    controller.resetFilters();
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
                }

                // Add category images at the end of content (scrollable)
                children.add(_buildCategorySection());

                // ✅ No top padding — flush under divider
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
      // ✅ start exactly under divider, no gap
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
              if (i < terms.length - 1)
                SizedBox(height: 2.sp), // same spacing as before
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSuggestShimmer() {
    return Padding(
      // ✅ no top padding
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

  // ------------------ CATEGORY SECTION (Static, non-clickable) ------------------
  Widget _buildCategorySection() {
    final categories = [
      {'image': 'assets/images/WOMEN.png'},
      {'image': 'assets/images/MEN.png'},
      {'image': 'assets/images/ACCESSORIES.png'},
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(12.sp, 8.sp, 12.sp, 8.sp),
      color: whiteColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: categories.map((category) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.sp),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  category['image']!,
                  height: 80.sp,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
