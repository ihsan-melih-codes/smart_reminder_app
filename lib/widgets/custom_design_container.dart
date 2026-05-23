import 'package:flutter/material.dart';

class CustomDesignContainer extends StatelessWidget {
  final Widget child;
  const CustomDesignContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.deepPurple.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }
}
