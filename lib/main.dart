import 'package:final_project/screens/hello_screen.dart';
import 'package:flutter/material.dart';
import 'package:fvp/fvp.dart' as fvp;

void main() {
  // video_player has no native Windows/Linux/macOS implementation, so fvp
  // fills that gap there. On Android/iOS the official implementation
  // already works (and renders more reliably), so we scope fvp to desktop
  // only instead of letting it take over every platform.
  fvp.registerWith(options: {
    'platforms': ['windows', 'linux', 'macos'],
  });
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HelloScreen(),
    );
  }
}
