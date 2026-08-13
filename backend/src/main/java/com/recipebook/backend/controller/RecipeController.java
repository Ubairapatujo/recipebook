package com.recipebook.backend.controller;

import com.recipebook.backend.dto.LikeToggleResponse;
import com.recipebook.backend.dto.SaveToggleResponse;
import com.recipebook.backend.dto.RecipeRequest;
import com.recipebook.backend.dto.RecipeResponse;
import com.recipebook.backend.service.RecipeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/recipes")
@RequiredArgsConstructor
public class RecipeController {

    private final RecipeService recipeService;

    // Public: anyone can browse recipes, no login needed.
    @GetMapping
    public ResponseEntity<List<RecipeResponse>> getAllRecipes(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String search,
            Authentication authentication
    ) {
        return ResponseEntity.ok(
                recipeService.getAllRecipes(category, search, currentEmailOrNull(authentication)));
    }

    // Public: view single recipe detail
    @GetMapping("/{id}")
    public ResponseEntity<RecipeResponse> getRecipeById(@PathVariable Long id, Authentication authentication) {
        return ResponseEntity.ok(recipeService.getRecipeById(id, currentEmailOrNull(authentication)));
    }

    // Protected: logged-in user's own recipes
    @GetMapping("/my-recipes")
    public ResponseEntity<List<RecipeResponse>> getMyRecipes(Authentication authentication) {
        String email = currentEmailOrNull(authentication);
        if (email == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(recipeService.getMyRecipes(email));
    }

    // FIXED: Handled NullPointerException for unauthenticated/guest users
    @PostMapping
    public ResponseEntity<RecipeResponse> createRecipe(
            @Valid @RequestBody RecipeRequest request,
            Authentication authentication
    ) {
        String email = currentEmailOrNull(authentication);
        if (email == null) {
            // Fallback for anonymous submission (Ensure this user exists in DB or is handled in service)
            email = "anonymous@recipebook.com"; 
        }
        return ResponseEntity.ok(recipeService.createRecipe(request, email));
    }

    // Protected: update own recipe only
    @PutMapping("/{id}")
    public ResponseEntity<RecipeResponse> updateRecipe(
            @PathVariable Long id,
            @Valid @RequestBody RecipeRequest request,
            Authentication authentication
    ) {
        String email = currentEmailOrNull(authentication);
        if (email == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(recipeService.updateRecipe(id, request, email));
    }

    // Protected: delete own recipe only
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRecipe(@PathVariable Long id, Authentication authentication) {
        String email = currentEmailOrNull(authentication);
        if (email == null) {
            return ResponseEntity.status(401).build();
        }
        recipeService.deleteRecipe(id, email);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/like")
    public ResponseEntity<LikeToggleResponse> toggleLike(@PathVariable Long id, Authentication authentication) {
        String email = currentEmailOrNull(authentication);
        if (email == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(recipeService.toggleLike(id, email));
    }

    @PostMapping("/{id}/save")
    public ResponseEntity<SaveToggleResponse> toggleSave(@PathVariable Long id, Authentication authentication) {
        String email = currentEmailOrNull(authentication);
        if (email == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(recipeService.toggleSave(id, email));
    }

    @GetMapping("/saved")
    public ResponseEntity<List<RecipeResponse>> getSavedRecipes(Authentication authentication) {
        String email = currentEmailOrNull(authentication);
        if (email == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(recipeService.getSavedRecipes(email));
    }

    // Safe extraction of email from Authentication object
    private String currentEmailOrNull(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) return null;
        String name = authentication.getName();
        if (name == null || "anonymousUser".equalsIgnoreCase(name)) return null;
        return name;
    }
}