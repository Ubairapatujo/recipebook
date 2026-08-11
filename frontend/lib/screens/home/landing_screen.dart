import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../providers/theme_provider.dart';

/// ---------------------------------------------------------------------------
/// DESIGN TOKENS — "Kitchen Index Card"
/// A self-contained brand palette for the public marketing surface. It does
/// not read from AppTheme on purpose: the landing page is allowed its own
/// voice, while the logged-in app keeps using AppTheme.light/darkTheme.
/// ---------------------------------------------------------------------------
class _Ink {
  // These are set once per build via _Ink.configure(isDark), called at the
  // top of LandingScreen.build(). This keeps every other widget's `_Ink.xxx`
  // reference unchanged while making the whole palette dark-mode aware.
  static late Color paper; // warm parchment background / near-black in dark
  static late Color paperSoft; // card / section fill
  static late Color ink; // primary text
  static late Color inkSoft; // secondary text
  static late Color chili; // primary accent / CTA
  static late Color chiliDark;
  static late Color herb; // secondary accent
  static late Color butter; // highlight accent (same in both modes)
  static late Color line; // hairline / divider / dashes

  // Fixed regardless of theme — the footer band is always a dark coffee
  // color, on purpose, so it reads as a distinct "closing" section.
  static const Color footerBg = Color(0xFF34241E);

  // Fixed light color for text/icons sitting on solid accent surfaces
  // (the chili logo mark, chili CTA banner, dark footer band) — these
  // surfaces don't flip with the theme, so their contrast color shouldn't
  // either.
  static const Color onAccent = Color(0xFFFFF8ED);

  static void configure(bool isDark) {
    // Palette: Warm Ivory / Soft Tomato / Butter Gold / Soft Olive /
    // Burnt Apricot / Oat Beige / Espresso / Sage Cream.
    if (isDark) {
      paper = const Color(0xFF34241E); // Espresso as the dark background
      paperSoft = const Color(0xFF422F27); // lifted card fill
      ink = const Color(0xFFFFF8ED); // Warm Ivory text on dark
      inkSoft = const Color(0xFFD9C7AE); // muted oat tone for secondary text
      chili = const Color(0xFFD9714F); // Soft Tomato, brightened for contrast
      chiliDark =
          const Color(0xFFC9573D); // base Soft Tomato as the deeper variant
      herb = const Color(0xFF8B9974); // Soft Olive, lifted for dark bg
      butter = const Color(0xFFE7B84B); // Butter Gold — same in both modes
      line = const Color(0xFF4E392E); // dark hairline
    } else {
      paper = const Color(0xFFFFF8ED); // Warm Ivory
      paperSoft = const Color(0xFFE8D6BA); // Oat Beige
      ink = const Color(0xFF34241E); // Espresso
      inkSoft = const Color(0xFF6B5847); // muted espresso for secondary text
      chili = const Color(0xFFC9573D); // Soft Tomato
      chiliDark = const Color(0xFFA8442E); // deeper Soft Tomato
      herb = const Color(0xFF71805B); // Soft Olive
      butter = const Color(0xFFE7B84B); // Butter Gold
      line = const Color(0xFFDCC9A3); // hairline derived from Oat Beige
    }
  }
}

