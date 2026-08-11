package com.recipebook.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "recipe")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Recipe {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String title;

    // Stored as newline-separated text; frontend splits into a list
    @Column(nullable = false, columnDefinition = "TEXT")
    private String ingredients;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String steps;

    @Column(nullable = false, length = 50)
    private String category; // Breakfast, Lunch, Dinner, Dessert, etc.

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "cook_time_minutes")
    private Integer cookTimeMinutes;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User owner;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    // Helper: convert stored newline-separated ingredients into a list for API responses
    @Transient
    public List<String> getIngredientList() {
        List<String> list = new ArrayList<>();
        if (ingredients != null && !ingredients.isBlank()) {
            for (String line : ingredients.split("\\r?\\n")) {
                if (!line.isBlank()) list.add(line.trim());
            }
        }
        return list;
    }
}
