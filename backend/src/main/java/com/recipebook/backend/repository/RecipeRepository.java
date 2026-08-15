package com.recipebook.backend.repository;

import com.recipebook.backend.dto.DashboardStatsProjection;
import com.recipebook.backend.model.Recipe;
import com.recipebook.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface RecipeRepository extends JpaRepository<Recipe, Long> {

    List<Recipe> findByOwner(User owner);

    List<Recipe> findByCategoryIgnoreCase(String category);

    List<Recipe> findByTitleContainingIgnoreCase(String keyword);

    List<Recipe> findByOwnerId(Long ownerId);

    // Native SQL Query — Postgres compatible, computed directly from base
    // tables (recipe, recipe_like, saved_recipe, review). Replaces the old
    // SQL-Server-only vw_UserDashboardStats view + ISNULL() query, which
    // does not exist on the Supabase Postgres database.
    @Query(value = "SELECT " +
                   "  COALESCE((SELECT COUNT(*) FROM recipe r WHERE r.user_id = :userId), 0) AS totalRecipes, " +
                   "  COALESCE((SELECT COUNT(*) FROM recipe_like rl JOIN recipe r ON rl.recipe_id = r.id WHERE r.user_id = :userId), 0) AS totalLikes, " +
                   "  COALESCE((SELECT COUNT(*) FROM saved_recipe sr JOIN recipe r ON sr.recipe_id = r.id WHERE r.user_id = :userId), 0) AS totalSaves, " +
                   "  COALESCE((SELECT AVG(rv.rating) FROM review rv JOIN recipe r ON rv.recipe_id = r.id WHERE r.user_id = :userId), 0.0) AS avgRating",
           nativeQuery = true)
    DashboardStatsProjection findDashboardStatsByUserIdNative(@Param("userId") Long userId);
}