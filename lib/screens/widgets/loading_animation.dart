import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
                height: 100, width: 100, child: Lottie.asset("assets/images/loading.json", frameRate: FrameRate.max))
            .animate()
            .scale(duration: 600.ms)
            .fade(duration: 400.ms));
  }
}
