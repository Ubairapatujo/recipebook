package com.recipebook.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsResponse {
    private Long totalRecipes;
    private Long totalLikes;
    private Long totalSaves;
    private Double avgRating;
}