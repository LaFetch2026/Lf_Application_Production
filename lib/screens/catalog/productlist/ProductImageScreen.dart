import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:lafetch/common/widget/other/lf_loader_widget.dart';

class ProductImage_Screen extends StatefulWidget {
  final int curr;
  final List<Map<String, dynamic>> list; // [{name: url, isVideo:false}, ...]

  const ProductImage_Screen({
    super.key,
    required this.curr,
    required this.list,
  });

  @override
  State<ProductImage_Screen> createState() => _ProductImage_ScreenState();
}

class _ProductImage_ScreenState extends State<ProductImage_Screen> {
  late final PageController _pageController;
  int _index = 0;
  bool _chromeVisible = true; // show/hide AppBar & indicator on tap

  bool _isImageUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }

  List<String> get _images {
    final urls = <String>[];
    for (final m in widget.list) {
      final url = (m['name'] ?? '').toString().trim();
      final isVideoFlag = m['isVideo'] == true;
      if (url.isNotEmpty && !isVideoFlag && _isImageUrl(url)) {
        urls.add(url);
      }
    }
    return urls;
  }

  @override
  void initState() {
    super.initState();
    final imgs = _images;
    final start = imgs.isEmpty ? 0 : widget.curr.clamp(0, imgs.length - 1);
    _index = start;
    _pageController = PageController(initialPage: start);
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _chromeVisible
          ? AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                '${images.isEmpty ? 0 : _index + 1} / ${images.length}',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
      body: images.isEmpty
          ? const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
            )
          : Stack(
              children: [
                // PhotoView gallery gives pinch, pan, and double-tap zoom out of the box.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _chromeVisible = !_chromeVisible),
                  child: PhotoViewGallery.builder(
                    pageController: _pageController,
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    backgroundDecoration:
                        const BoxDecoration(color: Colors.black),
                    loadingBuilder: (_, __) => const Center(
                      child: LfLogoLoader(size: 32, showGlow: false),
                    ),
                    builder: (context, index) {
                      final url = images[index];
                      // Medium-res for memory safety (1500px) - still allows 2-3x zoom
                      // while preventing OOM from loading massive original images
                      final mediumResProvider = ResizeImage(
                        CachedNetworkImageProvider(url),
                        width: 1500,
                        height: 1500,
                        policy: ResizeImagePolicy.fit,
                      );
                      return PhotoViewGalleryPageOptions(
                        imageProvider: mediumResProvider,
                        heroAttributes: PhotoViewHeroAttributes(tag: url),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 3.0,
                        // Double-tap zoom behavior:
                        gestureDetectorBehavior: HitTestBehavior.opaque,
                      );
                    },
                  ),
                ),

                // Bottom index pill (like many commerce apps)
                if (_chromeVisible)
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          '${_index + 1} / ${images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
