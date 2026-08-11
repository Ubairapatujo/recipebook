import 'package:flutter/material.dart';

class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.label,
    this.category,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? label;
  final String? category;

  static const _deadHosts = [
    'source.unsplash.com',
    'unsplash.it',
    'lorempixel.com',
  ];

  bool _isDeadHost(String u) => _deadHosts.any((h) => u.contains(h));

  bool _hasWord(String text, String word) {
    return RegExp(r'\b' + RegExp.escape(word) + r'\b').hasMatch(text);
  }

  // Purely text-based match for existing database dishes
  String? _getExactFoodImage() {
    final text = '${label ?? ''} ${category ?? ''}'.toLowerCase();
    bool has(String w) => _hasWord(text, w);
    bool phrase(String p) => text.contains(p);

    if (has('dosa')) {
      return 'https://images.pexels.com/photos/5560763/pexels-photo-5560763.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('idli') || has('sambar')) {
      return 'https://images.pexels.com/photos/4331490/pexels-photo-4331490.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('samosa')) {
      return 'https://images.pexels.com/photos/4449068/pexels-photo-4449068.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('tiramisu')) {
      return 'https://images.pexels.com/photos/6880219/pexels-photo-6880219.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('caprese')) {
      return 'https://images.pexels.com/photos/1213710/pexels-photo-1213710.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('pulao')) {
      return 'https://images.pexels.com/photos/723198/pexels-photo-723198.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('wrap')) {
      return 'https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('burger') || has('sandwich')) {
      return 'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('pancake')) {
      return 'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('oats') || has('berries')) {
      return 'https://images.pexels.com/photos/1099680/pexels-photo-1099680.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('cake') ||
        has('lava') ||
        has('chocolate') ||
        has('cheesecake')) {
      return 'https://images.pexels.com/photos/2144112/pexels-photo-2144112.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('salad')) {
      return 'https://images.pexels.com/photos/1059905/pexels-photo-1059905.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (phrase('stir fry') || has('noodle')) {
      return 'https://images.pexels.com/photos/1410235/pexels-photo-1410235.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (phrase('fried rice')) {
      return 'https://images.pexels.com/photos/3926123/pexels-photo-3926123.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('buddha') || has('chickpea') || has('bowl')) {
      return 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('chow') || has('mein')) {
      return 'https://images.pexels.com/photos/2347311/pexels-photo-2347311.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('pizza') || has('margherita')) {
      return 'https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('pasta')) {
      return 'https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('salmon')) {
      return 'https://images.pexels.com/photos/842142/pexels-photo-842142.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('lentil') || has('soup')) {
      return 'https://images.pexels.com/photos/539451/pexels-photo-539451.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('thai') || has('basil')) {
      return 'https://images.pexels.com/photos/699953/pexels-photo-699953.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('biryani')) {
      return 'https://images.pexels.com/photos/1624487/pexels-photo-1624487.jpeg?auto=compress&cs=tinysrgb&w=800';
    } else if (has('beef') || has('masala') || has('butter') || has('curry')) {
      return 'https://images.pexels.com/photos/2474661/pexels-photo-2474661.jpeg?auto=compress&cs=tinysrgb&w=800';
    }

    // Kuch match na hone par NO default image (biryani deleted permanently)
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isFoodish = url != null && url!.contains('foodish-api');
    final bool isValidUrl = url != null &&
        url!.trim().isNotEmpty &&
        url!.startsWith('http') &&
        !isFoodish &&
        !_isDeadHost(url!);

    // If valid URL exists, use it. Otherwise, match by dish name (Pasta, Burger, Pancake, etc.)
    final String? finalImageUrl = isValidUrl ? url! : _getExactFoodImage();

    // If still no match (unrecognized title & no image URL uploaded), show placeholder
    if (finalImageUrl == null) {
      Widget placeholderWidget = _placeholder(context);
      if (borderRadius != null) {
        return ClipRRect(borderRadius: borderRadius!, child: placeholderWidget);
      }
      return placeholderWidget;
    }

    Widget child = Image.network(
      finalImageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, widget, progress) {
        if (progress == null) return widget;
        return _placeholder(context);
      },
      errorBuilder: (context, error, stackTrace) {
        return _placeholder(context);
      },
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      color: scheme.surfaceContainerHighest.withOpacity(0.6),
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_menu_outlined,
        size: 32,
        color: scheme.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }
}
