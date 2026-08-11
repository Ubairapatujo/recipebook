import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/recipe.dart';
import '../../providers/auth_provider.dart';
import '../../services/recipe_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/mobile_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RecipeService _recipeService = RecipeService();

  bool _isLoading = true;
  List<Recipe> _userRecipes = [];
  int _myRecipesCount = 0;
  int _savedCount = 0;
  int _totalLikes = 0;
  double _avgRating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.user?.id ?? 5; // Fallback User ID

      // 1. Fetch Live Dashboard Stats
      final statsResponse = await http.get(
        Uri.parse('http://localhost:8080/api/dashboard/stats/$userId'),
      );

      if (statsResponse.statusCode == 200) {
        final data = json.decode(statsResponse.body);

        if (mounted) {
          setState(() {
            _myRecipesCount = data['totalRecipes'] ?? 0;
            _savedCount = data['totalSaves'] ?? 0;
            _totalLikes = data['totalLikes'] ?? 0;
            _avgRating = (data['avgRating'] as num?)?.toDouble() ?? 0.0;
          });
        }
      }

      // 2. Fetch User Recipes for Recent Activity
      final recipes = await _recipeService.getRecipes();

      final myRecipes = recipes.where((r) {
        if (auth.user?.id != null && auth.user!.id != 0) {
          return r.ownerId == auth.user!.id;
        }
        return r.ownerName == auth.user?.displayName;
      }).toList();

      if (mounted) {
        setState(() {
          _userRecipes = myRecipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper method to safely extract like count from recipe object or stats fallback
  int _getRecipeLikeCount(Recipe recipe) {
    if (recipe.likes != null) {
      if (recipe.likes is int) return recipe.likes as int;
      if (recipe.likes is List) return (recipe.likes as List).length;
    }
    // Agar single recipe object me like count parse nahi hua ho, toh overall total likes dikhayega
    return _totalLikes > 0 ? _totalLikes : 0;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MobileDrawer(),
      body: Column(
        children: [
          AppNavBar(
            currentRoute: '/dashboard',
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getHorizontalPadding(context),
                      vertical: 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome back, ${auth.user?.displayName ?? 'Chef'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dynamic Stats Grid
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getHorizontalPadding(context),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : (Responsive.isMobile(context)
                            ? Column(
                                children: [
                                  _buildStatsRow(
                                    [
                                      {
                                        'icon': Icons.book_rounded,
                                        'label': 'My Recipes',
                                        'value': '$_myRecipesCount',
                                        'color': AppTheme.primaryColor
                                      },
                                      {
                                        'icon': Icons.bookmark_rounded,
                                        'label': 'Saved',
                                        'value': '$_savedCount',
                                        'color': AppTheme.accentColor
                                      },
                                    ],
                                    isDark,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatsRow(
                                    [
                                      {
                                        'icon': Icons.favorite_rounded,
                                        'label': 'Total Likes',
                                        'value': '$_totalLikes',
                                        'color': Colors.red
                                      },
                                      {
                                        'icon': Icons.star_rounded,
                                        'label': 'Avg Rating',
                                        'value': _avgRating.toStringAsFixed(1),
                                        'color': Colors.amber
                                      },
                                    ],
                                    isDark,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _buildStatsRow(
                                      [
                                        {
                                          'icon': Icons.book_rounded,
                                          'label': 'My Recipes',
                                          'value': '$_myRecipesCount',
                                          'color': AppTheme.primaryColor
                                        },
                                        {
                                          'icon': Icons.bookmark_rounded,
                                          'label': 'Saved',
                                          'value': '$_savedCount',
                                          'color': AppTheme.accentColor
                                        },
                                      ],
                                      isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatsRow(
                                      [
                                        {
                                          'icon': Icons.favorite_rounded,
                                          'label': 'Total Likes',
                                          'value': '$_totalLikes',
                                          'color': Colors.red
                                        },
                                        {
                                          'icon': Icons.star_rounded,
                                          'label': 'Avg Rating',
                                          'value':
                                              _avgRating.toStringAsFixed(1),
                                          'color': Colors.amber
                                        },
                                      ],
                                      isDark,
                                    ),
                                  ),
                                ],
                              )),
                  ),
                  const SizedBox(height: 32),

                  // Activity Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getHorizontalPadding(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF16213E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withOpacity(0.05),
                            ),
                          ),
                          child: _userRecipes.isEmpty
                              ? Column(
                                  children: [
                                    Icon(
                                      Icons.inbox_rounded,
                                      size: 48,
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.4),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No activity yet',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Start by adding your first recipe!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () => Navigator.of(context)
                                          .pushNamed('/add-recipe'),
                                      icon: const Icon(Icons.add_rounded,
                                          size: 18),
                                      label: const Text('Add Recipe'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _userRecipes.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 24),
                                  itemBuilder: (context, index) {
                                    final recipe = _userRecipes[index];
                                    final likesCount =
                                        _getRecipeLikeCount(recipe);

                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.1),
                                          child: recipe.imageUrl != null &&
                                                  recipe.imageUrl!.isNotEmpty
                                              ? Image.network(recipe.imageUrl!,
                                                  fit: BoxFit.cover)
                                              : const Icon(Icons.restaurant,
                                                  color: AppTheme.primaryColor),
                                        ),
                                      ),
                                      title: Text(
                                        recipe.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${recipe.category} • ❤️ $likesCount Likes',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      trailing: const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 14),
                                      onTap: () => Navigator.of(context)
                                          .pushNamed('/home'),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Quick links
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getHorizontalPadding(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Links',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: _quickLink(Icons.home_rounded,
                                    'Home Feed', '/home', isDark)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _quickLink(Icons.search_rounded,
                                    'Search', '/search', isDark)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _quickLink(Icons.category_rounded,
                                    'Categories', '/categories', isDark)),
                          ],
                        ),
                      ],
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

  Widget _buildStatsRow(List<Map<String, dynamic>> items, bool isDark) {
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (item['color'] as Color).withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item['icon'] as IconData,
                    color: item['color'] as Color, size: 24),
                const SizedBox(height: 12),
                Text(
                  item['value'] as String,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _quickLink(IconData icon, String label, String route, bool isDark) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
