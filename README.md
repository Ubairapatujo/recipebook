# RecipeBook

A full-stack recipe-sharing web application — built to let people create, discover, and interact with recipes shared by other users.

**Stack:** Flutter Web → Spring Boot REST API (JWT auth) → PostgreSQL (Supabase)

**Live:** [Frontend](https://recipebook-xi-three.vercel.app) · [Backend API](https://recipebook-production-108c.up.railway.app/api)

![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-REST%20API-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-Web-blue)
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL%20%2F%20Supabase-336791)
![JWT](https://img.shields.io/badge/Auth-JWT-yellow)

---

## Overview

RecipeBook is a full-stack application where users can register, log in, and share recipes with the community. Other users can browse recipes, search and filter by category, like and save recipes they enjoy, and leave comments. Each user can manage their own recipes (create, edit, delete) through a dedicated dashboard.

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
- JWT-based stateless authentication
- BCrypt password hashing
- Route-level authorization (owner-only edit/delete)

### Recipe Management
- Create, edit, and delete recipes (owner-only)
- View a user's own recipes ("My Recipes")

### Discovery & Search
- Browse all recipes
- Search recipes by title
- Filter recipes by category

### User Features
- Like / unlike recipes, with per-user like state and a live total count
- Save / bookmark recipes for later, with a dedicated saved-recipes view
- Comment on recipes

### UI/UX
- Responsive Flutter Web interface
- Recipe detail screen with hero image, ingredients, and step-by-step instructions
- Light/dark theme support

---

## Tech Stack

| Technology | Purpose | Where it's used |
|---|---|---|
| Flutter (Web) | Frontend UI framework | `frontend/` |
| Provider | Frontend state management | `frontend/lib/providers` |
| Spring Boot | Backend REST API framework | `backend/` |
| Spring Security | Authentication & authorization | `backend/security`, `backend/config` |
| JWT | Stateless auth tokens | `backend/security` |
| BCrypt | Password hashing | `backend/service` |
| PostgreSQL / Supabase | Relational database | Cloud-hosted (Supabase) |
| Spring Data JPA / Hibernate | ORM / database access | `backend/repository`, `backend/model` |
| Maven | Backend build tool | `backend/pom.xml` |

---

## Project Structure

```
recipebook/
├── backend/
│   └── src/main/java/com/recipebook/backend/
│       ├── controller/    REST endpoints
│       ├── service/       Business logic
│       ├── repository/    Data access (Spring Data JPA)
│       ├── model/         JPA entities
│       ├── dto/           Request/response objects
│       ├── security/      JWT filter, JWT utilities
│       ├── config/        Security & CORS configuration
│       └── exception/     Custom exceptions & handling
└── frontend/
    └── lib/
        ├── models/        Data models
        ├── services/      API service layer
        ├── providers/     App state (auth, etc.)
        ├── screens/       App screens (home, detail, auth, dashboard, etc.)
        └── widgets/       Reusable UI components
```

---

## Backend Architecture

- **Controller** — exposes REST endpoints, extracts the authenticated user from the request, and delegates to the service layer.
- **Service** — contains business logic (e.g. toggling a like, computing like counts, building API responses).
- **Repository** — Spring Data JPA interfaces for database access.
- **Model** — JPA entities mapped to SQL Server tables (`Recipe`, `User`, `RecipeLike`, `SavedRecipe`, `Review`, etc.).
- **DTO** — request/response objects that shape what the API sends and receives, decoupled from the database entities.
- **Security/Config** — JWT filter (`JwtAuthFilter`) validates tokens on each request and populates the security context; `SecurityConfig` defines route access rules and CORS policy.
- **Exception** — centralized handling for cases like resource-not-found and unauthorized actions.

---

## Authentication & Security

- Users register and log in via `/api/auth/register` and `/api/auth/login`.
- Passwords are hashed with BCrypt before being stored — plaintext passwords are never persisted.
- On login, the backend issues a JWT, which the frontend stores and sends as a `Bearer` token on subsequent requests.
- A custom `JwtAuthFilter` runs on every request, validates the token, and sets the authenticated user in Spring Security's context.
- Protected actions (creating/editing/deleting recipes, liking, saving, commenting) require a valid token; ownership checks ensure users can only edit or delete their own recipes.
- Database credentials and JWT secrets are kept out of source control via environment-based configuration — never committed to GitHub.

---

## Database

- **Engine:** PostgreSQL, hosted on **Supabase**.
- The backend connects via Spring Data JPA / Hibernate over Supabase's Session Pooler connection, with schema managed through Hibernate's `ddl-auto` setting.
- **Core entities:** `User`, `Recipe`, `RecipeLike`, `SavedRecipe`, `Review` (used for both comments and ratings).

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
| POST | `/api/recipes/{id}/comments` | Add a comment to a recipe | Yes |
| GET | `/api/recipes/{id}/comments` | Get a recipe's comments | No |

---

## Frontend

The Flutter Web app consists of screens for home/browse, search, recipe details, add/edit recipe, a personal dashboard, and saved recipes. State (such as the logged-in user and token) is managed via the Provider package, and all backend communication goes through a dedicated API service layer. The UI is responsive and adapts between mobile and desktop layouts.

---

## Environment Configuration

Sensitive values are supplied via environment-specific configuration rather than being committed to the repository:

```
DATABASE_URL=your_database_url
DATABASE_USERNAME=your_database_username
DATABASE_PASSWORD=your_database_password
JWT_SECRET=your_jwt_secret
```

Real credentials must never be committed. Use a local, git-ignored configuration file for development.

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
# Configure src/main/resources/application.properties with your DB details
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

## Configuration

- **Backend API base URL:** configured in the frontend's API service layer.
- **CORS:** configured via a `CorsConfigurationSource` bean, allowing the deployed frontend origin and local development origins.
- **JWT:** configured through `JwtAuthFilter` and related security configuration.

---

## Deployment

| Layer | Platform | Status |
|---|---|---|
| Frontend | Vercel | Deployed — [live](https://recipebook-xi-three.vercel.app) |
| Backend | Railway | Deployed — [live](https://recipebook-production-108c.up.railway.app/api) |
| Database | Supabase (PostgreSQL) | Deployed |

**Note on migration:** the project originally targeted Azure SQL Database with a locally-run backend. It was later migrated to Railway (backend hosting) and Supabase PostgreSQL (database) for a fully deployed, publicly accessible setup.

---

## GitHub Safety

- `.gitignore` excludes local configuration files, build artifacts, and dependency directories.
- Database credentials, JWT secrets, and other sensitive configuration are never committed.
- Production configuration values are supplied via environment variables at deploy time, not hardcoded in source.

---

## Roadmap

### Completed
- User registration & JWT login
- Recipe CRUD (create, edit, delete, browse)
- Search & category filtering
- Likes, saves, and comments
- Responsive Flutter Web UI with light/dark theme
- Full public deployment (Vercel + Railway + Supabase)

### In Progress
- Rating aggregation (average rating per recipe)

### Planned
- Automated testing
- CI/CD pipeline
- Image upload/storage
- Production monitoring

---

## Testing

No automated tests are currently implemented.

**Future Testing:** unit tests for service-layer logic, integration tests for API endpoints, and widget tests for key Flutter screens.

---

## Future Improvements

- Automated testing and CI/CD
- Dedicated image storage instead of external image URLs
- Pagination for recipe listings
- Stronger input validation
- Production monitoring and observability
- Tightened production security rules (currently some endpoints are open for development convenience)

---

## Learning / Engineering Highlights

This project demonstrates:
- End-to-end full-stack development across Flutter and Spring Boot
- REST API design with a layered backend architecture (Controller/Service/Repository/DTO)
- Stateless authentication using JWT and secure password storage with BCrypt
- Integration with a cloud-hosted relational database (Supabase PostgreSQL), including migrating a production data layer between providers
- Frontend state management and API integration in Flutter
- Secure configuration practices for sensitive credentials

---

## Author

**Eira**
Computer Science student, NED University of Engineering and Technology, Karachi

---

## License

License: To be added.
