import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

/// A vibrant hero section for the RecipeBook landing page.
class Hero3DSection extends StatefulWidget {
  const Hero3DSection({
    super.key,
    required this.isDark,
    required this.statsLoading,
    required this.recipeCount,
    required this.categoryCount,
    required this.cookCount,
    required this.avgRating,
    this.statsError,
    required this.onExplore,
    required this.onJoin,
  });

  final bool isDark;
  final bool statsLoading;
  final int recipeCount;
  final int categoryCount;
  final int cookCount;
  final double? avgRating;
  final String? statsError;
  final VoidCallback onExplore;
  final VoidCallback onJoin;

  @override
  State<Hero3DSection> createState() => _Hero3DSectionState();
}

class _Hero3DSectionState extends State<Hero3DSection>
    with TickerProviderStateMixin {
  late final AnimationController _bob;

  double _px = 0;
  double _py = 0;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent e, Size size) {
    setState(() {
      _px = ((e.localPosition.dx / size.width) * 2 - 1).clamp(-1.0, 1.0);
      _py = ((e.localPosition.dy / size.height) * 2 - 1).clamp(-1.0, 1.0);
    });
  }

  void _resetTilt() => setState(() {
        _px = 0;
        _py = 0;
      });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isDark = widget.isDark;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF3A2922), const Color(0xFF211914)]
              : [AppTheme.paper, AppTheme.paperLight],
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF604A3A) : AppTheme.border,
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: _blob(
                AppTheme.accentColor.withOpacity(isDark ? 0.25 : 0.35), 220),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: _blob(
                AppTheme.primaryColor.withOpacity(isDark ? 0.3 : 0.3), 280),
          ),
          Positioned(
            top: 120,
            right: 60,
            child: _blob(AppTheme.primaryLight.withOpacity(0.25), 120),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.getHorizontalPadding(context),
              vertical: isMobile ? 36 : 60,
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContent(context),
                      const SizedBox(height: 32),
                      _buildImageStage(interactive: false),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 5, child: _buildContent(context)),
                      const SizedBox(width: 48),
                      Expanded(
                          flex: 6, child: _buildImageStage(interactive: true)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = widget.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 💥 NEW HIGH-CONTRAST COLOR TAGLINE (BRIGHT NEON COLOR WITH CONTAINER)
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF3D00), // Bright Neon Orange/Red Background
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: const Text(
            'THE ULTIMATE RECIPE ARCHIVE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.white, // White crisp text
              letterSpacing: 2.0,
            ),
          ),
        ),

        // Community Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryLight],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            widget.statsLoading
                ? 'A GROWING COMMUNITY'
                : widget.statsError != null
                    ? 'BACKEND CONNECTION NEEDED'
                    : (widget.cookCount >= 10
                        ? 'TRUSTED BY ${widget.cookCount}+ HOME COOKS'
                        : 'JOIN OUR COOKING COMMUNITY'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),

        const SizedBox(height: 20),

        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 42 : 56,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -1.5,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
            children: [
              const TextSpan(text: 'Cook what\n'),
              TextSpan(
                text: 'you crave.',
                style: TextStyle(
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                    ).createShader(const Rect.fromLTWH(0, 0, 250, 70)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Every recipe here comes from a real home cook: exact quantities, the steps that actually work, and the swaps people wish they knew sooner.',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: widget.onExplore,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 6,
                shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Start Cooking ➔',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 14),
            OutlinedButton(
              onPressed: widget.onJoin,
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    isDark ? Colors.white : const Color(0xFF1A1A2E),
                side: BorderSide(
                  color: (isDark ? Colors.white : const Color(0xFF1A1A2E))
                      .withOpacity(0.25),
                  width: 1.5,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Find your next favorite',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Row(
          children: [
            SizedBox(
              width: 110,
              height: 36,
              child: Stack(
                children: List.generate(4, (i) {
                  final colors = [
                    AppTheme.primaryColor,
                    AppTheme.accentColor,
                    AppTheme.primaryLight,
                    AppTheme.primaryDark,
                  ];
                  return Positioned(
                    left: i * 24.0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isDark ? const Color(0xFF1A1A2E) : Colors.white,
                          width: 2.5,
                        ),
                        color: colors[i],
                      ),
                      child: const Icon(Icons.person_rounded,
                          size: 18, color: Colors.white),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'FREE TO JOIN  •  NO CREDIT CARD REQUIRED',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageStage({required bool interactive}) {
    const stageHeight = 460.0;

    final stage = AnimatedBuilder(
      animation: _bob,
      builder: (context, _) {
        final bob = math.sin(_bob.value * math.pi * 2) * 6;
        final tiltX = -_py * 0.06;
        final tiltY = _px * 0.08;

        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateX(tiltX)
          ..rotateY(tiltY);

        return Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: SizedBox(
            height: stageHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(0, bob),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.35),
                            blurRadius: 50,
                            offset: const Offset(0, 24),
                            spreadRadius: -10,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: _heroImage(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
                  left: -20,
                  child: Transform.translate(
                    offset: Offset(_px * -10, bob * -0.5),
                    child: _statBadge(
                      icon: Icons.restaurant_menu_rounded,
                      value: widget.statsLoading || widget.statsError != null
                          ? '—'
                          : '${widget.recipeCount}',
                      label: 'Recipes',
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 90,
                  right: -16,
                  child: Transform.translate(
                    offset: Offset(_px * 12, bob * 0.6),
                    child: _statBadge(
                      icon: Icons.category_rounded,
                      value: widget.statsLoading || widget.statsError != null
                          ? '—'
                          : '${widget.categoryCount}',
                      label: 'Categories',
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -18,
                  left: 40,
                  child: Transform.translate(
                    offset: Offset(_px * -8, bob * 0.8),
                    child: _statBadge(
                      icon: Icons.star_rounded,
                      value: widget.statsLoading ||
                              widget.statsError != null ||
                              widget.avgRating == null
                          ? 'New'
                          : widget.avgRating!.toStringAsFixed(1),
                      label: 'Rating',
                      color: Colors.amber.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!interactive) return stage;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, stageHeight);
        return MouseRegion(
          onHover: (e) => _onHover(e, size),
          onExit: (_) => _resetTilt(),
          child: stage,
        );
      },
    );
  }

  Widget _heroImage() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1621996346565-e3d5d6281288?w=1200&q=80',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppTheme.primaryColor.withOpacity(0.8),
                child: const Center(
                  child: Icon(Icons.restaurant, size: 80, color: Colors.white),
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBadge({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final isDark = widget.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
