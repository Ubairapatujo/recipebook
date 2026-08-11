package com.recipebook.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecipeResponse {
    private Long id;
    private String title;
    private List<String> ingredients;
    private String steps;
    private String category;
    private String imageUrl;
    private Integer cookTimeMinutes;
    private Long ownerId;
    private String ownerName;
    private LocalDateTime createdAt;

    // Real like/save state — populated on every fetch, not just on toggle,
    // so the count and per-user state are always accurate on page load.
    private Long likeCount;
    private boolean likedByCurrentUser;
    private boolean savedByCurrentUser;
}