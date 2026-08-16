class Recipe {
  final int id;
  final String title;
  final List<String> ingredients;
  final String steps;
  final String category;
  final String? imageUrl;
  final int cookTimeMinutes;
  final int ownerId;
  final String ownerName;
  final DateTime createdAt;
  final int? likes;
  final int? rating;
  final List<Map<String, dynamic>> comments; // 👈 1. Nayi field add ki

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.category,
    this.imageUrl,
    required this.cookTimeMinutes,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
    this.likes,
    this.rating,
    this.comments = const [], // 👈 2. Default empty list rakhi
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'] ?? '',
      ingredients: _parseIngredients(json['ingredients']),
      steps: json['steps'] ?? '',
      category: json['category'] ?? 'General',
      imageUrl: json['imageUrl'],
      cookTimeMinutes: json['cookTimeMinutes'] ?? 0,
      ownerId: json['ownerId'] ?? 0,
      ownerName: json['ownerName'] ?? 'Unknown',
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ??
              DateTime.now(),
      likes: json['likeCount'] ?? json['likes'] ?? 0,
      rating: json['rating'],
      comments: _parseComments(json['comments']), // 👈 3. Comments parsing
    );
  }

  // 👈 4. Comments parse karne ke liye helper method
  static List<Map<String, dynamic>> _parseComments(dynamic data) {
    if (data == null || data is! List) return [];

    return data.map<Map<String, dynamic>>((e) {
      if (e is Map) {
        return {
          'text': e['text'] ?? e['comment'] ?? '',
          'author': e['author'] ?? e['userName'] ?? 'User',
          'time': e['time'] ?? 'Just now',
        };
      }
      return {'text': e.toString(), 'author': 'User', 'time': 'Just now'};
    }).toList();
  }

  static List<String> _parseIngredients(dynamic data) {
    if (data == null) return [];
    if (data is String) {
      if (data.contains('\n')) {
        return data.split('\n').where((e) => e.trim().isNotEmpty).toList();
      }
      if (data.contains(',')) {
        return data
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [data.trim()];
    }
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'title': title,
      'ingredients': ingredients.join('\n'),
      'steps': steps,
      'category': category,
      'imageUrl': imageUrl,
      'cookTimeMinutes': cookTimeMinutes,
    };
  }

  List<String> get stepsList {
    return steps
        .split(RegExp(r'\r?\n'))
        .map((s) => s.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '').trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String get formattedTime {
    if (cookTimeMinutes < 60) return '${cookTimeMinutes}m';
    final hours = cookTimeMinutes ~/ 60;
    final mins = cookTimeMinutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  String get dateAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.isNegative) return 'Just now';

    if (diff.inDays >= 365) {
      final years = (diff.inDays / 365).floor();
      return '${years}y ago';
    }
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '${months}mo ago';
    }
    if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return '${weeks}w ago';
    }
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }
}
