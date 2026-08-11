import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/recipe.dart';
import 'api_client.dart';

class RecipeService {
  // Get All Recipes (with Optional Category & Search Filter)
  Future<List<Recipe>> getAllRecipes({String? category, String? search}) async {
    final params = <String, String>{};
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('${ApiConfig.baseUrl}/recipes')
        .replace(queryParameters: params.isEmpty ? null : params);

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final dynamic bodyData = jsonDecode(response.body);
      if (bodyData is List) {
        return bodyData.map((json) => Recipe.fromJson(json)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<List<Recipe>> getRecipes() async {
    return getAllRecipes();
  }

  // Get Single Recipe By ID
  Future<Recipe> getRecipeById(int id) async {
    final response =
        await http.get(Uri.parse('${ApiConfig.baseUrl}/recipes/$id'));
    if (response.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Recipe not found');
    }
  }

  // Get User's Own Created Recipes
  Future<List<Recipe>> getMyRecipes(String token) async {
    final response = await ApiClient.get('/recipes/my-recipes', token: token);
    if (response.statusCode == 200) {
      final dynamic bodyData = jsonDecode(response.body);
      if (bodyData is List) {
        return bodyData.map((json) => Recipe.fromJson(json)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load your recipes');
    }
  }

  // Create Recipe
  Future<Recipe> createRecipe(Recipe recipe, String token) async {
    final response = await ApiClient.post(
      '/recipes',
      body: recipe.toRequestJson(),
      token: token,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(ApiClient.extractError(response.body));
    }
  }

  // Update Recipe
  Future<Recipe> updateRecipe(int id, Recipe recipe, String token) async {
    final response = await ApiClient.put(
      '/recipes/$id',
      body: recipe.toRequestJson(),
      token: token,
    );
    if (response.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(ApiClient.extractError(response.body));
    }
  }

  // Delete Recipe
  Future<void> deleteRecipe(int id, String token) async {
    final response = await ApiClient.delete('/recipes/$id', token: token);
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(ApiClient.extractError(response.body));
    }
  }

  // Toggle Like Recipe
  Future<Map<String, dynamic>> toggleLike(int recipeId, String token) async {
    final response =
        await ApiClient.post('/recipes/$recipeId/like', body: {}, token: token);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(ApiClient.extractError(response.body));
    }
  }

  // Toggle Save/Bookmark Recipe
  Future<bool> toggleSave(int recipeId, String token) async {
    final response =
        await ApiClient.post('/recipes/$recipeId/save', body: {}, token: token);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('saved')) {
            return data['saved'] as bool;
          }
        } catch (_) {}
      }
      return true;
    } else {
      throw Exception(ApiClient.extractError(response.body));
    }
  }

  // Alias for Toggle Bookmark
  Future<bool> toggleBookmark(int recipeId, String token) async {
    return toggleSave(recipeId, token);
  }

  // Get Saved/Bookmarked Recipes (Strict Null-Safe Check)
  Future<List<Recipe>> getSavedRecipes(String token) async {
    final response = await ApiClient.get('/recipes/saved', token: token);
    if (response.statusCode == 200) {
      if (response.body.isEmpty) return [];

      final dynamic bodyData = jsonDecode(response.body);

      if (bodyData is List) {
        return bodyData.map((json) => Recipe.fromJson(json)).toList();
      }

      if (bodyData is Map && bodyData['recipes'] is List) {
        return (bodyData['recipes'] as List)
            .map((json) => Recipe.fromJson(json))
            .toList();
      }

      return [];
    } else {
      throw Exception('Failed to load saved recipes');
    }
  }

  // 👈 NAYA METHOD: Add Comment
  Future<Map<String, dynamic>> addComment(
      int recipeId, String commentText, String token) async {
    final response = await ApiClient.post(
      '/recipes/$recipeId/comments',
      body: {'text': commentText},
      token: token,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(ApiClient.extractError(response.body));
    }
  }
}
