import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../providers/auth_provider.dart';
import '../../services/recipe_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/mobile_drawer.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeService _recipeService = RecipeService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Recipe? _recipe;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isBookmarked = false;
  bool _isLiked = false;
  int _rating = 0;
  int _likesCount = 0;

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recipe = await _recipeService.getRecipeById(widget.recipeId);
      if (!mounted) return;

      int count = recipe.likes ?? 0;
      int ratingValue = recipe.rating ?? 0;

      setState(() {
        _recipe = recipe;
        _likesCount = count;
        _rating = ratingValue;
        _isLiked = false;
        _isBookmarked = false;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // 1. Instant Smooth Like Toggle
  Future<void> _toggleLike() async {
    final auth = context.read<AuthProvider>();

    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to like this recipe!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final bool newLikedState = !_isLiked;
    final int newCount = newLikedState
        ? _likesCount + 1
        : (_likesCount > 0 ? _likesCount - 1 : 0);

    setState(() {
      _isLiked = newLikedState;
      _likesCount = newCount;
    });

    try {
      final response =
          await _recipeService.toggleLike(widget.recipeId, auth.user!.token);

      if (response.containsKey('likesCount')) {
        setState(() {
          _likesCount =
              (response['likesCount'] as num?)?.toInt() ?? _likesCount;
          if (response.containsKey('liked')) {
            _isLiked = (response['liked'] as bool?) ?? _isLiked;
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLiked = !newLikedState;
        _likesCount = newLikedState
            ? (_likesCount > 0 ? _likesCount - 1 : 0)
            : _likesCount + 1;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update like: $e')),
      );
    }
  }

  // 2. Save / Bookmark Toggle
  Future<void> _toggleSave() async {
    final auth = context.read<AuthProvider>();

    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to save recipes!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final isSaved =
          await _recipeService.toggleSave(widget.recipeId, auth.user!.token);
      if (!mounted) return;

      setState(() {
        _isBookmarked = isSaved;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSaved ? 'Recipe Saved!' : 'Recipe Removed!'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  // 3. Add Rating Logic
  void _setRating(int value) {
    setState(() {
      _rating = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You rated this recipe $value star(s)!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // 4. Add Comment Logic
  Future<void> _addComment() async {
    final auth = context.read<AuthProvider>();

    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add a comment!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    _commentController.clear();

    try {
      await _recipeService.addComment(
          widget.recipeId, commentText, auth.user!.token);
      await _loadRecipe();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: $e')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final isOwner =
        auth.isLoggedIn && _recipe != null && auth.user!.id == _recipe!.ownerId;

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.red.shade400),
                            const SizedBox(height: 12),
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadRecipe,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : _recipe != null
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildHero(isDark),
                                _buildContent(context, isDark, isOwner, auth),
                                const AppFooter(),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: isOwner
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'edit',
                  onPressed: () => Navigator.of(context)
                      .pushNamed('/edit-recipe/${_recipe!.id}'),
                  backgroundColor: AppTheme.accentColor,
                  child: const Icon(Icons.edit_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  heroTag: 'delete',
                  onPressed: () => _confirmDelete(context),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildHero(bool isDark) {
    if (_recipe == null) return const SizedBox.shrink();

    // 🛡️ Web-Safe Null Guards (Prevents Symbol(dartx.toString) JS Crash)
    final String category = _recipe?.category ?? 'General';
    final String title = _recipe?.title ?? 'Untitled Recipe';
    final String ownerName =
        (_recipe?.ownerName != null && _recipe!.ownerName.isNotEmpty)
            ? _recipe!.ownerName
            : 'Chef';
    final String initialLetter =
        ownerName.isNotEmpty ? ownerName[0].toUpperCase() : 'C';
    final String formattedTime = _recipe?.formattedTime ?? 'N/A';
    final String? imageUrl = _recipe?.imageUrl;

    return SizedBox(
      height: 380,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl.trim().isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholderImage(isDark),
            )
          else
            _placeholderImage(isDark),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF1A1A2E)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Text(
                        initialLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'By $ownerName',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.timer_outlined,
                        color: Colors.white.withOpacity(0.7), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    // Top Right Heart Icon & Likes Count
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.white,
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text(
                      '$_likesCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF16213E) : const Color(0xFFFFF3E0),
      child: Icon(Icons.restaurant_rounded,
          size: 80, color: AppTheme.primaryColor.withOpacity(0.3)),
    );
  }

  Widget _buildContent(
      BuildContext context, bool isDark, bool isOwner, AuthProvider auth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getHorizontalPadding(context),
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _actionButton(
                _isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                'Like',
                isDark: isDark,
                isActive: _isLiked,
                onTap: _toggleLike,
              ),
              const SizedBox(width: 12),
              _actionButton(
                _isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                'Save',
                isDark: isDark,
                isActive: _isBookmarked,
                onTap: _toggleSave,
              ),
              const SizedBox(width: 12),
              _actionButton(
                Icons.share_outlined,
                'Share',
                isDark: isDark,
                onTap: () {},
              ),
              const Spacer(),
              // Rating Stars Section
              Row(
                children: List.generate(
                  5,
                  (i) => IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _setRating(i + 1),
                    icon: Icon(
                      i < _rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: AppTheme.primaryColor,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Responsive.isDesktop(context)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: _buildIngredients(isDark)),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: _buildSteps(isDark)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIngredients(isDark),
                    const SizedBox(height: 32),
                    _buildSteps(isDark),
                  ],
                ),
          const SizedBox(height: 40),
          _buildCommentsSection(isDark, auth.isLoggedIn),
          const SizedBox(height: 40),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '← Back to Recipes',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label,
      {required bool isDark, bool isActive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? AppTheme.primaryColor
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? AppTheme.primaryColor
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredients(bool isDark) {
    final ingredientsList = _recipe?.ingredients ?? [];

    return Card(
      color: isDark ? const Color(0xFF16213E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shopping_basket_rounded,
                      color: AppTheme.primaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...ingredientsList.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 7),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSteps(bool isDark) {
    final stepsList = _recipe?.stepsList ?? [];

    return Card(
      color: isDark ? const Color(0xFF16213E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: AppTheme.primaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...stepsList.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value.trim(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(bool isDark, bool isLoggedIn) {
    final comments = _recipe?.comments ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Comments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${comments.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoggedIn)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                  onPressed: _addComment,
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),
        ...comments.map((comment) {
          final author = (comment['author'] as String?) ?? 'User';
          final initial = author.isNotEmpty ? author[0].toUpperCase() : 'U';

          return Card(
            color: isDark ? const Color(0xFF16213E) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            AppTheme.primaryColor.withOpacity(0.15),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        author,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (comment['time'] as String?) ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (comment['text'] as String?) ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recipe?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final token = context.read<AuthProvider>().user?.token;

              if (token == null) return;

              try {
                await _recipeService.deleteRecipe(_recipe!.id, token);
                if (!mounted) return;
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/home', (r) => false);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
