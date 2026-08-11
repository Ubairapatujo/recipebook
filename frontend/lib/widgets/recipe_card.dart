import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';
import 'safe_network_image.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final bool showBookmark;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;
  final bool showLike;
  final int? likes;
  final bool isLiked;
  final VoidCallback? onLikeTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.showBookmark = true,
    this.isBookmarked = false,
    this.onBookmarkTap,
    this.showLike = false,
    this.likes,
    this.isLiked = false,
    this.onLikeTap,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final recipe = widget.recipe;
    final cardColor = dark ? AppTheme.cardDark : AppTheme.paperLight;

    // Wrapped in Align: if this card sits inside a GridView cell that's
    // taller than the card's own content (fixed childAspectRatio), the
    // card now hugs its natural height and sticks to the top of the cell
    // instead of stretching and leaving blank space inside itself.
    return Align(
      alignment: Alignment.topCenter,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: double.infinity,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovering ? -5.0 : 0.0)
            ..scale(_isHovering ? 1.01 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isHovering
                    ? AppTheme.primaryColor.withOpacity(0.18)
                    : Colors.black.withOpacity(dark ? 0.18 : 0.06),
                blurRadius: _isHovering ? 18 : 8,
                offset: Offset(0, _isHovering ? 10 : 3),
              ),
            ],
          ),
          child: Material(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Compact height - removes blank space
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImageSection(recipe),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          recipe.category.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          recipe.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor:
                                  AppTheme.accentColor.withOpacity(0.45),
                              child: Text(
                                recipe.ownerName.isNotEmpty
                                    ? recipe.ownerName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppTheme.ink,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                recipe.ownerName,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                            Icon(
                              Icons.schedule_outlined,
                              size: 13,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recipe.formattedTime,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(Recipe recipe) {
    return AspectRatio(
      aspectRatio: 16 / 10, // Dynamic height according to width
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: _isHovering ? 1.05 : 1,
            child: SafeNetworkImage(
              url: recipe.imageUrl,
              category: recipe.category,
              label: recipe.title, // Sends recipe title for relevant pictures
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [
                if (widget.showLike && widget.onLikeTap != null)
                  _roundAction(
                    icon: widget.isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    active: widget.isLiked,
                    onTap: widget.onLikeTap!,
                  ),
                if (widget.showLike &&
                    widget.onLikeTap != null &&
                    widget.showBookmark &&
                    widget.onBookmarkTap != null)
                  const SizedBox(width: 6),
                if (widget.showBookmark && widget.onBookmarkTap != null)
                  _roundAction(
                    icon: widget.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    active: widget.isBookmarked,
                    onTap: widget.onBookmarkTap!,
                  ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.ink.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                recipe.formattedTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundAction({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Material(
      color: active
          ? AppTheme.primaryColor
          : AppTheme.paperLight.withOpacity(0.92),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(
            icon,
            size: 15,
            color: active ? Colors.white : AppTheme.ink,
          ),
        ),
      ),
    );
  }
}
