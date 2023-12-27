import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedText extends StatelessWidget {
  const AnimatedText(this.text,
      {super.key,
      this.style,
      this.scaleAnimation,
      this.fadeAnimation,
      this.duration,
      this.flipAnimation,
      this.textAlign,
      this.typingAnimation,
      this.curve});
  final String text;
  final TextStyle? style;
  final bool? scaleAnimation;
  final bool? fadeAnimation;
  final bool? flipAnimation;
  final bool? typingAnimation;
  final Duration? duration;
  final TextAlign? textAlign;
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    Widget textWidget = Text(
      text,
      textAlign: textAlign,
      style: style ?? GoogleFonts.urbanist(),
    );
    if (scaleAnimation == true) {
      return textWidget.animate().scale(duration: duration ?? 120.ms, curve: curve);
    }
    if (fadeAnimation == true) {
      return textWidget.animate().fade(duration: duration ?? 120.ms, curve: curve);
    }
    if (flipAnimation == true) {
      return textWidget.animate().flip(duration: duration ?? 120.ms, curve: curve);
    }
    if (typingAnimation == true) {
      return Animate().custom(
        duration: duration ?? const Duration(seconds: 1),
        begin: 0,
        end: text.length.toDouble(),
        curve: curve,
        builder: (_, value, __) => Text(
          text.substring(0, value.toInt()),
          textAlign: textAlign,
          style: style ?? GoogleFonts.urbanist(),
        ),
      );
    }
    return textWidget;
  }
}
