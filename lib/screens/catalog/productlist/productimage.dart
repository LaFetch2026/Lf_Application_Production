// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

import '../../../controllers/product_controller.dart';
import '../../../core/constant/constants.dart';

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
  late VideoPlayerController videoController;
  late Future<void> _initializeVideoPlayerFuture;

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
          productController.isVideoPlaying.value = true;
          videoController = VideoPlayerController.networkUrl(
            Uri.parse(
              widget.list[i]["name"],
            ),
          );

          _initializeVideoPlayerFuture = videoController.initialize();
          videoController.setLooping(true);

          list.add(
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Obx(() => Stack(
                        fit: StackFit.expand,
                        children: [
                          AspectRatio(
                            aspectRatio: videoController.value.aspectRatio,
                            child: VideoPlayer(videoController),
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
                              if (videoController.value.isPlaying) {
                                videoController.pause();
                                productController.isVideoPlaying.value = true;
                              } else {
                                productController.isVideoPlaying.value = false;
                                videoController.play();
                              }
                            },
                          ),
                        ],
                      ));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
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

  bool isImage(String path) {
    print(path);
    return path.contains('product_photo');
  }

  @override
  void dispose() {
    productController.isVideoPlaying.value = true;
    videoController.dispose();
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
                                        onPageChanged: (number) {
                                          _curr = number;
                                          print(_curr);
                                          setState(() {});
                                          if (videoController.value.isPlaying) {
                                            videoController.pause();
                                            productController
                                                .isVideoPlaying.value = true;
                                          }
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
                                          fit: BoxFit.cover),
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
