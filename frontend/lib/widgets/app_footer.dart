import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0F1729)
            : const Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.getHorizontalPadding(context),
          vertical: isMobile ? 40 : 56,
        ),
        child: Column(
          children: [
            // Top section
            isMobile ? _buildMobileFooter(context) : _buildDesktopFooter(context),
            const SizedBox(height: 32),
            // Divider
            Container(
              height: 1,
              color: Theme.of(context).dividerColor.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            // Bottom section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2026 RecipeBook. All rights reserved.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                Row(
                  children: [
                    _socialIcon(Icons.facebook_rounded, () {}),
                    const SizedBox(width: 12),
                    _socialIcon(Icons.flutter_dash_rounded, () {}),
                    const SizedBox(width: 12),
                    _socialIcon(Icons.alternate_email_rounded, () {}),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand column
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'RecipeBook',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Discover, share, and cook amazing recipes from a global community of food lovers.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              // Newsletter
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF16213E)
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Subscribe'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Links columns
        _buildLinksColumn(
          context,
          'Explore',
          [
            {'label': 'All Recipes', 'route': '/home'},
            {'label': 'Search', 'route': '/search'},
            {'label': 'Categories', 'route': '/categories'},
            {'label': 'Popular', 'route': '/home'},
          ],
        ),
        const SizedBox(width: 32),
        _buildLinksColumn(
          context,
          'Account',
          [
            {'label': 'Profile', 'route': '/profile'},
            {'label': 'My Recipes', 'route': '/my-recipes'},
            {'label': 'Saved Recipes', 'route': '/saved-recipes'},
            {'label': 'Dashboard', 'route': '/dashboard'},
          ],
        ),
        const SizedBox(width: 32),
        _buildLinksColumn(
          context,
          'Company',
          [
            {'label': 'About', 'route': '/about'},
            {'label': 'Contact', 'route': '/contact'},
            {'label': 'Privacy', 'route': '/about'},
            {'label': 'Terms', 'route': '/about'},
          ],
        ),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'RecipeBook',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Discover, share, and cook amazing recipes from a global community of food lovers.',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        // Newsletter
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF16213E)
                      : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Subscribe'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildLinksColumn(context, 'Explore', [
          {'label': 'All Recipes', 'route': '/home'},
          {'label': 'Search', 'route': '/search'},
          {'label': 'Categories', 'route': '/categories'},
        ]),
        const SizedBox(height: 16),
        _buildLinksColumn(context, 'Account', [
          {'label': 'Profile', 'route': '/profile'},
          {'label': 'My Recipes', 'route': '/my-recipes'},
          {'label': 'Dashboard', 'route': '/dashboard'},
        ]),
        const SizedBox(height: 16),
        _buildLinksColumn(context, 'Company', [
          {'label': 'About', 'route': '/about'},
          {'label': 'Contact', 'route': '/contact'},
        ]),
      ],
    );
  }

  Widget _buildLinksColumn(BuildContext context, String title, List<Map<String, String>> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed(link['route']!),
            child: Text(
              link['label']!,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _socialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 18,
        ),
      ),
    );
  }
}
