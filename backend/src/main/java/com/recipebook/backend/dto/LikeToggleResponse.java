package com.recipebook.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LikeToggleResponse {
    private boolean liked;
    private long likesCount;
}
