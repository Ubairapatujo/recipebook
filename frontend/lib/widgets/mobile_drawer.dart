import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              color: AppTheme.primaryColor.withOpacity(0.08),
              child: auth.isLoggedIn
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                          child: Text(
                            auth.user!.initials,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.user!.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                              ),
                            ),
                            Text(
                              auth.user!.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RecipeBook',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Discover & Share Recipes',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            // Navigation items
            _drawerItem(context, Icons.home_rounded, 'Home', '/home'),
            _drawerItem(context, Icons.search_rounded, 'Search', '/search'),
            _drawerItem(context, Icons.category_rounded, 'Categories', '/categories'),
            const Divider(indent: 16, endIndent: 16),
            if (auth.isLoggedIn) ...[
              _drawerItem(context, Icons.book_rounded, 'My Recipes', '/my-recipes'),
              _drawerItem(context, Icons.bookmark_rounded, 'Saved Recipes', '/saved-recipes'),
              _drawerItem(context, Icons.dashboard_rounded, 'Dashboard', '/dashboard'),
              _drawerItem(context, Icons.person_rounded, 'Profile', '/profile'),
              _drawerItem(context, Icons.add_circle_rounded, 'Add Recipe', '/add-recipe'),
              const Divider(indent: 16, endIndent: 16),
              _drawerItem(context, Icons.logout, 'Logout', null, onTap: () {
                auth.logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
              }),
            ] else ...[
              _drawerItem(context, Icons.login_rounded, 'Sign In', '/login'),
              _drawerItem(context, Icons.person_add_rounded, 'Register', '/register'),
            ],
            const Divider(indent: 16, endIndent: 16),
            _drawerItem(context, Icons.info_rounded, 'About', '/about'),
            _drawerItem(context, Icons.mail_rounded, 'Contact', '/contact'),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    String? route, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      onTap: onTap ??
          (route != null
              ? () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(route);
                }
              : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      dense: true,
    );
  }
}
