import 'package:flutter/material.dart';

class LegalLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const LegalLayout({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: child,
    );
  }
}
