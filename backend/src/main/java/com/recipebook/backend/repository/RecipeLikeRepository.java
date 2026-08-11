package com.recipebook.backend.repository;

import com.recipebook.backend.model.Recipe;
import com.recipebook.backend.model.RecipeLike;
import com.recipebook.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RecipeLikeRepository extends JpaRepository<RecipeLike, Long> {
    Optional<RecipeLike> findByRecipeAndUser(Recipe recipe, User user);
    long countByRecipe(Recipe recipe);
}