class _Type {
  static TextStyle display(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.fraunces(
        fontSize: size,
        height: 1.05,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? _Ink.ink,
        letterSpacing: -0.5,
      );

  static TextStyle body(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.workSans(
        fontSize: size,
        height: 1.5,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? _Ink.inkSoft,
      );

  static TextStyle mono(double size, {Color? color, double? spacing}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: FontWeight.w500,
        letterSpacing: spacing ?? 1.4,
        color: color ?? _Ink.inkSoft,
      );
}

/// Maps a recipe's category string to an accent color + icon so real
/// recipes (which have no icon field) still get a themed tile.
class _CategoryStyle {
  final Color accent;
  final IconData icon;
  const _CategoryStyle(this.accent, this.icon);

  static _CategoryStyle of(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return _CategoryStyle(_Ink.butter, Icons.free_breakfast_outlined);
      case 'lunch':
        return _CategoryStyle(_Ink.herb, Icons.lunch_dining_outlined);
      case 'dinner':
        return _CategoryStyle(_Ink.chili, Icons.dinner_dining_outlined);
      case 'desserts':
        return _CategoryStyle(_Ink.chiliDark, Icons.cake_outlined);
      case 'healthy':
        return _CategoryStyle(_Ink.herb, Icons.eco_outlined);
      case 'quick meals':
        return _CategoryStyle(_Ink.chili, Icons.bolt_outlined);
      case 'vegan':
        return _CategoryStyle(_Ink.herb, Icons.grass_outlined);
      case 'italian':
        return _CategoryStyle(_Ink.chiliDark, Icons.local_pizza_outlined);
      case 'asian':
        return _CategoryStyle(_Ink.chili, Icons.ramen_dining_outlined);
      default:
        return _CategoryStyle(_Ink.herb, Icons.restaurant_outlined);
    }
  }
}

/// ---------------------------------------------------------------------------
/// LANDING SCREEN
/// ---------------------------------------------------------------------------
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  static const double _desktopBreak = 940;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  List<Recipe> _recipes = [];
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      final recipes = await RecipeService()
          .getAllRecipes()
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      // Most recent first, capped to a handful for the landing strip.
      final sorted = [...recipes]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _recipes = sorted.take(8).toList();
        _loading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _Ink.configure(Theme.of(context).brightness == Brightness.dark);
    return Scaffold(
      backgroundColor: _Ink.paper,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= LandingScreen._desktopBreak;
          final hPad = isDesktop ? 64.0 : 20.0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _NavBar(isDesktop: isDesktop, hPad: hPad),
                _Hero(isDesktop: isDesktop, hPad: hPad),
                _HowItWorks(isDesktop: isDesktop, hPad: hPad),
                _FeaturedRecipes(
                  isDesktop: isDesktop,
                  hPad: hPad,
                  recipes: _recipes,
                  loading: _loading,
                  hasError: _hasError,
                ),
                _Categories(isDesktop: isDesktop, hPad: hPad),
                _CtaBanner(isDesktop: isDesktop, hPad: hPad),
                _Footer(isDesktop: isDesktop, hPad: hPad),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// NAV BAR
/// ---------------------------------------------------------------------------
class _NavBar extends StatelessWidget {
  const _NavBar({required this.isDesktop, required this.hPad});
  final bool isDesktop;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _Ink.line, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _Ink.chili,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.restaurant_menu, color: _Ink.onAccent, size: 18),
          ),
          const SizedBox(width: 10),
          Text('RecipeBook', style: _Type.display(20, weight: FontWeight.w700)),
          const Spacer(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              onPressed: themeProvider.toggleTheme,
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: _Ink.ink,
              ),
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 8),
            _NavLink('Home', onTap: () => Navigator.pushNamed(context, '/')),
            const SizedBox(width: 28),
            _NavLink('Explore',
                onTap: () => Navigator.pushNamed(context, '/home')),
            const SizedBox(width: 28),
            _NavLink('Categories',
                onTap: () => Navigator.pushNamed(context, '/categories')),
            const SizedBox(width: 28),
            _NavLink('About',
                onTap: () => Navigator.pushNamed(context, '/about')),
            const SizedBox(width: 32),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text('Sign in', style: _Type.mono(12.5, color: _Ink.ink)),
            ),
            const SizedBox(width: 8),
            _PillButton(
              label: 'Get Started',
              filled: true,
              onTap: () => Navigator.pushNamed(context, '/register'),
            ),
          ] else
            IconButton(
              onPressed: () => _openMobileMenu(context),
              icon: Icon(Icons.menu, color: _Ink.ink),
            ),
        ],
      ),
    );
  }

  void _openMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _Ink.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Menu', style: _Type.mono(12, spacing: 2)),
              const SizedBox(height: 16),
              ...{
                'Home': '/',
                'Explore': '/home',
                'Categories': '/categories',
                'About': '/about',
              }.entries.map(
                    (e) => InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, e.value);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(e.key, style: _Type.display(20)),
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              _PillButton(
                label: 'Get Started',
                filled: true,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/register');
                },
              ),
              const SizedBox(height: 10),
              _PillButton(
                label: 'Sign in',
                filled: false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink(this.label, {required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label.toUpperCase(),
        style: _Type.mono(12.5, color: _Ink.ink, spacing: 1.2),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.icon,
    this.onPhoto = false,
  });
  final String label;
  final bool filled;
  final VoidCallback onTap;
  final IconData? icon;
  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    final outlineColor = onPhoto ? Colors.white : _Ink.ink;
    return Material(
      color: filled ? _Ink.chili : Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: filled ? null : Border.all(color: outlineColor, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: _Type.body(
                  14.5,
                  weight: FontWeight.w600,
                  color: filled ? _Ink.onAccent : outlineColor,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon,
                    size: 16, color: filled ? _Ink.onAccent : outlineColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// HERO
/// ---------------------------------------------------------------------------
class _Hero extends StatelessWidget {
  const _Hero({required this.isDesktop, required this.hPad});
  final bool isDesktop;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isDesktop ? 720 : 640,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed background photo.
          Image.asset(
            'assets/images/hero_pasta.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) => Container(color: _Ink.paperSoft),
          ),
          // Dark scrim so the headline stays readable over the photo,
          // strongest behind the text and fading toward the right.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.62),
                  Colors.black.withOpacity(0.38),
                  Colors.black.withOpacity(0.12),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                hPad, isDesktop ? 72 : 40, hPad, isDesktop ? 72 : 40),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _HeroText(isDesktop: isDesktop, onPhoto: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.isDesktop, this.onPhoto = false});
  final bool isDesktop;
  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    final headlineSize = isDesktop ? 58.0 : 38.0;
    final headlineColor = onPhoto ? Colors.white : null;
    final bodyColor = onPhoto ? Colors.white.withOpacity(0.88) : null;
    final captionColor = onPhoto ? Colors.white.withOpacity(0.85) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 💥 YAHAN THODA EXTRA GAP DO TAAKE WATERMARK SE NEECHE AAH JAYE AUR SAAF DIKHE
        const SizedBox(height: 35),

        Row(
          children: [
            Container(
              width: 28,
              height: 2.5,
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255, 240, 233, 231), // Bright Red-Orange
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'THE ULTIMATE RECIPE ARCHIVE',
              style: _Type.mono(
                12.5,
                color: const Color.fromARGB(255, 222, 216, 214),
              ).copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Cook what\nyou crave.',
            style: _Type.display(headlineSize, color: headlineColor)),
        const SizedBox(height: 20),
        SizedBox(
          width: 460,
          child: Text(
            'Every recipe here comes from a real home cook: exact quantities, '
            'the steps that actually work, and the swaps people wish they knew '
            'sooner. Save it, tweak it, cook it again.',
            style: _Type.body(15.5, color: bodyColor),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _PillButton(
              label: 'Start Cooking',
              filled: true,
              icon: Icons.arrow_forward,
              onTap: () => Navigator.pushNamed(context, '/register'),
            ),
            _PillButton(
              label: 'Find your next favorite',
              filled: false,
              onPhoto: onPhoto,
              onTap: () => Navigator.pushNamed(context, '/categories'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Icon(Icons.circle,
                size: 6, color: onPhoto ? Colors.white : _Ink.herb),
            const SizedBox(width: 8),
            Text('FREE TO JOIN · NO CREDIT CARD',
                style: _Type.mono(11.5, color: captionColor)),
          ],
        ),
      ],
    );
  }
}

class _IndexCardStack extends StatelessWidget {
  const _IndexCardStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          'assets/images/hero_pasta.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          // Falls back to the original hand-drawn card mockup if the
          // image file hasn't been added to assets/images/ yet.
          errorBuilder: (_, __, ___) => const _IndexCardStackFallback(),
        ),
      ),
    );
  }
}

