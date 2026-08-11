import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeletons.dart';
import '../../widgets/mobile_drawer.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final RecipeService _recipeService = RecipeService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _selectedCategory;
  List<Recipe> _recipes = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Breakfast',
      'icon': Icons.free_breakfast_rounded,
      'color': Colors.amber,
      'gradient': [Colors.amber, Colors.orange]
    },
    {
      'name': 'Lunch',
      'icon': Icons.lunch_dining_rounded,
      'color': Colors.green,
      'gradient': [Colors.green, Colors.teal]
    },
    {
      'name': 'Dinner',
      'icon': Icons.dinner_dining_rounded,
      'color': Colors.deepOrange,
      'gradient': [Colors.deepOrange, Colors.red]
    },
    {
      'name': 'Desserts',
      'icon': Icons.cake_rounded,
      'color': Colors.pink,
      'gradient': [Colors.pink, Colors.purple]
    },
    {
      'name': 'Healthy',
      'icon': Icons.eco_rounded,
      'color': Colors.teal,
      'gradient': [Colors.teal, Colors.green]
    },
    {
      'name': 'Quick Meals',
      'icon': Icons.flash_on_rounded,
      'color': Colors.orange,
      'gradient': [Colors.orange, Colors.deepOrange]
    },
    {
      'name': 'Vegan',
      'icon': Icons.park_rounded,
      'color': Colors.lightGreen,
      'gradient': [Colors.lightGreen, Colors.green]
    },
    {
      'name': 'Italian',
      'icon': Icons.local_pizza_rounded,
      'color': Colors.red,
      'gradient': [Colors.red, Colors.deepOrange]
    },
    {
      'name': 'Asian',
      'icon': Icons.ramen_dining_rounded,
      'color': Colors.indigo,
      'gradient': [Colors.indigo, Colors.blue]
    },
    {
      'name': 'Snacks',
      'icon': Icons.cookie_rounded,
      'color': Colors.brown,
      'gradient': [Colors.brown, Colors.deepOrange]
    },
    {
      'name': 'Beverages',
      'icon': Icons.local_cafe_rounded,
      'color': Colors.brown,
      'gradient': [Colors.brown, Colors.amber]
    },
    {
      'name': 'Salads',
      'icon': Icons.grass_rounded,
      'color': Colors.green,
      'gradient': [Colors.green, Colors.lime]
    },
  ];

  Future<void> _loadByCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });
    try {
      final recipes = await _recipeService.getAllRecipes(category: category);
      if (mounted) {
        setState(() {
          _recipes = recipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MobileDrawer(),
      body: Column(
        children: [
          AppNavBar(
            currentRoute: '/categories',
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getHorizontalPadding(context),
                      vertical: 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Browse recipes by category',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Category grid
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _categories.map((cat) {
                            final isSelected = cat['name'] == _selectedCategory;
                            return InkWell(
                              onTap: () =>
                                  _loadByCategory(cat['name'] as String),
                              child: Container(
                                width: (MediaQuery.of(context).size.width -
                                        Responsive.getHorizontalPadding(
                                                context) *
                                            2 -
                                        12) /
                                    (Responsive.isMobile(context) ? 2 : 3),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: (cat['gradient'] as List<Color>)
                                        .map((c) => isSelected
                                            ? c
                                            : c.withOpacity(0.15))
                                        .toList(),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? (cat['color'] as Color)
                                        : (cat['color'] as Color)
                                            .withOpacity(0.15),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      cat['icon'] as IconData,
                                      color: isSelected
                                          ? Colors.white
                                          : cat['color'] as Color,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      cat['name'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                                ? Colors.grey.shade300
                                                : const Color(0xFF1A1A2E)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        // Selected category recipes
                        if (_selectedCategory != null) ...[
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Text(
                                '${_selectedCategory} Recipes',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () => setState(() {
                                  _selectedCategory = null;
                                  _recipes = [];
                                }),
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_isLoading)
                            const RecipeCardSkeleton(count: 4)
                          else if (_recipes.isEmpty)
                            EmptyState(
                              icon: Icons.restaurant_rounded,
                              title: 'No recipes in this category',
                              subtitle: 'Be the first to add one!',
                            )
                          else
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        Responsive.getGridColumns(context),
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.72,
                                  ),
                                  itemCount: _recipes.length,
                                  itemBuilder: (context, index) {
                                    return RecipeCard(
                                      recipe: _recipes[index],
                                      onTap: () => Navigator.of(context)
                                          .pushNamed(
                                              '/recipe/${_recipes[index].id}'),
                                      showLike: true,
                                    );
                                  },
                                );
                              },
                            ),
                        ],
                      ],
                    ),
                  ),
                  const AppFooter(), // <--- Ab Footer scrollview ke andar neeche aa gaya hai
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
