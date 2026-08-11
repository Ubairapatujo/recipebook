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

    // Public: anyone can browse recipes, no login needed. If a valid token
    // IS present though, we still resolve who's asking so likedByCurrentUser
    // / savedByCurrentUser come back accurate instead of always false.
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
        String email = authentication.getName();
        return ResponseEntity.ok(recipeService.getMyRecipes(email));
    }

    // Protected: create a new recipe
    @PostMapping
    public ResponseEntity<RecipeResponse> createRecipe(
            @Valid @RequestBody RecipeRequest request,
            Authentication authentication
    ) {
        String email = authentication.getName();
        return ResponseEntity.ok(recipeService.createRecipe(request, email));
    }

    // Protected: update own recipe only
    @PutMapping("/{id}")
    public ResponseEntity<RecipeResponse> updateRecipe(
            @PathVariable Long id,
            @Valid @RequestBody RecipeRequest request,
            Authentication authentication
    ) {
        String email = authentication.getName();
        return ResponseEntity.ok(recipeService.updateRecipe(id, request, email));
    }

    // Protected: delete own recipe only
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRecipe(@PathVariable Long id, Authentication authentication) {
        String email = authentication.getName();
        recipeService.deleteRecipe(id, email);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/like")
    public ResponseEntity<LikeToggleResponse> toggleLike(@PathVariable Long id, Authentication authentication) {
        return ResponseEntity.ok(recipeService.toggleLike(id, authentication.getName()));
    }

    @PostMapping("/{id}/save")
    public ResponseEntity<SaveToggleResponse> toggleSave(@PathVariable Long id, Authentication authentication) {
        return ResponseEntity.ok(recipeService.toggleSave(id, authentication.getName()));
    }

    @GetMapping("/saved")
    public ResponseEntity<List<RecipeResponse>> getSavedRecipes(Authentication authentication) {
        return ResponseEntity.ok(recipeService.getSavedRecipes(authentication.getName()));
    }

    // GET /api/recipes and /api/recipes/{id} are public, so Authentication
    // here is either null or Spring's "anonymousUser" token when nobody is
    // logged in — only treat it as a real user when it's neither.
    private String currentEmailOrNull(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) return null;
        String name = authentication.getName();
        if (name == null || "anonymousUser".equals(name)) return null;
        return name;
    }
}