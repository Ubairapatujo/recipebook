# RecipeBook

A full-stack recipe-sharing web application — built to let people create, discover, and interact with recipes shared by other users.

**Stack:** Flutter Web → Spring Boot REST API (JWT auth) → PostgreSQL (Supabase)

**Live:** [Frontend](https://recipebook-xi-three.vercel.app) · [Backend API](https://recipebook-production-108c.up.railway.app/api)

![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.5-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-Web-blue)
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL%20%2F%20Supabase-336791)
![JWT](https://img.shields.io/badge/Auth-JWT-yellow)

---

## Overview

RecipeBook is a full-stack application where users can register, log in, and share recipes with the community. Other users can browse recipes, search and filter by category, like and save recipes they enjoy, rate them, and leave comments. Each user can manage their own recipes (create, edit, delete) through a dedicated dashboard that also surfaces their personal stats.

The project was built to demonstrate a complete, production-style full-stack workflow: a Flutter Web frontend consuming a secured Spring Boot REST API, backed by a cloud-hosted PostgreSQL database — deployed end-to-end across Vercel (frontend), Railway (backend), and Supabase (database).

**Architecture at a glance:**

```
Flutter Web (Frontend) — Vercel
        ↓  HTTPS / REST
Spring Boot API (Backend) — Railway
        ↓  JDBC / JPA
PostgreSQL — Supabase (Database)
```

---

## Key Features

### Authentication & Security
- User registration and login
- JWT-based stateless authentication (JJWT 0.11.5)
- BCrypt password hashing
- Route-level authorization (owner-only edit/delete)

### Recipe Management
- Create, edit, and delete recipes (owner-only)
- View a user's own recipes ("My Recipes")
- Browse by category

### Discovery & Search
- Browse all recipes
- Search recipes by title
- Filter recipes by category

### User Interaction
- Like / unlike recipes, with a live per-recipe like count
- Save / bookmark recipes for later, with a dedicated saved-recipes view
- Rate and comment on recipes (via the ratings/reviews system)

### Personal Dashboard
- Per-user stats: total recipes, total saves, total likes received, and average rating — served by a dedicated dashboard endpoint

### UI/UX
- Responsive Flutter Web interface (mobile and desktop layouts)
- Recipe detail screen with hero image, ingredients, and step-by-step instructions
- Light/dark theme support
- Static informational pages (About, Contact) and a custom 404 page

---

## Tech Stack

| Technology | Purpose | Where it's used |
|---|---|---|
| Flutter (Web) | Frontend UI framework | `frontend/` |
| Provider | Frontend state management | `frontend/lib/providers` |
| Spring Boot 3.2.5 | Backend REST API framework | `backend/` |
| Spring Security | Authentication & authorization | `backend/security`, `backend/config` |
| JJWT 0.11.5 | JWT token generation & validation | `backend/security` |
| BCrypt | Password hashing | `backend/service` |
| PostgreSQL / Supabase | Relational database | Cloud-hosted (Supabase) |
| Spring Data JPA / Hibernate | ORM / database access | `backend/repository`, `backend/model` |
| Lombok | Reduces entity/DTO boilerplate | `backend/model`, `backend/dto` |
| Maven | Backend build tool | `backend/pom.xml` |

---

## Project Structure

```
recipebook/
├── backend/
│   └── src/main/java/com/recipebook/backend/
│       ├── controller/    AuthController, RecipeController, ReviewController, DashboardController
│       ├── service/       Business logic
│       ├── repository/    Data access (Spring Data JPA)
│       ├── model/         User, Recipe, RecipeLike, SavedRecipe, Review
│       ├── dto/           Request/response objects
│       ├── security/      JwtAuthFilter, JwtUtil
│       ├── config/        SecurityConfig (routes, CORS)
│       └── exception/     GlobalExceptionHandler and custom exceptions
└── frontend/
    └── lib/
        ├── models/        Data models
        ├── services/      API service layer (ApiClient, RecipeService, AuthService)
        ├── providers/     App state (AuthProvider, ThemeProvider)
        ├── screens/
        │   ├── auth/          login_screen, register_screen
        │   ├── dashboard/     dashboard_screen
        │   ├── home/          home_screen, landing_screen
        │   ├── pages/         about_screen, contact_screen
        │   ├── profile/       profile_screen
        │   ├── recipes/       add_recipe_screen, edit_recipe_screen, recipe_detail_screen,
        │   │                  my_recipes_screen, saved_recipes_screen, search_screen,
        │   │                  categories_screen
        │   └── static/        not_found_screen
        └── widgets/       Reusable UI components (nav bar, footer, mobile drawer)
```

---

## Backend Architecture

- **Controller** — exposes REST endpoints, extracts the authenticated user from the request, and delegates to the service layer. Split by domain: `AuthController` (register/login), `RecipeController` (CRUD, like, save), `ReviewController` (ratings & comments), `DashboardController` (per-user stats).
- **Service** — contains business logic (e.g. toggling a like, computing like counts, building API responses).
- **Repository** — Spring Data JPA interfaces for database access, including native SQL for aggregate dashboard stats.
- **Model** — JPA entities mapped to the database tables: `User`, `Recipe`, `RecipeLike`, `SavedRecipe`, `Review`.
- **DTO** — request/response objects that shape what the API sends and receives, decoupled from the database entities.
- **Security/Config** — `JwtAuthFilter` validates the Bearer token on each request and populates the security context; `SecurityConfig` defines route access rules and CORS policy.
- **Exception** — `GlobalExceptionHandler` centralizes handling for resource-not-found, unauthorized actions, validation errors, and unexpected exceptions, returning a consistent JSON error shape.

---

## Authentication & Security

- Users register and log in via `/api/auth/register` and `/api/auth/login`.
- Passwords are hashed with BCrypt before being stored — plaintext passwords are never persisted.
- On login, the backend issues a JWT (24-hour expiry), which the frontend stores and sends as a `Bearer` token on subsequent requests.
- A custom `JwtAuthFilter` runs on every request, validates the token, and sets the authenticated user in Spring Security's context.
- Protected actions (creating/editing/deleting recipes, liking, saving, rating/commenting) require a valid token; ownership checks ensure users can only edit or delete their own recipes.

> **Note:** database credentials and the JWT signing secret are supplied via environment variables (`DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `JWT_SECRET`) and never committed.

---

## Database

- **Engine:** PostgreSQL, hosted on **Supabase**.
- The backend connects via Spring Data JPA / Hibernate over Supabase's Session Pooler connection, with schema kept in sync via Hibernate's `ddl-auto=update` setting.
- **Core entities:** `User`, `Recipe`, `RecipeLike`, `SavedRecipe`, `Review` (used for both ratings and comments).

---

## API Overview

| Method | Endpoint | Description | Auth required |
|---|---|---|---|
| POST | `/api/auth/register` | Register a new user | No |
| POST | `/api/auth/login` | Log in and receive a JWT | No |
| GET | `/api/recipes` | List/search/filter recipes | No |
| GET | `/api/recipes/{id}` | Get a single recipe's details | No |
| GET | `/api/recipes/my-recipes` | Get the logged-in user's own recipes | Yes |
| POST | `/api/recipes` | Create a recipe | Yes |
| PUT | `/api/recipes/{id}` | Update a recipe (owner only) | Yes |
| DELETE | `/api/recipes/{id}` | Delete a recipe (owner only) | Yes |
| POST | `/api/recipes/{id}/like` | Toggle like on a recipe | Yes |
| POST | `/api/recipes/{id}/save` | Toggle save/bookmark on a recipe | Yes |
| GET | `/api/recipes/saved` | Get the logged-in user's saved recipes | Yes |
| POST | `/api/reviews/add` | Add a rating/comment to a recipe | Yes |
| GET | `/api/reviews/recipe/{recipeId}` | Get all reviews for a recipe | No |
| GET | `/api/dashboard/stats/{userId}` | Get a user's recipe/like/save/rating stats | Yes |

---

## Frontend

The Flutter Web app is organized by feature: authentication (login/register), the public landing page and browse/home feed, recipe detail/add/edit/search/categories, a personal dashboard, saved recipes, a profile screen, and static pages (About, Contact, 404). State — including the logged-in user and JWT token — is managed via the Provider package (`AuthProvider`, `ThemeProvider`), and all backend communication goes through a dedicated API service layer (`ApiClient`, `RecipeService`, `AuthService`) so the base URL and auth headers are handled in one place. The UI is responsive and adapts between mobile and desktop layouts, with light/dark theme support.

---

## Environment Configuration

Sensitive values are supplied via environment variables at deploy time rather than being committed to the repository:

```
DB_URL=jdbc:postgresql://<host>:5432/postgres
DB_USERNAME=your_database_username
DB_PASSWORD=your_database_password
JWT_SECRET=your_jwt_signing_secret
PORT=8080
```

Real credentials must never be committed. Use a local, git-ignored configuration for development, and set these as environment variables in your hosting platform (e.g. Railway) for production.

---

## Local Development Setup

### Prerequisites
- Java 17
- Maven
- Flutter SDK
- Access to a PostgreSQL instance (e.g. Supabase)

### Backend Setup
```bash
cd backend
# Set DB_URL, DB_USERNAME, DB_PASSWORD as environment variables,
# or edit src/main/resources/application.properties directly for local dev
mvn spring-boot:run
```
The API will be available at `http://localhost:8080/api`.

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

To build for deployment:
```bash
flutter build web
```

---

## Deployment

| Layer | Platform | Status |
|---|---|---|
| Frontend | Vercel | Deployed — [live](https://recipebook-xi-three.vercel.app) |
| Backend | Railway | Deployed — [live](https://recipebook-production-108c.up.railway.app/api) |
| Database | Supabase (PostgreSQL) | Deployed |

**Note on migration:** the project originally targeted Azure SQL Database with a locally-run backend. It was later migrated to Railway (backend hosting) and Supabase PostgreSQL (database) for a fully deployed, publicly accessible setup — including rewriting native SQL queries from SQL Server syntax to PostgreSQL syntax.

---

## Roadmap

### Completed
- User registration & JWT login
- Recipe CRUD (create, edit, delete, browse)
- Search & category filtering
- Likes, saves, ratings, and comments
- Per-user dashboard stats
- Responsive Flutter Web UI with light/dark theme
- Full public deployment (Vercel + Railway + Supabase)

### Planned
- Automated testing
- CI/CD pipeline
- Dedicated image storage instead of external image URLs
- Pagination for recipe listings
- Production monitoring and observability
- Tightened production security rules (some endpoints are currently open for development convenience)

---

## Testing

No automated tests are currently implemented.

**Future Testing:** unit tests for service-layer logic, integration tests for API endpoints, and widget tests for key Flutter screens.

---

## Learning / Engineering Highlights

This project demonstrates:
- End-to-end full-stack development across Flutter and Spring Boot
- REST API design with a layered backend architecture (Controller/Service/Repository/DTO)
- Stateless authentication using JWT and secure password storage with BCrypt
- Integration with a cloud-hosted relational database (Supabase PostgreSQL), including migrating a production data layer between providers and database engines
- Frontend state management and API integration in Flutter
- Debugging distributed, multi-service deployments (Vercel + Railway + Supabase) using live logs and network inspection

---

## Author

**Ubaira Patujo**
Computer Science student, NED University of Engineering and Technology, Karachi

---

## License

License: To be added.
