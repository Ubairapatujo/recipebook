package com.recipebook.backend.repository;

import com.recipebook.backend.model.Recipe;
import com.recipebook.backend.model.SavedRecipe;
import com.recipebook.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SavedRecipeRepository extends JpaRepository<SavedRecipe, Long> {
    Optional<SavedRecipe> findByRecipeAndUser(Recipe recipe, User user);
    List<SavedRecipe> findByUserOrderByCreatedAtDesc(User user);
}
