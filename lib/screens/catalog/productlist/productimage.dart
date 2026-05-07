// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

import '../../../controllers/product_controller.dart';
import '../../../core/constant/constants.dart';
import '../../../utils/audio_session_helper.dart';
import 'package:lafetch/common/widget/other/lf_loader_widget.dart';

class ProductImageScreen extends StatefulWidget {
  final int curr;
  final List list;

  const ProductImageScreen({
    super.key,
    required this.curr,
    required this.list,
  });

  @override
  State<ProductImageScreen> createState() => ProductImageScreenState();
}

class ProductImageScreenState extends State<ProductImageScreen> {
  int _curr = 0;
  final productController = Get.put(ProductController());
  PageController pageController = PageController();
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoPlayerFuture;

  /// Track which index is currently a video to dispose when swiping away
  int? _currentVideoIndex;

  @override
  void initState() {
    _curr = widget.curr;
    pageController = PageController(initialPage: _curr);
    super.initState();
  }

  List<Widget> getListForPageView() {
    List<Widget> list = [];
    if (widget.list.isNotEmpty) {
      for (var i = 0; i < widget.list.length; i++) {
        if (isImage(widget.list[i]["name"])) {
          print("show video=========${isImage(widget.list[i]["name"])}");

          list.add(Container(
            color: whiteColor,
            child: PhotoView(
              backgroundDecoration: BoxDecoration(color: whiteColor),
              initialScale: PhotoViewComputedScale.covered,
              imageProvider: NetworkImage(widget.list[i]["name"]),
            ),
          ));
        } else {
          // Video item - only initialize when this page becomes active
          productController.isVideoPlaying.value = true;
          _initializeVideoPlayerFuture =
              _initVideoAmbient(widget.list[i]["name"], i);

          list.add(
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    _videoController != null &&
                    _videoController!.value.isInitialized) {
                  return Obx(() => Stack(
                        fit: StackFit.expand,
                        children: [
                          AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                          IconButton(
                            icon: CircleAvatar(
                              backgroundColor: blue,
                              child: Icon(
                                !productController.isVideoPlaying.value
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                            ),
                            onPressed: () {
                              if (_videoController!.value.isPlaying) {
                                _videoController!.pause();
                                productController.isVideoPlaying.value = true;
                              } else {
                                productController.isVideoPlaying.value = false;
                                _videoController!.play();
                              }
                            },
                          ),
                        ],
                      ));
                } else {
                  return const Center(
                    child: LfLogoLoader(size: 32, showGlow: false),
                  );
                }
              },
            ),
          );
        }
      }
    } else {
      list.add(Image.asset(dummyWishlistImage, fit: BoxFit.fitHeight));
    }
    return list;
  }

  Future<void> _initVideoAmbient(String url, int index) async {
    // Dispose any existing controller before creating new one
    await _disposeCurrentVideoController();

    await configureAmbientAudioSession();
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _currentVideoIndex = index;
    await _videoController!.initialize();
    _videoController!.setLooping(true);
    _videoController!.play();
  }

  Future<void> _disposeCurrentVideoController() async {
    if (_videoController != null) {
      await _videoController!.pause();
      await _videoController!.dispose();
      _videoController = null;
      _currentVideoIndex = null;
    }
  }

  /// Call when swiping away from a video page to pause/dispose
  Future<void> _onVideoPageLeft() async {
    await _disposeCurrentVideoController();
    productController.isVideoPlaying.value = true;
  }

  bool isImage(String path) {
    print(path);
    return path.contains('product_photo');
  }

  @override
  void dispose() {
    _disposeCurrentVideoController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Stack(
                            children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 0.sp),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: PageView(
                                        allowImplicitScrolling: true,
                                        scrollDirection: Axis.horizontal,
                                        controller: pageController,
                                        onPageChanged: (number) async {
                                          _curr = number;
                                          print(_curr);
                                          setState(() {});

                                          // If leaving a video page, dispose its controller
                                          if (_currentVideoIndex != null &&
                                              _currentVideoIndex != number) {
                                            await _onVideoPageLeft();
                                          }

                                          // If entering a video page, the FutureBuilder will handle init
                                        },
                                        children: getListForPageView()),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 16.sp),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: SvgPicture.asset(arrowBack,
                                          height: 15.sp,
                                          width: 15.sp,
                                          fit: BoxFit.fill),
                                      onPressed: () {
                                        Get.back();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        widget.list.length == 1
                            ? const SizedBox(
                                height: 0,
                              )
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 22.0.sp, vertical: 30.0.sp),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List<Widget>.generate(
                                      widget.list.length,
                                      (index) => Container(
                                            height: 6.sp,
                                            width: 40.sp,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 5.sp),
                                            decoration: BoxDecoration(
                                                color: (index == _curr)
                                                    ? colorPrimary
                                                    : colorSecondary),
                                          )),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
