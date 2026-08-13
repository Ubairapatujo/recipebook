import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../models/recipe.dart';

class AddRecipeScreen extends StatefulWidget {
  final ValueChanged<Recipe>? onRecipeAdded;

  const AddRecipeScreen({super.key, this.onRecipeAdded});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Desserts');
  final _cookTimeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();

  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      // 1. Read bytes from selected image (Flutter Web Compatible)
      final Uint8List bytes = await image.readAsBytes();

      // 2. Prepare ImgBB Multipart Request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://api.imgbb.com/1/upload?key=6d207e02198a847e3710d53813b3dd05'),
      );

      // 3. Attach file bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: image.name.isNotEmpty ? image.name : 'recipe_image.jpg',
        ),
      );

      // 4. Send request to ImgBB
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String uploadedUrl = data['data']['url'];

        setState(() {
          _imageUrlController.text = uploadedUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(
            'Upload failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Cook time parsing (Extract digits)
      final rawCookTime = _cookTimeController.text.trim();
      final numOnly = rawCookTime.replaceAll(RegExp(r'[^0-9]'), '');
      final parsedCookTime = int.tryParse(numOnly) ?? 0;

      // Create Recipe matching model strict types
      final newRecipe = Recipe(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text.trim(),
        ingredients: _ingredientsController.text
            .split('\n')
            .where((e) => e.trim().isNotEmpty)
            .toList(),
        steps: _stepsController.text.trim(),
        category: _categoryController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        cookTimeMinutes: parsedCookTime,
        ownerId: 1,
        ownerName: _ownerNameController.text.trim().isEmpty
            ? 'Anonymous'
            : _ownerNameController.text.trim(),
        createdAt: DateTime.now(),
      );

      if (widget.onRecipeAdded != null) {
        widget.onRecipeAdded!(newRecipe);
      }
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _cookTimeController.dispose();
    _imageUrlController.dispose();
    _ownerNameController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Recipe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Title',
                  hintText: 'e.g. Salted Caramel Cheesecake',
                  prefixIcon: Icon(Icons.restaurant),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter category' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cookTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cook Time (mins)',
                        hintText: 'e.g. 30',
                        prefixIcon: Icon(Icons.timer),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter cook time' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'e.g. Tom',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ingredients (One per line)',
                  hintText: '1 cup flour\n2 eggs\n1/2 cup sugar',
                  prefixIcon: Icon(Icons.list_alt),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter ingredients'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stepsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Preparation Steps',
                  hintText: '1. Mix dry ingredients...\n2. Bake at 180°C...',
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter steps'
                    : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Recipe Picture (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildImagePickerBox(dark),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isUploading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Publish Recipe',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerBox(bool dark) {
    final hasUrl = _imageUrlController.text.trim().isNotEmpty;

    return InkWell(
      onTap: _isUploading ? null : _pickAndUploadImage,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: dark ? Colors.grey.shade900 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasUrl
                ? Theme.of(context).primaryColor
                : (dark ? Colors.grey.shade800 : Colors.grey.shade300),
            width: 1.5,
          ),
        ),
        child: _isUploading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Uploading Image...',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              )
            : hasUrl
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          _imageUrlController.text,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Text('Invalid Image URL')),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.6),
                          radius: 18,
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap to select image from Gallery',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: dark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'If left blank, placeholder icon will be shown',
                        style: TextStyle(
                          fontSize: 11,
                          color: dark
                              ? Colors.grey.shade500
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
