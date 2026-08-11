package com.recipebook.backend.dto;

public interface DashboardStatsProjection {
    Long getTotalRecipes();
    Long getTotalLikes();
    Long getTotalSaves();
    Double getAvgRating();
}