import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:final_project/constants/app_colors.dart';

class HelloScreen extends StatefulWidget {
  const HelloScreen({super.key});

  @override
  State<HelloScreen> createState() => _HelloScreenState();
}

class _HelloScreenState extends State<HelloScreen>
    with SingleTickerProviderStateMixin {
  // All sizing/position below is relative to the screen (0.0–1.0), so the
  // logo scales with the device instead of using fixed pixel values.
  static const double _logoWidthFactor = 0.70;
  static const double _logoHeightFactor = 0.40;
  static const double _logoTopFactor = 0.12;
  static const double _logoLeftFactor = 0.01;

  // The "أُنُس" text image sits beside the logo, to its right.
  static const double _textGapFactor = 0.02; // gap between logo and image
  static const double _textRightMarginFactor = 0.02;
  static const double _textAspectRatio = 890 / 838; // unus.png width / height

  // The source video has black letterboxing baked into the frame around the
  // actual animated mark. Measured directly on a device screenshot: the
  // visible mark occupies roughly 221x212px inside a 755x425px 16:9 frame,
  // centered. Displaying the video at this tighter aspect ratio with
  // BoxFit.cover crops that black border away instead of showing the full
  // raw frame.
  static const double _logoContentAspectRatio = 221 / 212;

  late final VideoPlayerController _controller;

  // Slide-in entrance: the logo travels from off-screen left to its final
  // position while the video plays normally underneath it.
  late final AnimationController _slideController;
  late final Animation<double> _slideAnimation;

  // The text image stays hidden for the first second on the page, then
  // fades in.
  bool _showText = false;
  Timer? _textTimer;

  // Some Android video backends blank the texture once a non-looping video
  // reaches end-of-stream. To avoid that flash of black, we intercept the
  // last moment of playback and freeze a hair before the real end instead
  // of letting it "complete" naturally.
  bool _heldFinalFrame = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );

    _controller = VideoPlayerController.asset('assets/logo/logo_build.mp4')
      ..setLooping(false) // play the logo animation once only
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play(); // autoplay as soon as the video is ready
      });
    _controller.addListener(_holdFinalFrame);

    // Start the slide-in immediately so it runs alongside the video.
    _slideController.forward();

    // Reveal the text exactly one second after this page starts.
    _textTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _showText = true);
    });
  }

  void _holdFinalFrame() {
    if (_heldFinalFrame) return;
    final value = _controller.value;
    if (!value.isInitialized || value.duration == Duration.zero) return;

    const freezeMargin = Duration(milliseconds: 60);
    if (value.position >= value.duration - freezeMargin) {
      _heldFinalFrame = true;
      _controller.pause();
      _controller.seekTo(value.duration - freezeMargin);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_holdFinalFrame);
    _controller.dispose();
    _slideController.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final logoWidth = screenSize.width * _logoWidthFactor;
    final logoHeight = screenSize.width * _logoHeightFactor;
    final logoTop = screenSize.height * _logoTopFactor;
    final logoLeft = screenSize.width * _logoLeftFactor;
    final logoStartLeft = -logoWidth; // fully off-screen to the left
    final logoRight = logoLeft + logoWidth;

    // Image sits to the right of the logo, filling the remaining width and
    // vertically centered against the logo's box.
    final textLeft = logoRight + screenSize.width * _textGapFactor;
    final textWidth =
        screenSize.width - textLeft - screenSize.width * _textRightMarginFactor;
    final textHeight = textWidth / _textAspectRatio;
    final textTop = logoTop + (logoHeight - textHeight) / 2;

    final logoContent = SizedBox(
      width: logoWidth,
      height: logoHeight,
      child: _controller.value.isInitialized
          ? RepaintBoundary(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _logoContentAspectRatio,
                  child: ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );

    return Scaffold(
      backgroundColor: AppColors.Burgundy,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              final currentLeft =
                  logoStartLeft +
                  (logoLeft - logoStartLeft) * _slideAnimation.value;
              return Positioned(
                top: logoTop,
                left: currentLeft,
                child: child!,
              );
            },
            child: logoContent,
          ),
          Positioned(
            top: textTop,
            left: textLeft,
            child: AnimatedOpacity(
              opacity: _showText ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: Image.asset('assets/images/unus.png', width: textWidth),
            ),
          ),
        ],
      ),
    );
  }
}
