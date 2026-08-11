import 'package:flutter/material.dart';
import 'app_nav_bar.dart';
import 'app_footer.dart';

class PageWrapper extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const PageWrapper({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppNavBar(currentRoute: currentRoute),
          Expanded(
            child: SingleChildScrollView(
              child: child,
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}