class _IndexCardStackFallback extends StatelessWidget {
  const _IndexCardStackFallback();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 18,
          child: Transform.rotate(
            angle: -0.09,
            child: _RecipeCardMock(
              color: _Ink.herb.withOpacity(0.14),
              borderColor: _Ink.herb,
              title: 'Brown Butter Pasta',
              lines: const ['200g pasta', '3 tbsp butter', 'sage, lemon zest'],
            ),
          ),
        ),
        Transform.rotate(
          angle: 0.04,
          child: _RecipeCardMock(
            color: _Ink.paperSoft,
            borderColor: _Ink.ink,
            title: 'Smoky Paprika Chicken',
            lines: const [
              '4 thighs, bone-in',
              '2 tsp smoked paprika',
              'roast 35 min · 200°C'
            ],
          ),
        ),
        Positioned(
          right: 18,
          top: -6,
          child: Transform.rotate(
            angle: 0.18,
            child: Container(
              width: 82,
              height: 82,
              decoration:
                  BoxDecoration(color: _Ink.chili, shape: BoxShape.circle),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Text(
                'TODAY\'S\nPICK',
                textAlign: TextAlign.center,
                style: _Type.mono(10, color: _Ink.onAccent, spacing: 0.6),
              ),
            ),
          ),
        ),
        Positioned(
          left: 4,
          bottom: 4,
          child: Transform.rotate(
            angle: -0.06,
            child: Container(
              width: 34,
              height: 34,
              decoration:
                  BoxDecoration(color: _Ink.butter, shape: BoxShape.circle),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecipeCardMock extends StatelessWidget {
  const _RecipeCardMock({
    required this.color,
    required this.borderColor,
    required this.title,
    required this.lines,
  });
  final Color color;
  final Color borderColor;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 268,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor.withOpacity(0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              9,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _Ink.line, shape: BoxShape.circle)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: _Type.display(19, weight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.remove, size: 12, color: _Ink.inkSoft),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(l, style: _Type.mono(11.5, spacing: 0.2))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// HOW IT WORKS
/// ---------------------------------------------------------------------------
class _HowItWorks extends StatelessWidget {
  const _HowItWorks({required this.isDesktop, required this.hPad});
  final bool isDesktop;
  final double hPad;

  static const _steps = [
    (
      '01',
      'Discover',
      'Search by ingredient, cuisine, or the thirty minutes you actually have.'
    ),
    (
      '02',
      'Save & Cook',
      'Bookmark it, scale the servings, follow the steps in order.'
    ),
    (
      '03',
      'Share Back',
      'Post the version you made — swaps, timings, what worked.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = _steps
        .map((s) => _StepCard(number: s.$1, title: s.$2, desc: s.$3))
        .toList();

    return Container(
      color: _Ink.paperSoft,
      padding:
          EdgeInsets.symmetric(horizontal: hPad, vertical: isDesktop ? 72 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HOW IT WORKS', style: _Type.mono(12.5, color: _Ink.chili)),
          const SizedBox(height: 10),
          Text('From craving to plate.',
              style: _Type.display(isDesktop ? 34 : 26)),
          SizedBox(height: isDesktop ? 44 : 32),
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      Expanded(child: items[i]),
                      if (i != items.length - 1) const SizedBox(width: 32),
                    ],
                  ],
                )
              : Column(
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      items[i],
                      if (i != items.length - 1) const SizedBox(height: 28),
                    ],
                  ],
                ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard(
      {required this.number, required this.title, required this.desc});
  final String number;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _Ink.herb, width: 1.4),
          ),
          alignment: Alignment.center,
          child: Text(number, style: _Type.mono(13, color: _Ink.herb)),
        ),
        const SizedBox(height: 16),
        Text(title, style: _Type.display(20, weight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(desc, style: _Type.body(14)),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// FEATURED RECIPES — now wired to the real backend via RecipeService.
/// Shows a loading strip while fetching, a friendly empty/error state if the
/// backend has no data or is unreachable, and real recipe cards otherwise.
/// ---------------------------------------------------------------------------
class _FeaturedRecipes extends StatelessWidget {
  const _FeaturedRecipes({
    required this.isDesktop,
    required this.hPad,
    required this.recipes,
    required this.loading,
    required this.hasError,
  });
  final bool isDesktop;
  final double hPad;
  final List<Recipe> recipes;
  final bool loading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: hPad, vertical: isDesktop ? 72 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FROM THE COMMUNITY',
                        style: _Type.mono(12.5, color: _Ink.chili)),
                    const SizedBox(height: 10),
                    Text('Everyone\'s making these.',
                        style: _Type.display(isDesktop ? 34 : 26)),
                  ],
                ),
              ),
              if (isDesktop && recipes.isNotEmpty)
                _PillButton(
                  label: 'View all',
                  filled: false,
                  icon: Icons.arrow_forward,
                  onTap: () => Navigator.pushNamed(context, '/categories'),
                ),
            ],
          ),
          SizedBox(height: isDesktop ? 40 : 28),
          SizedBox(
            height: 240,
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (loading) {
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, i) => _RecipeTileSkeleton(),
      );
    }

    if (hasError) {
      return _InlineNotice(
        icon: Icons.wifi_off_rounded,
        title: 'Backend connection needed',
        message: 'Could not reach the RecipeBook backend. Start the '
            'Spring Boot server and refresh this page.',
      );
    }

    if (recipes.isEmpty) {
      return _InlineNotice(
        icon: Icons.menu_book_outlined,
        title: 'No recipes yet',
        message: 'Be the first to add one — it will show up here.',
        actionLabel: 'Add a recipe',
        onAction: () => Navigator.pushNamed(context, '/register'),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: recipes.length,
      separatorBuilder: (_, __) => const SizedBox(width: 18),
      itemBuilder: (context, i) {
        final recipe = recipes[i];
        final style = _CategoryStyle.of(recipe.category);
        return _RecipeTile(
          title: recipe.title,
          accent: style.accent,
          icon: style.icon,
          time: '${recipe.cookTimeMinutes} min',
          level: recipe.category,
          onTap: () => Navigator.pushNamed(context, '/recipe/${recipe.id}'),
        );
      },
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Ink.paperSoft,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _Ink.line),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: _Ink.inkSoft),
          const SizedBox(height: 10),
          Text(title, style: _Type.display(15, weight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(message, style: _Type.body(12.5), textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            _PillButton(label: actionLabel!, filled: true, onTap: onAction!),
          ],
        ],
      ),
    );
  }
}

