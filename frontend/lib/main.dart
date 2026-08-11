import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home/landing_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/recipes/recipe_detail_screen.dart';
import 'screens/recipes/add_recipe_screen.dart';
import 'screens/recipes/edit_recipe_screen.dart';
import 'screens/recipes/search_screen.dart';
import 'screens/recipes/categories_screen.dart';
import 'screens/recipes/my_recipes_screen.dart';
import 'screens/recipes/saved_recipes_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/pages/about_screen.dart';
import 'screens/pages/contact_screen.dart';
import 'screens/pages/not_found_screen.dart';

void main() {
  runApp(const RecipeBookApp());
}

class RecipeBookApp extends StatelessWidget {
  const RecipeBookApp({super.key});

  static const String _title = 'RecipeBook';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..tryAutoLogin()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: _title,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (context) => const LandingScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/search': (context) => const SearchScreen(),
              '/categories': (context) => const CategoriesScreen(),
              '/add-recipe': (context) => const AddRecipeScreen(),
              '/my-recipes': (context) => const MyRecipesScreen(),
              '/saved-recipes': (context) => const SavedRecipesScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/about': (context) => const AboutScreen(),
              '/contact': (context) => const ContactScreen(),
            },
            onGenerateRoute: (settings) {
              // Recipe detail with ID
              if (settings.name?.startsWith('/recipe/') == true) {
                final idStr = settings.name!.split('/').last;
                final id = int.tryParse(idStr);
                if (id != null) {
                  return MaterialPageRoute(
                    builder: (_) => RecipeDetailScreen(recipeId: id),
                  );
                }
              }
              // Edit recipe with ID
              if (settings.name?.startsWith('/edit-recipe/') == true) {
                final idStr = settings.name!.split('/').last;
                final id = int.tryParse(idStr);
                if (id != null) {
                  return MaterialPageRoute(
                    builder: (_) => EditRecipeScreen(recipeId: id),
                  );
                }
              }
              // 404
              return MaterialPageRoute(builder: (_) => const NotFoundScreen());
            },
          );
        },
      ),
    );
  }
}
