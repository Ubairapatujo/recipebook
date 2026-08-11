package com.recipebook.backend.controller;

import com.recipebook.backend.dto.DashboardStatsProjection;
import com.recipebook.backend.dto.DashboardStatsResponse;
import com.recipebook.backend.repository.RecipeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = "*")
public class DashboardController {

    @Autowired
    private RecipeRepository recipeRepository;

    @GetMapping("/stats/{userId}")
    public ResponseEntity<DashboardStatsResponse> getDashboardStats(@PathVariable Long userId) {
        DashboardStatsProjection stats = recipeRepository.findDashboardStatsByUserIdNative(userId);

        if (stats != null) {
            return ResponseEntity.ok(new DashboardStatsResponse(
                stats.getTotalRecipes() != null ? stats.getTotalRecipes() : 0L,
                stats.getTotalLikes() != null ? stats.getTotalLikes() : 0L,
                stats.getTotalSaves() != null ? stats.getTotalSaves() : 0L,
                stats.getAvgRating() != null ? stats.getAvgRating() : 0.0
            ));
        }

        return ResponseEntity.ok(new DashboardStatsResponse(0L, 0L, 0L, 0.0));
    }
}