class _RecipeTileSkeleton extends StatelessWidget {
  const _RecipeTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: _Ink.paperSoft,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _Ink.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 108,
            decoration: const BoxDecoration(
              color: Color(0xFFE8DCC4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 14, width: 130, color: const Color(0xFFE8DCC4)),
                const SizedBox(height: 10),
                Container(
                    height: 10, width: 90, color: const Color(0xFFE8DCC4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({
    required this.title,
    required this.accent,
    required this.icon,
    required this.time,
    required this.level,
    this.onTap,
  });
  final String title;
  final Color accent;
  final IconData icon;
  final String time;
  final String level;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 210,
        decoration: BoxDecoration(
          color: _Ink.paperSoft,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _Ink.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 108,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.14),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 40, color: accent),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _Type.display(15.5, weight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 13, color: _Ink.inkSoft),
                      const SizedBox(width: 4),
                      Text(time, style: _Type.mono(10.5)),
                      const SizedBox(width: 12),
                      Icon(Icons.local_offer_outlined,
                          size: 13, color: _Ink.inkSoft),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          level,
                          style: _Type.mono(10.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}

/// ---------------------------------------------------------------------------
/// CATEGORIES
/// ---------------------------------------------------------------------------
class _Categories extends StatelessWidget {
  const _Categories({required this.isDesktop, required this.hPad});
  final bool isDesktop;
  final double hPad;

  static const _cats = [
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
  Widget build(BuildContext context) {
    return Container(
      color: _Ink.paperSoft,
      padding:
          EdgeInsets.symmetric(horizontal: hPad, vertical: isDesktop ? 56 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BROWSE BY CATEGORY',
              style: _Type.mono(12.5, color: _Ink.chili)),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _cats.map((c) => _CategoryChip(label: c)).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _Ink.paper,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.pushNamed(context, '/categories'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _Ink.line),
          ),
          child: Text(label,
              style:
                  _Type.body(13.5, color: _Ink.ink, weight: FontWeight.w500)),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// CTA BANNER
/// ---------------------------------------------------------------------------
class _CtaBanner extends StatelessWidget {
  const _CtaBanner({required this.isDesktop, required this.hPad});
  final bool isDesktop;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _Ink.chili,
      padding:
          EdgeInsets.symmetric(horizontal: hPad, vertical: isDesktop ? 64 : 44),
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  child: Text(
                    'Got a recipe worth sharing?',
                    style: _Type.display(32,
                        color: _Ink.onAccent, weight: FontWeight.w600),
                  ),
                ),
                _PillButton(
                  label: 'Create an account',
                  filled: false,
                  onTap: () => Navigator.pushNamed(context, '/register'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Got a recipe worth sharing?',
                  style: _Type.display(26,
                      color: _Ink.onAccent, weight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                _PillButton(
                  label: 'Create an account',
                  filled: false,
                  onTap: () => Navigator.pushNamed(context, '/register'),
                ),
              ],
            ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// FOOTER
/// ---------------------------------------------------------------------------
class _Footer extends StatelessWidget {
  const _Footer({required this.isDesktop, required this.hPad});
  final bool isDesktop;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _Ink.footerBg,
      padding: EdgeInsets.fromLTRB(hPad, isDesktop ? 56 : 40, hPad, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _FooterBrand()),
                    Expanded(
                        child: _FooterLinks('Explore',
                            const ['Home', 'Categories', 'About', 'Contact'])),
                    Expanded(
                        child: _FooterLinks('Account',
                            const ['Sign in', 'Get Started', 'Dashboard'])),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FooterBrand(),
                    const SizedBox(height: 28),
                    _FooterLinks('Explore',
                        const ['Home', 'Categories', 'About', 'Contact']),
                    const SizedBox(height: 20),
                    _FooterLinks('Account',
                        const ['Sign in', 'Get Started', 'Dashboard']),
                  ],
                ),
          const SizedBox(height: 36),
          Container(height: 1, color: Colors.white.withOpacity(0.12)),
          const SizedBox(height: 20),
          Text('© ${DateTime.now().year} RecipeBook. Made by home cooks.',
              style: _Type.mono(11, color: Colors.white54)),
        ],
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: _Ink.chili, borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child:
                  Icon(Icons.restaurant_menu, color: _Ink.onAccent, size: 15),
            ),
            const SizedBox(width: 10),
            Text('RecipeBook',
                style: _Type.display(18,
                    color: _Ink.onAccent, weight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 260,
          child: Text(
            'A recipe box built by the people who actually cook from it.',
            style: _Type.body(13, color: Colors.white60),
          ),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks(this.heading, this.links);
  final String heading;
  final List<String> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading.toUpperCase(),
            style: _Type.mono(11, color: Colors.white38, spacing: 1.2)),
        const SizedBox(height: 14),
        ...links.map(
          (l) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(l, style: _Type.body(13.5, color: Colors.white70)),
          ),
        ),
      ],
    );
  }
}
