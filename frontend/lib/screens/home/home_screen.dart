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
import '../../widgets/loading_skeletons.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/mobile_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeService _recipeService = RecipeService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Desserts',
    'Healthy',
    'Quick Meals',
    'Vegan',
    'Italian',
    'Asian',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final category = _selectedCategory == 'All' ? null : _selectedCategory;
      final recipes = await _recipeService.getAllRecipes(category: category);

      if (mounted) {
        setState(() {
          _recipes = recipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
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
            currentRoute: '/home',
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRecipes,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(isDark),
                    // Category filters
                    _buildCategoryFilters(),
                    // Recipe grid
                    _buildRecipeGrid(isDark),
                    const AppFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: context.watch<AuthProvider>().isLoggedIn
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed('/add-recipe'),
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Add Recipe',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getHorizontalPadding(context),
        vertical: 34,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THE COLLECTION',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover Recipes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${_recipes.length} recipes available',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(
            width: Responsive.isMobile(context) ? 48 : 260,
            child: Responsive.isMobile(context)
                ? IconButton(
                    onPressed: () => Navigator.of(context).pushNamed('/search'),
                    icon: const Icon(Icons.search_rounded),
                    color: AppTheme.primaryColor,
                  )
                : TextField(
                    readOnly: true,
                    onTap: () => Navigator.of(context).pushNamed('/search'),
                    decoration: const InputDecoration(
                      hintText: 'Search the pantry...',
                      prefixIcon: Icon(Icons.search_rounded, size: 19),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedCategory = cat);
                _loadRecipes();
              },
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeGrid(bool isDark) {
    final columns = Responsive.getGridColumns(context);
    final padding = Responsive.getHorizontalPadding(context);

    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: const RecipeCardSkeleton(),
      );
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: _loadRecipes,
      );
    }

    if (_recipes.isEmpty) {
      return EmptyState(
        icon: Icons.restaurant_rounded,
        title: 'No recipes found',
        subtitle: _selectedCategory == 'All'
            ? 'Be the first to share a recipe!'
            : 'Try selecting a different category or tap "All".',
        actionLabel: 'Add Your First Recipe',
        onAction: () => Navigator.of(context).pushNamed('/add-recipe'),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive height fix for grid cards
          final aspectRatio = switch (columns) {
            1 => 0.95,
            2 => 0.85,
            3 => 0.80,
            _ => 0.75,
          };

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: aspectRatio,
            ),
            itemCount: _recipes.length,
            itemBuilder: (context, index) {
              final recipe = _recipes[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () =>
                    Navigator.of(context).pushNamed('/recipe/${recipe.id}'),
                showBookmark: context.watch<AuthProvider>().isLoggedIn,
                showLike: true,
              );
            },
          );
        },
      ),
    );
  }
}
