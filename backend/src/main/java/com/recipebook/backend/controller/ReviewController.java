package com.recipebook.backend.controller;

import com.recipebook.backend.model.Recipe;
import com.recipebook.backend.model.Review;
import com.recipebook.backend.model.User;
import com.recipebook.backend.repository.RecipeRepository;
import com.recipebook.backend.repository.ReviewRepository;
import com.recipebook.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reviews")
@CrossOrigin(origins = "*")
public class ReviewController {

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private RecipeRepository recipeRepository;

    @Autowired
    private UserRepository userRepository;

    // Rating Submit karne ki API
    @PostMapping("/add")
    public ResponseEntity<?> addReview(@RequestParam Long recipeId, 
                                        @RequestParam Long userId, 
                                        @RequestParam Double rating, 
                                        @RequestParam(required = false) String comment) {

        Recipe recipe = recipeRepository.findById(recipeId)
                .orElseThrow(() -> new RuntimeException("Recipe not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Review review = new Review(rating, comment, recipe, user);
        reviewRepository.save(review);

        return ResponseEntity.ok("Review added successfully!");
    }

    // Recipe ke tamaam reviews dekhne ki API
    @GetMapping("/recipe/{recipeId}")
    public ResponseEntity<List<Review>> getReviewsByRecipe(@PathVariable Long recipeId) {
        return ResponseEntity.ok(reviewRepository.findByRecipeId(recipeId));
    }
}