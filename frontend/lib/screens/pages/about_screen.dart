import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/mobile_drawer.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MobileDrawer(),
      body: Column(
        children: [
          AppNavBar(
            currentRoute: '/about',
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getHorizontalPadding(context),
                      vertical: 60,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.12),
                          AppTheme.primaryColor.withOpacity(0.04),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About RecipeBook',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Where food lovers share their passion',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Content
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getHorizontalPadding(context),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            icon: Icons.lightbulb_rounded,
                            title: 'Our Mission',
                            description:
                                'RecipeBook was created to connect food enthusiasts from around the world. '
                                'We believe that everyone has a story to tell through food, and our platform '
                                'provides the perfect space to share, discover, and celebrate culinary creations.',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            icon: Icons.people_rounded,
                            title: 'Our Community',
                            description:
                                'With thousands of active users, RecipeBook has grown into a vibrant community '
                                'of home cooks, professional chefs, and food bloggers. Whether you\'re looking for '
                                'a quick weeknight dinner or an elaborate feast, you\'ll find it here.',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            icon: Icons.star_rounded,
                            title: 'Why Choose RecipeBook',
                            description:
                                'RecipeBook offers an intuitive interface, powerful search capabilities, '
                                'and a beautiful design that makes browsing recipes a pleasure. Our platform '
                                'supports multiple cuisines, dietary preferences, and cooking styles.',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 24),
                          // Features list
                          Text(
                            'Platform Features',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._featureItems.map((f) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF16213E) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: f['color']!.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(f['icon'] as IconData, color: f['color'] as Color, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  f['label'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const AppFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _featureItems = [
    {'icon': Icons.restaurant_menu_rounded, 'label': 'Share & Discover Recipes', 'color': AppTheme.primaryColor},
    {'icon': Icons.search_rounded, 'label': 'Advanced Search & Filters', 'color': AppTheme.accentColor},
    {'icon': Icons.bookmark_rounded, 'label': 'Save Your Favorites', 'color': Colors.teal},
    {'icon': Icons.star_rounded, 'label': 'Rate & Review', 'color': Colors.amber},
    {'icon': Icons.comment_rounded, 'label': 'Community Discussion', 'color': Colors.blue},
    {'icon': Icons.category_rounded, 'label': 'Organized Categories', 'color': Colors.purple},
  ];

  Widget _buildSection({required IconData icon, required String title,
      required String description, required bool isDark}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
