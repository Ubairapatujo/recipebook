package com.recipebook.backend.controller;

import com.recipebook.backend.dto.LikeToggleResponse;
import com.recipebook.backend.dto.SaveToggleResponse;
import com.recipebook.backend.dto.RecipeRequest;
import com.recipebook.backend.dto.RecipeResponse;
import com.recipebook.backend.model.Recipe;
import com.recipebook.backend.model.Review;
import com.recipebook.backend.model.User;
import com.recipebook.backend.repository.RecipeRepository;
import com.recipebook.backend.repository.ReviewRepository;
import com.recipebook.backend.repository.UserRepository;
import com.recipebook.backend.service.RecipeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/recipes")
@RequiredArgsConstructor
public class RecipeController {

    private final RecipeService recipeService;
    private final ReviewRepository reviewRepository;
    private final RecipeRepository recipeRepository;
    private final UserRepository userRepository;

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

    // NEW: Add Comment (uses Review table with rating left null)
    @PostMapping("/{id}/comments")
    public ResponseEntity<?> addComment(
            @PathVariable Long id,
            @RequestBody Map<String, String> body,
            Authentication authentication
    ) {
        String email = currentEmailOrNull(authentication);
        if (email == null) {
            return ResponseEntity.status(401).build();
        }

        String text = body.get("text");
        if (text == null || text.isBlank()) {
            return ResponseEntity.badRequest().body("Comment text is required");
        }

        Recipe recipe = recipeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Recipe not found"));
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Review review = new Review(null, text, recipe, user);
        reviewRepository.save(review);

        return ResponseEntity.ok(Map.of(
                "id", review.getId(),
                "text", review.getComment(),
                "user", user.getEmail(),
                "createdAt", review.getCreatedAt()
        ));
    }

    // NEW: Get Comments for a Recipe
    @GetMapping("/{id}/comments")
    public ResponseEntity<List<Review>> getComments(@PathVariable Long id) {
        return ResponseEntity.ok(reviewRepository.findByRecipeId(id));
    }

    // Safe extraction of email from Authentication object
    private String currentEmailOrNull(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) return null;
        String name = authentication.getName();
        if (name == null || "anonymousUser".equalsIgnoreCase(name)) return null;
        return name;
    }
}