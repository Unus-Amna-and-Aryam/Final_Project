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
  static const double _logoWidthFactor = 0.70;
  static const double _logoHeightFactor = 0.50;
  static const double _textWidthFactor = 0.58;
  static const double _textAspectRatio = 890 / 838;
  static const double _logoContentAspectRatio = 221 / 212;
  static const double _logoExtraZoom = 1.6;

  late final VideoPlayerController _controller;
  late final AnimationController _slideController;
  late final Animation<double> _slideAnimation;
  bool _showText = false;
  Timer? _textTimer;
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
      ..setLooping(false)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.setVolume(0);
        _controller.play();
        _textTimer = Timer(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          setState(() => _showText = true);
        });
      });
    _controller.addListener(_holdFinalFrame);
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
    final logoTop = (screenSize.height - logoHeight) / 2;
    final logoLeft = (screenSize.width - logoWidth) / 2;
    final logoStartLeft = -logoWidth;
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
      backgroundColor: AppColors.burgundy,
      body: GestureDetector(
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
                        color: AppColors.gold,
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
                    color: AppColors.gold,
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
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreatAcountScreen()));
  }
}
