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

class EditRecipeScreen extends StatefulWidget {
  final int recipeId;
  const EditRecipeScreen({super.key, required this.recipeId});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final RecipeService _recipeService = RecipeService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _cookTimeController = TextEditingController();

  String _selectedCategory = 'Breakfast';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  Recipe? _recipe;

  final List<String> _categories = [
    'Breakfast', 'Lunch', 'Dinner', 'Desserts', 'Healthy',
    'Quick Meals', 'Vegan', 'Italian', 'Asian', 'Snacks', 'Beverages',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    try {
      final recipe = await _recipeService.getRecipeById(widget.recipeId);
      setState(() {
        _recipe = recipe;
        _titleController.text = recipe.title;
        _ingredientsController.text = recipe.ingredients.join('\n');
        _stepsController.text = recipe.steps;
        _imageUrlController.text = recipe.imageUrl ?? '';
        _cookTimeController.text = recipe.cookTimeMinutes.toString();
        _selectedCategory = recipe.category;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final auth = context.read<AuthProvider>();
      final recipe = Recipe(
        id: _recipe!.id,
        title: _titleController.text.trim(),
        ingredients: _ingredientsController.text
            .split('\n')
            .where((e) => e.trim().isNotEmpty)
            .toList(),
        steps: _stepsController.text.trim(),
        category: _selectedCategory,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        cookTimeMinutes: int.parse(_cookTimeController.text.trim()),
        ownerId: _recipe!.ownerId,
        ownerName: _recipe!.ownerName,
        createdAt: _recipe!.createdAt,
      );

      await _recipeService.updateRecipe(_recipe!.id, recipe, auth.user!.token);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully!')),
        );
        Navigator.of(context).pushNamed('/recipe/${_recipe!.id}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _imageUrlController.dispose();
    _cookTimeController.dispose();
    super.dispose();
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
            currentRoute: '/my-recipes',
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
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: _loadRecipe, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.getHorizontalPadding(context),
                            vertical: 32,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 680),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.edit_rounded,
                                          color: AppTheme.primaryColor, size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      'Edit Recipe',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),

                                if (_errorMessage != null)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                                    ),
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.red, fontSize: 13),
                                    ),
                                  ),
                                if (_errorMessage != null) const SizedBox(height: 16),

                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildField(isDark, 'Recipe Title', _titleController),
                                      const SizedBox(height: 20),
                                      _buildSectionLabel(isDark, 'Category'),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _categories.map((cat) {
                                          final isSelected = cat == _selectedCategory;
                                          return ChoiceChip(
                                            label: Text(cat),
                                            selected: isSelected,
                                            onSelected: (_) =>
                                                setState(() => _selectedCategory = cat),
                                            selectedColor: AppTheme.primaryColor,
                                            labelStyle: TextStyle(
                                              color: isSelected ? Colors.white : AppTheme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                            backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 20),
                                      _buildField(isDark, 'Cook Time (minutes)', _cookTimeController,
                                          keyboardType: TextInputType.number),
                                      const SizedBox(height: 20),
                                      _buildField(isDark, 'Image URL', _imageUrlController),
                                      const SizedBox(height: 20),
                                      _buildSectionLabel(isDark, 'Ingredients'),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 140,
                                        child: TextFormField(
                                          controller: _ingredientsController,
                                          maxLines: null,
                                          expands: true,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter each ingredient on a new line',
                                          ),
                                          validator: (v) => (v == null || v.trim().isEmpty)
                                              ? 'Ingredients are required'
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      _buildSectionLabel(isDark, 'Cooking Steps'),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 180,
                                        child: TextFormField(
                                          controller: _stepsController,
                                          maxLines: null,
                                          expands: true,
                                          decoration: const InputDecoration(
                                            hintText: 'Describe each step on a new line...',
                                          ),
                                          validator: (v) => (v == null || v.trim().isEmpty)
                                              ? 'Cooking steps are required'
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: _isSaving ? null : _handleSubmit,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: _isSaving
                                              ? const SizedBox(
                                                  height: 22,
                                                  width: 22,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Text(
                                                  'Update Recipe',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                        ),
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
          const AppFooter(),
        ],
      ),
    );
  }

  Widget _buildField(bool isDark, String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.grey.shade300 : const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? '$label is required'
              : null,
        ),
      ],
    );
  }

  Widget _buildSectionLabel(bool isDark, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.grey.shade300 : const Color(0xFF1A1A2E),
      ),
    );
  }
}
