import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:final_project/constants/app_colors.dart';
import 'package:final_project/screens/create_acount_screen.dart';

class HelloScreen extends StatefulWidget {
  const HelloScreen({super.key});

  @override
  State<HelloScreen> createState() => _HelloScreenState();
}

class _HelloScreenState extends State<HelloScreen>
    with SingleTickerProviderStateMixin {
  // All sizing below is relative to the screen (0.0–1.0), so the logo scales
  // with the device instead of using fixed pixel values.
  static const double _logoWidthFactor = 0.70;
  static const double _logoHeightFactor = 0.50;

  // The "أُنُس" text image, placed above the logo.
  static const double _textWidthFactor = 0.58;
  static const double _textAspectRatio = 890 / 838; // unus.png width / height

  // The source video has a black border baked into the frame around the
  // actual animated mark on all four sides. Measured directly on a device
  // screenshot: the visible mark occupies roughly 221x212px inside a
  // 755x425px 16:9 frame, centered. Reshaping the display box to that
  // tighter aspect ratio with BoxFit.cover only crops the axis the fit
  // doesn't constrain to (here, width), so an extra uniform zoom is needed
  // on top to crop the remaining border on every side.
  static const double _logoContentAspectRatio = 221 / 212;
  static const double _logoExtraZoom = 1.6;

  late final VideoPlayerController _controller;

  // Slide-in entrance: the logo travels from off-screen left to its final
  // position while the video plays normally underneath it.
  late final AnimationController _slideController;
  late final Animation<double> _slideAnimation;

  // The name and phrase stay hidden until the logo video has actually
  // started playing, then fade in shortly after.
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
        // Browsers refuse to autoplay a video with sound before the user
        // has interacted with the page — this splash video plays the
        // instant the page loads, so on web that autoplay call was
        // silently rejected and the video just never started. Muting
        // first (fine here: it's a silent logo animation) is exactly
        // what browser autoplay policies allow through.
        _controller.setVolume(0);
        _controller.play(); // autoplay as soon as the video is ready

        // Only reveal the name and phrase once the logo video is actually
        // playing, shortly after it starts.
        _textTimer = Timer(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          setState(() => _showText = true);
        });
      });
    _controller.addListener(_holdFinalFrame);

    // Start the slide-in immediately so the logo appears first.
    _slideController.forward();
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
    // Logo centered in the middle of the screen.
    final logoTop = (screenSize.height - logoHeight) / 2;
    final logoLeft = (screenSize.width - logoWidth) / 2;
    final logoStartLeft = -logoWidth; // fully off-screen to the left

    // Name sits above the logo, horizontally centered with it; same size as
    // before.
    final textWidth = screenSize.width * _textWidthFactor;
    final textHeight = textWidth / _textAspectRatio;
    final textLeft = (screenSize.width - textWidth) / 2;
    final textTop = logoTop - textHeight - screenSize.height * 0.08;

    final logoContent = SizedBox(
      width: logoWidth,
      height: logoHeight,
      child: _controller.value.isInitialized
          ? RepaintBoundary(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _logoContentAspectRatio,
                  // The ClipRect here is sized to this tight aspect box
                  // (not the wider outer SizedBox), so the extra zoom below
                  // actually gets cropped against the video's own frame
                  // instead of the much larger logo container.
                  child: ClipRect(
                    child: Transform.scale(
                      scale: _logoExtraZoom,
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
              ),
            )
          : const SizedBox.shrink(),
    );

    return Scaffold(
      backgroundColor: AppColors.Burgundy,
      body: GestureDetector(
        // Swiping up anywhere on the page opens the next screen.
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -200) _goToSecondScreen();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/hello_background.png',
                fit: BoxFit.cover,
              ),
            ),
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
                child: Image.asset(
                  'assets/images/unus.png',
                  width: textWidth,
                  height: textHeight,
                ),
              ),
            ),
            Positioned(
              top: logoTop + logoHeight + screenSize.height * 0.02,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _showText ? 1 : 0,
                  duration: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.06,
                    ),
                    child: Text(
                      'بهم نستأنس … بأُنس ننظّم',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        color: AppColors.Gold,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: screenSize.height * 0.04,
              left: 0,
              right: 0,
              child: Center(
                child: IconButton(
                  onPressed: _goToSecondScreen,
                  icon: Icon(
                    Icons.keyboard_arrow_up,
                    color: AppColors.Gold,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToSecondScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreatAcountScreen()),
    );
  }
}
