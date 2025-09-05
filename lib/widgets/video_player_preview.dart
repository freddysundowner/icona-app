import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../controllers/product_controller.dart';

class VideoPlayerWidget extends StatefulWidget {
  final CustomImage customImage;
  final double volume;

  const VideoPlayerWidget(
      {super.key, required this.customImage, this.volume = 1.0});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.customImage.imgType == ImageType.network
        ? VideoPlayerController.networkUrl(
            Uri.parse(widget.customImage.path)) // URL video
        : VideoPlayerController.file(
            File(widget.customImage.path)); // Local video

    _controller.initialize().then((_) {
      setState(() {});
      _controller.setVolume(widget.volume); // Mute by default
      _controller.play(); // Auto-play
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8), // Apply border radius
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), // Ensure rounding
              ),
              child: FittedBox(
                fit: BoxFit.cover, // Change to BoxFit.contain if needed
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height * 0.85,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          )
        : Center(
            child:
                CircularProgressIndicator()); // Show loading indicator while video loads
  }
}
