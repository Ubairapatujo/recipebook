# =====================================================================
#  fix_recipe_images.ps1
#  Updates every demo recipe with a reliable HD food photo.
#  This version PRINTS every step so you can see exactly what fails.
# =====================================================================

# IMPORTANT: this must match the port your backend is ACTUALLY running on.
# Your app screenshot showed localhost:5000 -- if the API runs there,
# change 8080 to 5000 below.
$BaseUrl = "http://localhost:8080/api"

$DemoUsers = @(
    @{ name = "Ayesha Khan";  email = "ayesha.khan@recipebook.demo";  password = "Demo@1234" },
    @{ name = "Hassan Ali";   email = "hassan.ali@recipebook.demo";   password = "Demo@1234" },
    @{ name = "Sara Ahmed";   email = "sara.ahmed@recipebook.demo";   password = "Demo@1234" },
    @{ name = "Bilal Sheikh"; email = "bilal.sheikh@recipebook.demo"; password = "Demo@1234" }
)

# All URLs use the same reliable Unsplash parameters:
#   ?q=80&w=1000&auto=format&fit=crop
# auto=format + fit=crop are what make Unsplash serve the image directly.
$Q = "?q=80&w=1000&auto=format&fit=crop"
$HdImages = @{
    "Classic Chicken Biryani"          = "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8$Q"
    "Creamy Garlic Butter Pasta"       = "https://images.unsplash.com/photo-1621996346565-e3d5d6281292$Q"
    "Loaded Beef Burger"               = "https://images.unsplash.com/photo-1568901346375-23c9450c58cd$Q"
    "Fluffy Pancake Stack"             = "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445$Q"
    "Chocolate Lava Cake"              = "https://images.unsplash.com/photo-1606313564200-e75d5e30476c$Q"
    "Grilled Lemon Herb Chicken Salad" = "https://images.unsplash.com/photo-1546069901-ba9599a7e63c$Q"
    "15-Minute Vegetable Stir Fry"     = "https://images.unsplash.com/photo-1512621776951-a57141f2eefd$Q"
    "Vegan Chickpea Buddha Bowl"       = "https://images.unsplash.com/photo-1540420773420-3366772f4999$Q"
    "Chicken Chow Mein"                = "https://images.unsplash.com/photo-1585032226651-759b368d7246$Q"
    "Classic Margherita Pizza"         = "https://images.unsplash.com/photo-1604382354936-07c5d9983bd3$Q"
    "Beef Butter Masala"               = "https://images.unsplash.com/photo-1588166524941-3bf61a9c41db$Q"
    "Overnight Oats with Berries"      = "https://images.unsplash.com/photo-1517673400267-0251440c45dc$Q"
    "Crispy Masala Dosa"               = "https://images.unsplash.com/photo-1668236543090-82eba5ee5976$Q"
    "Steamed Idli with Sambar"         = "https://images.unsplash.com/photo-1589301760014-d929f3979dbc$Q"
    "Quick Veggie Fried Rice"          = "https://images.unsplash.com/photo-1603133872878-684f208fb84b$Q"
    "Baked Salmon with Vegetables"     = "https://images.unsplash.com/photo-1467003909585-2f8a72700288$Q"
    "Spicy Chicken Samosas"            = "https://images.unsplash.com/photo-1601050690597-df0568f70950$Q"
    "Vegan Lentil Soup"                = "https://images.unsplash.com/photo-1547592166-23ac45744acd$Q"
    "Thai-Style Basil Chicken"         = "https://images.unsplash.com/photo-1562967914-608f82629710$Q"
    "Italian Tiramisu"                 = "https://images.unsplash.com/photo-1571877227200-a0d98ea607e9$Q"
    "One-Pot Vegetable Pulao"          = "https://images.unsplash.com/photo-1645177628172-a94c1f96e6db$Q"
    "Greek Yogurt Chicken Wrap"        = "https://images.unsplash.com/photo-1626700051175-6818013e1d4f$Q"
    "Homemade Butter Chicken"          = "https://images.unsplash.com/photo-1603894584373-5ac82b2ae398$Q"
    "Simple Caprese Salad"             = "https://images.unsplash.com/photo-1592417817098-8f3d6eb12735$Q"
}
$Fallback = "https://images.unsplash.com/photo-1498837167922-ddd27525d352$Q"

function Login($user) {
    $body = @{ email = $user.email; password = $user.password } | ConvertTo-Json
    try {
        $resp = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method Post -Body $body -ContentType "application/json"
        # Support common token field names.
        if ($resp.token)       { return $resp.token }
        if ($resp.accessToken) { return $resp.accessToken }
        if ($resp.jwt)         { return $resp.jwt }
        Write-Host "  ! Login for $($user.email) returned no token field. Raw: $($resp | ConvertTo-Json -Compress)" -ForegroundColor Yellow
        return $null
    } catch {
        Write-Host "  X Login FAILED for $($user.email): $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "Base URL: $BaseUrl"
Write-Host "Updating database with reliable HD food photos..." -ForegroundColor Cyan
Write-Host ""

$updated = 0
$failed  = 0

foreach ($user in $DemoUsers) {
    Write-Host "User: $($user.email)" -ForegroundColor Cyan
    $token = Login $user
    if (-not $token) { continue }

    try {
        $myRecipes = Invoke-RestMethod -Uri "$BaseUrl/recipes/my-recipes" -Method Get `
            -Headers @{ Authorization = "Bearer $token" }
    } catch {
        Write-Host "  X Could not fetch recipes: $($_.Exception.Message)" -ForegroundColor Red
        continue
    }

    if (-not $myRecipes -or $myRecipes.Count -eq 0) {
        Write-Host "  (no recipes for this user)" -ForegroundColor DarkGray
        continue
    }

    foreach ($recipe in $myRecipes) {
        $hdUrl = $HdImages[$recipe.title]
        if (-not $hdUrl) { $hdUrl = $Fallback }

        # Normalise ingredients/steps whether they arrive as arrays or strings.
        $ingredients = if ($recipe.ingredients -is [array]) { $recipe.ingredients -join "`n" } else { "$($recipe.ingredients)" }
        $steps       = if ($recipe.steps -is [array])       { $recipe.steps -join "`n" }       else { "$($recipe.steps)" }

        $payload = @{
            title           = $recipe.title
            ingredients     = $ingredients
            steps           = $steps
            category        = $recipe.category
            imageUrl        = $hdUrl
            cookTimeMinutes = $recipe.cookTimeMinutes
        } | ConvertTo-Json

        try {
            Invoke-RestMethod -Uri "$BaseUrl/recipes/$($recipe.id)" -Method Put -Body $payload `
                -ContentType "application/json" -Headers @{ Authorization = "Bearer $token" } | Out-Null
            Write-Host "  + Updated: $($recipe.title)" -ForegroundColor Green
            $updated++
        } catch {
            Write-Host "  X Update FAILED for '$($recipe.title)': $($_.Exception.Message)" -ForegroundColor Red
            $failed++
        }
    }
    Write-Host ""
}

Write-Host "Done. Updated: $updated  |  Failed: $failed" -ForegroundColor Cyan
