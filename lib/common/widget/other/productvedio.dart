import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../controllers/product_controller.dart';
import '../../../core/constant/constants.dart';



class ProductVideo extends StatefulWidget {
  final VideoPlayerController videoController;
  final Function? onPressedPlay;
  final Function? onPressedPause;

  const ProductVideo({
    Key? key,
    required this.videoController,
    this.onPressedPlay,
    this.onPressedPause,
  }) : super(key: key);

  @override
  State<ProductVideo> createState() => _ProductVideoState();
}

class _ProductVideoState extends State<ProductVideo> {
  final productController = Get.put(ProductController());
  // bool isVideo = true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.videoController.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            fit: StackFit.expand,
            children: [
              AspectRatio(
                aspectRatio: widget.videoController.value.aspectRatio,
                child: VideoPlayer(widget.videoController),
              ),
              IconButton(
                icon: CircleAvatar(
                    backgroundColor: blue,
                    child: Obx(
                          () => Icon(
                        !productController.isVideoPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    )),
                onPressed: () {
                  if (widget.videoController.value.isPlaying) {
                    widget.videoController.pause();
                    productController.isVideoPlaying.value = true;
                  } else {
                    productController.isVideoPlaying.value = false;
                    widget.videoController.play();
                  }
                },
              ),
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
