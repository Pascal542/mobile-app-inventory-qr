import 'package:flutter/material.dart';

class InventoryShell extends StatelessWidget {
  final Widget child;

  const InventoryShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
    );
  }
} 