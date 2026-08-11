package com.recipebook.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RecipeRequest {

    @NotBlank(message = "Title is required")
    private String title;

    @NotBlank(message = "Ingredients are required")
    private String ingredients; // newline-separated, e.g. "2 eggs\n1 cup flour"

    @NotBlank(message = "Steps are required")
    private String steps;

    @NotBlank(message = "Category is required")
    private String category;

    private String imageUrl;

    @NotNull(message = "Cook time is required")
    private Integer cookTimeMinutes;
}
