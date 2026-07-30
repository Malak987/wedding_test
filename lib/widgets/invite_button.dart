import 'package:flutter/material.dart';
import 'animated_button.dart';

/// Semantic alias of [AnimatedButton] used specifically on the hero
/// section, kept separate so its style can diverge later without
/// touching the generic button.
class InviteButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const InviteButton({super.key, required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(label: label, onPressed: onPressed, icon: icon);
  }
}
