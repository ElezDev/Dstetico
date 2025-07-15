import 'dart:ui';

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final LinearGradient? gradient;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.gradient,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = Center(
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
          : Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: buttonChild,
      ),
    );
  }
}
