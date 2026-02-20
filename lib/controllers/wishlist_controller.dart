// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:lafetch/controllers/base_controller.dart';
import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/loginscreen.dart';

/// Endpoints used by the new wishlist API.
class ApiEndpoints {
  static String boardsByUser(int userId) =>
      "${ApiConstants.baseUrl}/wishlist-board/$userId";

  static String board(int boardId) =>
      "${ApiConstants.baseUrl}/wishlist-board/$boardId";

  static String createBoard() => "${ApiConstants.baseUrl}/wishlist-board";

  static String boardProducts(int boardId) =>
      "${ApiConstants.baseUrl}/board-products/$boardId";

  static String boardProductMutate() => "${ApiConstants.baseUrl}/board-product";
}

dynamic _safeJsonDecode(String body) {
  try {
    return jsonDecode(body);
  } catch (_) {
    final peek = body.substring(0, body.length > 200 ? 200 : body.length);
    print("⚠️ Not JSON (peek): $peek");
    return null;
  }
}

class WishlistController extends BaseController {
  // ------------------ reactive state (core) ------------------
  final isLoading = false.obs;
  final isDetails = false.obs;

  // New API data stores
  final wishlistList = <Map<String, dynamic>>[].obs; // boards
  final boardProducts = <Map<String, dynamic>>[].obs; // products for a board
  final wishListProduct = <Map<String, dynamic>>[].obs; // alias used by UI

  final wishlistCount = 0.obs;
  final totalBoard = 0.obs;

  // PDP/heart helpers
  final isHeartLoading = false.obs;
  final isWishlisted = false.obs;
  // Some parts of UI read this map directly
  final wishListDetails = <String, dynamic>{"wishlisted": false}.obs;

  // ------------------ UI helpers (compat with existing screens) ------------------
  final wishlistListController = ScrollController();
  final productListController = ScrollController();

  // paging toggles used in UI (even if you don't page on API)
  final hasnextpage = true.obs;
  final loadMore = false.obs;
  final isWishlist = false.obs;
  final page = 1.obs;
  final productPage = 1.obs;

  // selection buffers for “Edit Board / Add items”
  final selected = <bool>[].obs;
  final addList = <dynamic>[].obs;
  final deleteidList = <dynamic>[].obs;
  final deleteId = <int>[].obs;
  final addItem = 0.obs;

  // board creation/rename inputs
  final boardNameController = TextEditingController();
  final boardError = ''.obs;

  int defaultBoardId = 0;

  @override
  void onInit() {
    super.onInit();
    // hook for future paging if needed
    wishlistListController.addListener(() {
      if (!wishlistListController.hasClients) return;
      final pos = wishlistListController.position;
      if (pos.pixels >= pos.maxScrollExtent - 16 &&
          hasnextpage.value &&
          !loadMore.value) {
        // no-op for now (API not paged)
      }
    });
  }

  // ------------------ validation helpers ------------------
  bool checkIdvalidation() => addItem.value > 0;

  bool checkIdNamevalidation(String name) {
    final n = name.trim();
    if (n.isEmpty) {
      boardError.value = "Please enter board name";
      return false;
    }
    if (n.length < 3) {
      boardError.value = "Board name must be at least 3 characters";
      return false;
    }
    boardError.value = "";
    return true;
  }

  /// Check if a product exists in any wishlist board
  Future<void> checkIfWishlisted(int productId) async {
    isHeartLoading.value = true;
    try {
      // First ensure we have the latest boards
      if (wishlistList.isEmpty) {
        await fetchBoards();
      }

      // Check each board for the product
      bool found = false;
      for (var board in wishlistList) {
        final boardId = board['id'] as int?;
        if (boardId == null) continue;

        // Fetch products for this board silently (don't update UI)
        final products = await fetchBoardProducts(boardId, silent: true);

        // Check if product exists in this board
        if (products.any((p) {
          final prod = p['product'] as Map<String, dynamic>?;
          final id = prod?['id'];
          return id != null && id.toString() == productId.toString();
        })) {
          found = true;
          break;
        }
      }

      isWishlisted.value = found;
      wishListDetails["wishlisted"] = found;
      print("✅ Product $productId wishlisted: $found");
    } catch (e) {
      print("❌ checkIfWishlisted error: $e");
      isWishlisted.value = false;
      wishListDetails["wishlisted"] = false;
    } finally {
      isHeartLoading.value = false;
    }
  }

