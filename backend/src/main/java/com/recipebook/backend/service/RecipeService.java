package com.recipebook.backend.service;

import com.recipebook.backend.dto.LikeToggleResponse;
import com.recipebook.backend.dto.RecipeRequest;
import com.recipebook.backend.dto.RecipeResponse;
import com.recipebook.backend.dto.SaveToggleResponse;
import com.recipebook.backend.exception.ResourceNotFoundException;
import com.recipebook.backend.exception.UnauthorizedActionException;
import com.recipebook.backend.model.Recipe;
import com.recipebook.backend.model.RecipeLike;
import com.recipebook.backend.model.SavedRecipe;
import com.recipebook.backend.model.User;
import com.recipebook.backend.repository.RecipeLikeRepository;
import com.recipebook.backend.repository.RecipeRepository;
import com.recipebook.backend.repository.ReviewRepository;
import com.recipebook.backend.repository.SavedRecipeRepository;
import com.recipebook.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@SuppressWarnings("null") // 👈 Removes null safety warnings in Problems tab
public class RecipeService {

    private final RecipeRepository recipeRepository;
    private final UserRepository userRepository;
    private final RecipeLikeRepository recipeLikeRepository;
    private final SavedRecipeRepository savedRecipeRepository;
    private final ReviewRepository reviewRepository;

    public List<RecipeResponse> getAllRecipes(String category, String search, String currentUserEmail) {
        List<Recipe> recipes;

        if (category != null && !category.isBlank()) {
            recipes = recipeRepository.findByCategoryIgnoreCase(category);
        } else if (search != null && !search.isBlank()) {
            recipes = recipeRepository.findByTitleContainingIgnoreCase(search);
        } else {
            recipes = recipeRepository.findAll();
        }

        return recipes.stream().map(r -> toResponse(r, currentUserEmail)).toList();
    }

    public RecipeResponse getRecipeById(Long id, String currentUserEmail) {
        Recipe recipe = recipeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Recipe not found with id: " + id));
        return toResponse(recipe, currentUserEmail);
    }

    public List<RecipeResponse> getMyRecipes(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        return recipeRepository.findByOwner(user).stream()
                .map(r -> toResponse(r, userEmail))
                .toList();
    }

    public RecipeResponse createRecipe(RecipeRequest request, String userEmail) {
        User owner = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Recipe recipe = new Recipe();
        recipe.setTitle(request.getTitle());
        recipe.setIngredients(request.getIngredients());
        recipe.setSteps(request.getSteps());
        recipe.setCategory(request.getCategory());
        recipe.setImageUrl(request.getImageUrl());
        recipe.setCookTimeMinutes(request.getCookTimeMinutes());
        recipe.setOwner(owner);

        Recipe saved = recipeRepository.save(recipe);
        return toResponse(saved, userEmail);
    }

    public RecipeResponse updateRecipe(Long id, RecipeRequest request, String userEmail) {
        Recipe recipe = recipeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Recipe not found with id: " + id));

        if (!recipe.getOwner().getEmail().equals(userEmail)) {
            throw new UnauthorizedActionException("You can only edit your own recipes");
        }

        recipe.setTitle(request.getTitle());
        recipe.setIngredients(request.getIngredients());
        recipe.setSteps(request.getSteps());
        recipe.setCategory(request.getCategory());
        recipe.setImageUrl(request.getImageUrl());
        recipe.setCookTimeMinutes(request.getCookTimeMinutes());

        Recipe updated = recipeRepository.save(recipe);
        return toResponse(updated, userEmail);
    }

    public void deleteRecipe(Long id, String userEmail) {
        Recipe recipe = recipeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Recipe not found with id: " + id));

        if (!recipe.getOwner().getEmail().equals(userEmail)) {
            throw new UnauthorizedActionException("You can only delete your own recipes");
        }

        recipeRepository.delete(recipe);
    }

    @Transactional
    public LikeToggleResponse toggleLike(Long recipeId, String userEmail) {
        Recipe recipe = recipeRepository.findById(recipeId)
                .orElseThrow(() -> new ResourceNotFoundException("Recipe not found with id: " + recipeId));
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        var existing = recipeLikeRepository.findByRecipeAndUser(recipe, user);
        boolean liked;
        if (existing.isPresent()) {
            recipeLikeRepository.delete(existing.get());
            liked = false;
        } else {
            RecipeLike like = new RecipeLike();
            like.setRecipe(recipe);
            like.setUser(user);
            recipeLikeRepository.save(like);
            liked = true;
        }
        long count = recipeLikeRepository.countByRecipe(recipe);
        return new LikeToggleResponse(liked, count);
    }

    @Transactional
    public SaveToggleResponse toggleSave(Long recipeId, String userEmail) {
        Recipe recipe = recipeRepository.findById(recipeId)
                .orElseThrow(() -> new ResourceNotFoundException("Recipe not found with id: " + recipeId));
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        var existing = savedRecipeRepository.findByRecipeAndUser(recipe, user);
        boolean saved;
        if (existing.isPresent()) {
            savedRecipeRepository.delete(existing.get());
            saved = false;
        } else {
            SavedRecipe savedRecipe = new SavedRecipe();
            savedRecipe.setRecipe(recipe);
            savedRecipe.setUser(user);
            savedRecipeRepository.save(savedRecipe);
            saved = true;
        }
        return new SaveToggleResponse(saved);
    }

    public List<RecipeResponse> getSavedRecipes(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return savedRecipeRepository.findByUserOrderByCreatedAtDesc(user).stream()
                .map(saved -> toResponse(saved.getRecipe(), userEmail))
                .toList();
    }

    private RecipeResponse toResponse(Recipe recipe, String currentUserEmail) {
        long likeCount = recipeLikeRepository.countByRecipe(recipe);
        boolean liked = false;
        boolean saved = false;

        if (currentUserEmail != null) {
            User currentUser = userRepository.findByEmail(currentUserEmail).orElse(null);
            if (currentUser != null) {
                liked = recipeLikeRepository.findByRecipeAndUser(recipe, currentUser).isPresent();
                saved = savedRecipeRepository.findByRecipeAndUser(recipe, currentUser).isPresent();
            }
        }

        List<Map<String, Object>> comments = reviewRepository.findByRecipeId(recipe.getId()).stream()
                .filter(r -> r.getComment() != null && !r.getComment().isBlank())
                .map(r -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("text", r.getComment());
                    map.put("author", r.getUser().getName());
                    map.put("time", r.getCreatedAt().toString());
                    return map;
                })
                .collect(Collectors.toList());

        return new RecipeResponse(
                recipe.getId(),
                recipe.getTitle(),
                recipe.getIngredientList(),
                recipe.getSteps(),
                recipe.getCategory(),
                recipe.getImageUrl(),
                recipe.getCookTimeMinutes(),
                recipe.getOwner().getId(),
                recipe.getOwner().getName(),
                recipe.getCreatedAt(),
                likeCount,
                liked,
                saved,
                comments
        );
    }
}