import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class AppNavBar extends StatelessWidget {
  final String currentRoute;
  final VoidCallback? onMenuTap;

  const AppNavBar({
    super.key,
    required this.currentRoute,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isMobile = Responsive.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getHorizontalPadding(context),
            vertical: isMobile ? 10 : 14,
          ),
          child: Row(
            children: [
              _buildLogo(context),
              const Spacer(),
              if (!isMobile) ...[
                _buildDesktopLinks(context, auth),
                const SizedBox(width: 22),
                _buildDesktopActions(context, auth, themeProvider),
              ] else ...[
                IconButton(
                  tooltip: 'Toggle theme',
                  onPressed: themeProvider.toggleTheme,
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    size: 20,
                  ),
                ),
                if (auth.isLoggedIn)
                  _buildAvatar(context, compact: true)
                else
                  IconButton(
                    tooltip: 'Sign in',
                    onPressed: () => Navigator.of(context).pushNamed('/login'),
                    icon: const Icon(Icons.person_outline, size: 21),
                  ),
                IconButton(
                  tooltip: 'Open menu',
                  onPressed: onMenuTap,
                  icon: const Icon(Icons.menu_rounded, size: 24),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x663E241B),
                    blurRadius: 0,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 19),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.titleLarge,
                children: [
                  const TextSpan(text: 'Recipe'),
                  TextSpan(
                    text: 'Book',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLinks(BuildContext context, AuthProvider auth) {
    final links = [
      {'label': 'Home', 'route': '/home'},
      {'label': 'Search', 'route': '/search'},
      {'label': 'Categories', 'route': '/categories'},
      if (auth.isLoggedIn) ...[
        {'label': 'My Recipes', 'route': '/my-recipes'},
        {'label': 'Dashboard', 'route': '/dashboard'},
      ],
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: links.map((link) {
        final active = currentRoute == link['route'];
        return Padding(
          padding: const EdgeInsets.only(left: 18),
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed(link['route']!),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                link['label']!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: active
                          ? AppTheme.primaryColor
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopActions(
    BuildContext context,
    AuthProvider auth,
    ThemeProvider themeProvider,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Toggle theme',
          onPressed: themeProvider.toggleTheme,
          icon: Icon(
            themeProvider.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            size: 20,
          ),
        ),
        if (auth.isLoggedIn) ...[
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/saved-recipes'),
            icon: const Icon(Icons.bookmark_border_rounded, size: 17),
            label: const Text('Saved Recipes'),
          ),
          const SizedBox(width: 10),
          _buildAvatar(context),
        ] else ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/login'),
            child: const Text('Sign In'),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/register'),
            child: const Text('Join Free'),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, {bool compact = false}) {
    final auth = context.watch<AuthProvider>();
    return PopupMenuButton<String>(
      tooltip: 'Account menu',
      onSelected: (value) {
        final routes = {
          'profile': '/profile',
          'dashboard': '/dashboard',
          'my-recipes': '/my-recipes',
          'saved': '/saved-recipes',
          'add': '/add-recipe',
        };
        if (value == 'logout') {
          context.read<AuthProvider>().logout();
          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
        } else if (routes[value] != null) {
          Navigator.of(context).pushNamed(routes[value]!);
        }
      },
      icon: CircleAvatar(
        radius: compact ? 16 : 18,
        backgroundColor: AppTheme.accentColor.withOpacity(0.35),
        child: Text(
          auth.user?.initials ?? '?',
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'profile', child: Text('Profile')),
        PopupMenuItem(value: 'dashboard', child: Text('Dashboard')),
        PopupMenuItem(value: 'my-recipes', child: Text('My Recipes')),
        PopupMenuItem(value: 'saved', child: Text('Saved Recipes')),
        PopupMenuItem(value: 'add', child: Text('Add Recipe')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'logout', child: Text('Log out')),
      ],
    );
  }
}