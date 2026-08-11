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

    // Native SQL Query (Bypasses JPQL attribute errors completely)
    @Query(value = "SELECT " +
                   "  ISNULL(total_recipes, 0) AS totalRecipes, " +
                   "  ISNULL(total_likes, 0) AS totalLikes, " +
                   "  ISNULL(total_saves, 0) AS totalSaves, " +
                   "  ISNULL(avg_rating, 0.0) AS avgRating " +
                   "FROM vw_UserDashboardStats " +
                   "WHERE user_id = :userId", nativeQuery = true)
    DashboardStatsProjection findDashboardStatsByUserIdNative(@Param("userId") Long userId);
}