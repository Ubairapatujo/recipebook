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
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/mobile_drawer.dart';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RecipeService _recipeService = RecipeService();

  List<Recipe> _savedRecipes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSavedRecipes();
  }

  Future<void> _fetchSavedRecipes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user?.token;

    if (!authProvider.isLoggedIn || token == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _savedRecipes = [];
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recipes = await _recipeService.getSavedRecipes(token);
      if (mounted) {
        setState(() {
          _savedRecipes = recipes; // Safely assign fetched list
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
          _savedRecipes = []; // Fallback to empty list on error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    final savedCount = _savedRecipes.length; // Safe count

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MobileDrawer(),
      body: Column(
        children: [
          AppNavBar(
            currentRoute: '/saved-recipes',
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchSavedRecipes,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getHorizontalPadding(context),
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saved Recipes',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your personal collection',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bookmark_rounded,
                                    size: 14, color: AppTheme.primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  '$savedCount saved',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Main Content
                      _buildSavedContent(isLoggedIn),

                      const SizedBox(height: 32),
                      const AppFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedContent(bool isLoggedIn) {
    if (!isLoggedIn) {
      return EmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Please log in',
        subtitle: 'You need to be logged in to view your saved recipes.',
        actionLabel: 'Sign In',
        onAction: () => Navigator.of(context).pushNamed('/login'),
      );
    }

    if (_isLoading) {
      return const RecipeCardSkeleton();
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: _fetchSavedRecipes,
      );
    }

    if (_savedRecipes.isEmpty) {
      return EmptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'No saved recipes yet',
        subtitle: 'Bookmark recipes you love to find them here easily.',
        actionLabel: 'Browse Recipes',
        onAction: () => Navigator.of(context).pushNamed('/home'),
      );
    }

    final columns = Responsive.getGridColumns(context);
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
      itemCount: _savedRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _savedRecipes[index];
        return RecipeCard(
          recipe: recipe,
          onTap: () => Navigator.of(context).pushNamed('/recipe/${recipe.id}'),
          showBookmark: true,
          showLike: true,
        );
      },
    );
  }
}
