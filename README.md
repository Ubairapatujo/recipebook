# RecipeBook

A full-stack recipe sharing app.

**Stack:** Flutter (Web) → Spring Boot REST API (JWT auth) → SQL Server

## Structure
```
recipebook/
├── backend/   Spring Boot (Java 17, Maven)
└── frontend/  Flutter Web app
```

## Backend Setup

1. Open `backend/src/main/resources/application.properties` and fill in your SQL Server details:
   - `spring.datasource.url`
   - `spring.datasource.username`
   - `spring.datasource.password`

2. Tables are auto-created on first run (`spring.jpa.hibernate.ddl-auto=update`) — no manual SQL needed.

3. Run locally:
   ```
   cd backend
   mvn spring-boot:run
   ```
   API will be live at `http://localhost:8080/api`

### Key endpoints
| Method | Endpoint | Auth required |
|---|---|---|
| POST | /api/auth/register | No |
| POST | /api/auth/login | No |
| GET | /api/recipes | No |
| GET | /api/recipes/{id} | No |
| GET | /api/recipes/my-recipes | Yes |
| POST | /api/recipes | Yes |
| PUT | /api/recipes/{id} | Yes (owner only) |
| DELETE | /api/recipes/{id} | Yes (owner only) |

## Frontend Setup

1. Update `frontend/lib/services/api_client.dart` with your backend URL.
2. Run:
   ```
   cd frontend
   flutter pub get
   flutter run -d chrome        # for local testing
   flutter build web            # for deployment
   ```

## Deployment (see chat for full day-by-day plan)
- Backend → Render.com (free tier, supports Spring Boot via Docker or native build)
- Database → Azure SQL free tier
- Frontend → Firebase Hosting (`flutter build web` output)