  // ------------------ auth & request helpers ------------------
  Future<Map<String, dynamic>?> _auth() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");
    final token = prefs.getString("token") ?? '';
    // if (userId == null || token.isEmpty) {
    //   getSnackBar("User not logged in.");
    //   Get.offAll(() => const LoginScreen(initialTab: 0));
    //   return null;
    // }
    return {"userId": userId, "token": token};
  }

  Map<String, String> _headers(String token, {bool json = false}) => {
        'Accept': 'application/json',
        if (json) 'Content-Type': 'application/json',
        'Authorization': "Bearer $token",
      };

  String _serverMessage(http.Response r,
      {String fallback = "Request failed."}) {
    final d = _safeJsonDecode(r.body);
    if (d is Map && d['message'] != null) return d['message'].toString();
    return fallback;
  }

  // Normalize product structure for UI (esp. images)
  /// Convert API rows like {"id": ..., "product": {...}} into a flat product map
  Map<String, dynamic> _normalizeProduct(Map<String, dynamic> row) {
    // row is {"id": <boardItemId>, "product": {...}}
    final p = Map<String, dynamic>.from(row['product'] ?? const {});

    List<Map<String, dynamic>> wrapImages(dynamic imgs) {
      final out = <Map<String, dynamic>>[];
      if (imgs is List) {
        for (final it in imgs) {
          final url = (it ?? '').toString().trim();
          if (url.isNotEmpty) out.add({"name": url});
        }
      } else if (imgs is String && imgs.trim().isNotEmpty) {
        out.add({"name": imgs.trim()});
      }
      return out;
    }

    // ⚠️ Important: we DON'T have variant inventory here → assume available.
    // If later you add an endpoint to fetch variants, fill this properly.
    final bool inStock = true;

    return {
      "boardItemId": row["id"],
      "product": {
        "id": p["id"],
        "name": (p["title"] ?? p["name"] ?? "").toString(),
        "brand_name": () {
          final b = p["brand_name"] ?? p["brand"];
          if (b is Map) return (b["name"] ?? "").toString();
          return (b ?? "").toString();
        }(),
        "price": p["basePrice"] ?? p["price"] ?? 0,
        "mrp": p["mrp"] ?? 0,
        "images": wrapImages(p["imageUrls"] ?? p["images"]),
        // keep this separate from availability — don't use p["status"]
        "wishlisted": true, // it’s on a board
      },
      // Provide an "inventory" shape your UI already understands
      "inventory": {
        "id": null,
        "stocks": inStock ? 1 : 0,
        "product_matrix_name_size": "",
      },
      "quantity": 1,
    };
  }

  // ======================================================
  // ===============  BOARDS (LIST/CRUD)  =================
  // ======================================================

  /// GET /wishlist-board/{userId}
  Future<void> fetchBoards() async {
    final auth = await _auth();
    if (auth == null) return;

    final userId = auth['userId'];
    if (userId == null) return; // Guest users don't have boards

    final token = auth['token'] as String;

    isLoading.value = true;
    try {
      final resp = await http.get(
        Uri.parse(ApiEndpoints.boardsByUser(userId)),
        headers: _headers(token),
      );

      final decoded = _safeJsonDecode(resp.body);

      if (resp.statusCode == 200 && decoded != null) {
        final List data = decoded['data'] is List ? decoded['data'] : [];

        final boards = data.map<Map<String, dynamic>>((e) {
          final item = Map<String, dynamic>.from(e);

          // Normalize productCount to int
          item['productCount'] =
              int.tryParse(item['productCount']?.toString() ?? "0") ?? 0;

          // Normalize thumbnail (replace null with empty string)
          item['thumbnail'] = item['thumbnail'] ?? "";

          return item;
        }).toList();

        wishlistList.assignAll(boards);
        totalBoard.value = boards.length;
        isWishlist.value = false;

        print("✅ Boards loaded: ${boards.length}");
      } else {
        wishlistList.clear();
        totalBoard.value = 0;
        print("❌ fetchBoards ${resp.statusCode} ${resp.reasonPhrase}");
        getSnackBar(_serverMessage(resp, fallback: "Failed to load boards."));
      }
    } catch (e) {
      wishlistList.clear();
      totalBoard.value = 0;
      print("❗ fetchBoards error: $e");
      getSnackBar("Something went wrong.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Alias for older code
  Future<void> listBoardsForUser() => fetchBoards();

  /// POST /wishlist-board  {userId, name}
  Future<void> createBoard(String name) async {
    if (!checkIdNamevalidation(name)) return;

    final auth = await _auth();
    if (auth == null) return;

    final userId = auth['userId'];
    if (userId == null) return; // Guest users can't create boards

    final token = auth['token'] as String;

    showLoading();
    try {
      final resp = await http.post(
        Uri.parse(ApiEndpoints.createBoard()),
        headers: _headers(token, json: true),
        body: jsonEncode({"userId": userId, "name": name.trim()}),
      );

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        getSnackBar("✅ Board created.");
        await fetchBoards();
      } else {
        getSnackBar(_serverMessage(resp, fallback: "Failed to create board."));
      }
    } catch (e) {
      print("createBoard error: $e");
      getSnackBar("Something went wrong.");
    } finally {
      hideLoading();
    }
  }

  /// PUT /wishlist-board/{boardId} {name}
  Future<void> renameBoard(int boardId, String newName) async {
    final auth = await _auth();
    if (auth == null) return;

    final token = auth['token'] as String;

    showLoading();
    try {
      final resp = await http.put(
        Uri.parse(ApiEndpoints.board(boardId)),
        headers: _headers(token, json: true),
        body: jsonEncode({"name": newName}),
      );

      if (resp.statusCode == 200) {
        getSnackBar("✅ Board renamed.");
        await fetchBoards();
      } else {
        getSnackBar(_serverMessage(resp, fallback: "Failed to rename board."));
      }
    } catch (e) {
      print("renameBoard error: $e");
      getSnackBar("Something went wrong.");
    } finally {
      hideLoading();
    }
  }

  /// DELETE /wishlist-board/{boardId}
  Future<bool> deleteBoard(int boardId) async {
    final auth = await _auth();
    if (auth == null) return false;

    final token = auth['token'] as String;

    showLoading();
    try {
      final resp = await http.delete(
        Uri.parse(ApiEndpoints.board(boardId)),
        headers: _headers(token),
      );

      final ok = resp.statusCode == 200 || resp.statusCode == 204;
      if (ok) {
        getSnackBar("✅ Board deleted.");
        // Do NOT fetch here automatically; caller usually handles navigation then refresh.
        return true;
      } else {
        final peek = resp.body.isNotEmpty
            ? resp.body
                .substring(0, resp.body.length > 200 ? 200 : resp.body.length)
            : '';
        print("❌ deleteBoard ${resp.statusCode} $peek");
        getSnackBar("Failed to delete board. (${resp.statusCode})");
        return false;
      }
    } catch (e) {
      print("deleteBoard error: $e");
      getSnackBar("Something went wrong.");
      return false;
    } finally {
      hideLoading();
    }
  }

  // ======================================================
  // ================= BOARD PRODUCTS =====================
  // ======================================================

  /// GET /board-products/{boardId}
  Future<List<Map<String, dynamic>>> fetchBoardProducts(int boardId,
      {bool silent = false}) async {
    print("📤 GET ${ApiEndpoints.boardProducts(boardId)}");
    final auth = await _auth();
    if (auth == null) return [];

    final token = auth['token'] as String;
    isLoading.value = true;

    try {
      final resp = await http.get(
        Uri.parse(ApiEndpoints.boardProducts(boardId)),
        headers: _headers(token),
      );

      final decoded = _safeJsonDecode(resp.body);
      if (resp.statusCode == 200 && decoded != null) {
        final list =
            decoded is List ? decoded : (decoded['data'] as List? ?? const []);

        final mapped = List<Map<String, dynamic>>.from(list.map((e) {
          final m = _normalizeProduct(Map<String, dynamic>.from(e));

          final product = Map<String, dynamic>.from((m["product"] ?? const {}));
          product["price"] = product["price"] ??
              product["basePrice"] ??
              product["sellingAmount"] ??
              0;
          final mrp = product["mrp"];
          product["mrp"] = (mrp is num && mrp <= 0) ? null : mrp;

          if (product["images"] == null) {
            final imgs = (product["imageUrls"] is List)
                ? product["imageUrls"] as List
                : const [];
            product["images"] = imgs.map((u) => {"name": "$u"}).toList();
          }

          m["product"] = product;
          m["inventory"] ??= <String, dynamic>{};
          m["inventory"]["stocks"] = (m["inventory"]["stocks"] ?? 1);
          m["inventory"]["product_matrix_name_size"] ??= "";

          return m;
        }));

        if (!silent) {
          boardProducts.assignAll(mapped);
          wishListProduct.assignAll(mapped);
          wishlistCount.value = mapped.length;
          selected.assignAll(List<bool>.filled(mapped.length, false));
          addList.clear();
          deleteidList.clear();
          addItem.value = 0;
        }

        return mapped; // ✅ return the list
      } else {
        if (!silent) {
          boardProducts.clear();
          wishListProduct.clear();
          wishlistCount.value = 0;
          selected.clear();
        }

        if (resp.statusCode == 404) {
          // 404: Board doesn't have products yet or doesn't exist
          print("⚠️ fetchBoardProducts 404: Board $boardId has no products or doesn't exist");
          // Don't show error snackbar for empty board - it's a valid state
        } else {
          print("❌ fetchBoardProducts ${resp.statusCode} ${resp.reasonPhrase}");
          if (!silent) {
            getSnackBar("Failed to fetch board products.");
          }
        }
        return [];
      }
    } catch (e) {
      print("fetchBoardProducts error: $e");
      if (!silent) {
        boardProducts.clear();
        wishListProduct.clear();
        wishlistCount.value = 0;
        selected.clear();
        getSnackBar("Something went wrong.");
      }
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// POST /board-product  {userId, productId, boardId}
  Future<void> addProductToBoard(int boardId, int productId) async {
    final auth = await _auth();
    if (auth == null) return;

    final userId = auth['userId'];
    if (userId == null) return; // Guest users can't add to boards

    final token = auth['token'] as String;

    showLoading();
    try {
      final resp = await http.post(
        Uri.parse(ApiEndpoints.boardProductMutate()),
        headers: _headers(token, json: true),
        body: jsonEncode(
          {"userId": userId, "productId": productId, "boardId": boardId},
        ),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        getSnackBar("✅ Product added to board.");

        // Update wishlist status
        isWishlisted.value = true;
        wishListDetails["wishlisted"] = true;

        // Refresh boards list
        await fetchBoards();
      } else {
        getSnackBar(
            _serverMessage(resp, fallback: "Failed to add product to board."));
      }
    } catch (e) {
      print("addProductToBoard error: $e");
      getSnackBar("Something went wrong.");
    } finally {
      hideLoading();
    }
  }

  /// DELETE /board-product  {userId, productId, boardId}
  Future<void> removeProductFromBoard(int boardId, int productId) async {
    final auth = await _auth();
    if (auth == null) return;

    final userId = auth['userId'];
    if (userId == null) return; // Guest users can't remove from boards

    final token = auth['token'] as String;

    showLoading();
    try {
      final req =
          http.Request('DELETE', Uri.parse(ApiEndpoints.boardProductMutate()))
            ..headers.addAll(_headers(token, json: true))
            ..body = jsonEncode({
              "userId": userId,
              "productId": productId,
              "boardId": boardId,
            });

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      final ok = res.statusCode == 200 ||
          res.statusCode == 202 ||
          res.statusCode == 204;
      if (ok) {
        // Optimistically update local state so UI reflects removal immediately.
        boardProducts.removeWhere((e) {
          final m = Map<String, dynamic>.from(e as Map);
          final id = m['productId'] ?? m['id'];
          return '$id' == '$productId';
        });
        wishListProduct.assignAll(boardProducts);
        wishlistCount.value = boardProducts.length;
        isWishlisted.value = false;
        wishListDetails["wishlisted"] = false;

        getSnackBar("✅ Product removed.");
      } else {
        final msg = _serverMessage(res, fallback: "Failed to delete product.");
        print("❌ removeProductFromBoard ${res.statusCode} ${res.body}");
        getSnackBar("❌ $msg");
      }
    } catch (e) {
      print("removeProductFromBoard error: $e");
      getSnackBar("Something went wrong.");
    } finally {
      hideLoading();
    }
  }

  // ======================================================
  // ============== tiny screen convenience ===============
  // ======================================================

  /// Older screens call this; keep it simple: just fetch products.
  Future<void> getWishlistDetails(int boardId, int _page, [Color? _]) async {
    isDetails.value = true;
    try {
      await fetchBoardProducts(boardId);
    } catch (e) {
      print("getWishlistDetails error: $e");
      getSnackBar("Failed to load wishlist.");
    } finally {
      isDetails.value = false;
    }
  }

  /// Old name used in some screens; keep as alias for boards list.
  Future<void> getWishlistData() => fetchBoards();

  /// PDP heart helper (optional)
  void checkIfProductIsWishlisted(int productId) {
    isHeartLoading.value = true;
    try {
      final exists = boardProducts.any(
        (p) =>
            (p['id']?.toString() ?? p['productId']?.toString() ?? '') ==
            '$productId',
      );
      isWishlisted.value = exists;
      wishListDetails["wishlisted"] = exists;
    } catch (_) {
      isWishlisted.value = false;
      wishListDetails["wishlisted"] = false;
    } finally {
      isHeartLoading.value = false;
    }
  }

  /// Move-to-cart stub used by PDP
  void callMovetoCart(
    String boardId,
    String wishlistProductId,
    String sizeInventoryId,
    int quantity,
  ) {
    print(
        "Moving item to cart: $wishlistProductId (board:$boardId, size:$sizeInventoryId, qty:$quantity)");
    // TODO: implement cart API if required.
  }

  // Backwards-compat wrapper kept elsewhere in codebase
  @Deprecated('Use removeProductFromBoard(boardId, productId)')
  Future<void> deleteProductFromBoard(int boardId, int productId) =>
      removeProductFromBoard(boardId, productId);
}
