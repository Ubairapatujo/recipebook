# RecipeBook Flutter Frontend — Warm Editorial Redesign

This folder is a replacement for your existing `frontend` folder. It keeps
your existing screens, recipe content, API services, authentication flow, and
routes, while updating the visual frontend to a warm editorial recipe-book
experience.

## What changed

- Cream paper-inspired light theme with dark brown editorial text
- Coral accent color and sage secondary color
- Playfair Display headings with DM Sans body text
- Updated navigation and account menu
- Redesigned landing hero
- Redesigned recipe cards with bookmark/like actions
- Softer pill buttons, category filters, search field, borders, shadows, and hover motion
- Existing routes and backend service code preserved
- The landing-page hero uses a local visual and does not call an unrelated
  third-party image service

## Replace your frontend

1. Back up your current `frontend` folder.
2. Delete or rename the current `frontend` folder in your project.
3. Copy this entire folder into the project and name it `frontend`.
4. Open the project in Visual Studio or VS Code.
5. Run:

```bash
flutter pub get
flutter run -d chrome
```

## Configure the backend URL

Before deploying, open:

```text
lib/config/api_config.dart
```

Replace the localhost URL with the public URL of your Spring Boot backend:

```dart
class ApiConfig {
  static const String baseUrl = 'https://your-backend-domain.com/api';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
```

Do not include a trailing slash after `api`.

## Build for deployment

```bash
flutter build web --release
```

Deploy the generated folder:

```text
build/web
```

## Important

- This package changes the frontend only.
- Your Spring Boot backend is not included in this package and should remain in
  its existing `backend` folder.
- Recipe data, authentication, API calls, route names, and existing screen
  content are preserved.
- If the landing page displays “BACKEND CONNECTION NEEDED”, the frontend
  cannot reach the URL in `lib/config/api_config.dart`. For local Chrome
  testing, start your Spring Boot backend on port 8080. For deployment, use
  the public backend URL and allow the frontend origin in the backend CORS
  configuration.
