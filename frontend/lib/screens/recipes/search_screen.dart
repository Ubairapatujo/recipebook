import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../providers/auth_provider.dart';
import '../../services/recipe_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeletons.dart';
import '../../widgets/mobile_drawer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final RecipeService _recipeService = RecipeService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();

  List<Recipe> _results = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  int _selectedCookTime = 0; // 0 = all

  final List<String> _categories = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Desserts', 'Healthy', 'Quick Meals', 'Vegan', 'Italian', 'Asian'];
  final List<Map<String, dynamic>> _cookTimes = [
    {'label': 'Any Time', 'value': 0},
    {'label': '< 15 min', 'value': 15},
    {'label': '< 30 min', 'value': 30},
    {'label': '< 45 min', 'value': 45},
    {'label': '< 60 min', 'value': 60},
  ];

  Future<void> _search() async {
    setState(() => _isLoading = true);
    try {
      final category = _selectedCategory == 'All' ? null : _selectedCategory;
      final search = _searchController.text.trim().isEmpty ? null : _searchController.text.trim();
      final recipes = await _recipeService.getAllRecipes(
        category: category,
        search: search,
      );
      // Filter by cook time
      if (_selectedCookTime > 0) {
        recipes.removeWhere((r) => r.cookTimeMinutes > _selectedCookTime);
      }
      setState(() {
        _results = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            currentRoute: '/search',
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Search header
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getHorizontalPadding(context),
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search Recipes',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Search bar
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onSubmitted: (_) => _search(),
                                decoration: InputDecoration(
                                  hintText: 'Search recipes, ingredients, cuisines...',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.clear_rounded),
                                    onPressed: () {
                                      _searchController.clear();
                                      _search();
                                    },
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _search,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Icon(Icons.search_rounded),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Filters
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getHorizontalPadding(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category filters
                        SizedBox(
                          height: 44,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              final isSelected = cat == _selectedCategory;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(cat),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() => _selectedCategory = cat);
                                    _search();
                                  },
                                  selectedColor: AppTheme.primaryColor,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Cook time filters
                        SizedBox(
                          height: 36,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _cookTimes.length,
                            itemBuilder: (context, index) {
                              final item = _cookTimes[index];
                              final isSelected = item['value'] == _selectedCookTime;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(
                                    item['label'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() => _selectedCookTime = item['value'] as int);
                                    _search();
                                  },
                                  selectedColor: AppTheme.accentColor,
                                  backgroundColor: isDark ? const Color(0xFF16213E) : Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Results
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.getHorizontalPadding(context),
                      ),
                      child: const RecipeCardSkeleton(count: 4),
                    )
                  else if (_results.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.getHorizontalPadding(context),
                      ),
                      child: EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No recipes found',
                        subtitle: 'Try adjusting your search or filters.',
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.getHorizontalPadding(context),
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_results.length} results',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: Responsive.getGridColumns(context),
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.72,
                                ),
                                itemCount: _results.length,
                                itemBuilder: (context, index) {
                                  final recipe = _results[index];
                                  return RecipeCard(
                                    recipe: recipe,
                                    onTap: () => Navigator.of(context).pushNamed('/recipe/${recipe.id}'),
                                    showBookmark: context.watch<AuthProvider>().isLoggedIn,
                                    showLike: true,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                  const AppFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
