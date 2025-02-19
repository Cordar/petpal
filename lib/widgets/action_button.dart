import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final bool isDisabled;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.label,
    required this.isDisabled,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey : color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 40),
        ),
        onPressed: isDisabled ? null : onPressed, // Disable button if needed
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
