# FunRun Architecture Design

## 1. Overview
FunRun is a gamified running application that transforms ordinary running into an interactive adventure. It uses real-time GPS tracking to trigger quests, raids, and rewards.

## 2. Core Features
- **Map-based Interactions:** Checkpoints and quests appear on the map based on user location.
- **Tier System:** Progression through levels and tiers (Bronze, Silver, Gold, etc.) with associated rewards.
- **Real-time Quests:**
    - **Speed Challenges:** Sprint between two points.
    - **Cooperative Raids:** Multiple runners contributing to a total distance goal to "defeat a boss".
- **Social Integration:** Shared goals and competitive leaderboards.

## 3. Tech Stack
- **Backend:** NestJS (TypeScript), PostgreSQL (TypeORM), WebSockets for real-time updates.
- **Mobile:** Flutter (Dart) for high-performance cross-platform support.
- **Admin Panel:** React-based dashboard for managing quests and monitoring users.

## 4. System Components
### Backend Server (`apps/backend-server`)
- **Runs Module:** Tracks coordinates, calculates distance, and manages run state.
- **Users Module:** Manages profiles, tiers, and progression data.
- **Quests Module:** (Future) Manages quest logic and triggers.

### Mobile App (`apps/mobile-app-flutter`)
- **Map Interaction:** Using `google_maps_flutter`.
- **Location Tracking:** Background GPS tracking with `geolocator`.
- **State Management:** Provider or Riverpod.

### Shared Packages (`packages/`)
- **Types:** Shared DTOs and interfaces.
- **Utils:** Common functions for distance calculations (Haversine formula).
