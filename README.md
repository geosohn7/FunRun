# FunRun Project

This project is a gamified running application built using a **Monorepo** structure. It combines a mobile client for runners and a backend server for tracking and gamification logic.

## 🚀 Tech Stack

### core
- **Monorepo Manager:** NPM Workspaces
- **Languages:** TypeScript (Backend/Shared), Dart (Mobile)

### Apps (`/apps`)
- **📱 Mobile App (`apps/mobile_app_flutter`)**: built with **Flutter (Dart)**.
  - Key libraries: `google_maps_flutter`, `geolocator`, `http`.
- **💻 Backend Server (`apps/backend-server`)**: built with **NestJS (TypeScript)**.
  - Database: **PostgreSQL** with **TypeORM**.
- **🛠 Admin Panel (`apps/admin-panel`)**: (In progress) Intended for web-based dashboarding.

### Packages (`/packages`) - Shared Logic
- **📦 types**: Shared TypeScript interfaces, DTOs, and enums.
- **🛠 utils**: Shared utility functions (e.g., Haversine formula for distance calculation).

## 🛠 Getting Started

1.  **Backend**:
    ```bash
    npm run start:backend
    ```
2.  **Mobile**:
    ```bash
    npm run start:mobile
    ```

For detailed architectural decisions, see `architecture_design.md`.
