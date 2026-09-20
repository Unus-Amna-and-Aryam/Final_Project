<div align="center">
<img src="assets/images/logo_round.png" alt="Unus logo" width="120" />
<h1>Unus · أُنس</h1>
 
[**Live Demo**](https://unus-flutter.vercel.app) · [**Project Links**](https://unus-linktree.vercel.app) 
 
**Plan your whole event in one place, from family gatherings to weddings.**
 
[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![RTL](https://img.shields.io/badge/Layout-Arabic%20RTL-4A1620)](#features)
 
[**Live Demo**](https://unus-flutter.vercel.app) · [**Project Links**](https://unus-linktree.vercel.app) · [**Report an Issue**](../../issues)
 
</div>

---
 
## Table of Contents
 
- [Overview](#overview)
- [How It Works](#how-it-works)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Roadmap](#roadmap)
- [Brand Identity](#brand-identity)
- [Team](#team)
---
 
## Overview
 
Planning an event usually means searching in many different places for a venue, catering, decor, photography and more. **Unus** asks a few questions about your event, then suggests a full plan based on your budget and guest count, with all the service providers in one place.
 
Unus is our graduation project for **Flutter Bootcamp**.
 
## How It Works
 
1. **Tell us about your event.** Answer questions about the event type, location, guest count, budget and needs.
2. **Get your plan.** Unus suggests a plan with providers for venues, catering, decor, hospitality, photography and bridal services.
3. **Refine and save.** Swap any provider for another one, and save providers or full plans to your favorites.
## Features
 
| Feature | Description |
|---|---|
| 🧭 **Smart onboarding** | Question screens with selectable cards, sliders and collapsible categories. |
| 📋 **Recommended plan** | Providers suggested based on the user's answers, with details for each one and the option to swap it. |
| 🤍 **Favorites** | Save providers or full plans, synced with Supabase for each signed-in user. |
| 🔐 **Authentication** | Sign in and sign up with Supabase Auth, or browse as a guest with **Skip for now**. |
| 👤 **Profile** | Edit your display name, read the "Who we are" page, and see current and upcoming cities in "Where are we?". |
| 💌 **Invitations** | Design invitations for your event and send them to your guests. |
| 🌙 **Full Arabic support** | Right-to-left layout and the Amiri font on every screen. |
 
## Screenshots
 
Screenshots will be added soon. You can try the web version here: **[unus-flutter.vercel.app](https://unus-flutter.vercel.app)**
 
## Tech Stack
 
| Category | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) (Dart SDK `^3.13.1`) |
| Backend, database & auth | [Supabase](https://supabase.com) (`supabase_flutter`) |
| Environment config | `flutter_dotenv` |
| Typography | `google_fonts` (Amiri) |
| Local storage | `shared_preferences` |
| Navigation | `curved_navigation_bar` |
| Media | `video_player` + `fvp` (desktop support) |
| External links | `url_launcher` |
 
## Architecture
 
```
lib/
├── constants/    # Brand colors (AppColors)
├── models/       # Data models
├── screens/      # App screens
├── service/      # Supabase data access
├── widgets/      # Shared UI widgets
└── main.dart     # App entry point (MainApp)
 
supabase/
└── favorites_schema.sql   # Creates the favorites tables and their RLS policies
```
 
<details>
<summary><b>Key classes</b></summary>
**Models**
 
| Class | Responsibility |
|---|---|
| `QuestionModel` | A single onboarding question |
| `OnboardingAnswers` | The user's answers to the onboarding flow |
| `OnboardingSession` | Holds the current onboarding answers across the app |
| `Providers` | A service provider record |
| `FavoritePlan` | A saved recommended plan |
 
**Services**
 
| Class | Responsibility |
|---|---|
| `ProvidersDatabaseService` | Loads service providers from Supabase |
| `FavoritesDatabaseService` | Saves and loads favorites in Supabase |
 
**Screens**
 
| Class | Responsibility |
|---|---|
| `HelloScreen` | Splash / welcome screen |
| `CreatAcountScreen` | Sign in / sign up |
| `QuestionScreen` | Renders one onboarding question |
| `RecommendedPlanScreen` | Home screen showing the recommended plan |
| `ProviderDetailScreen` | Details of a single provider |
| `FavoritesScreen` | Saved providers and plans |
| `FavoritePlanDetailScreen` | Details of a saved plan |
| `ProfileScreen` | User profile |
| `MyInfoScreen` | Edit account information |
| `AboutUsScreen` | "About us" page |
 
**Shared**
 
| Class | Responsibility |
|---|---|
| `AppColors` | The app's color palette |
| `AppBottomNavBar` | Bottom navigation bar |
 
</details>

## Getting Started
 
### Prerequisites
 
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and verified with `flutter doctor`
- A [Supabase](https://supabase.com) project
### Installation
 
**1. Clone the repository and install dependencies**
 
```bash
git clone <repository-url>
cd <repository-folder>
flutter pub get
```
 
**2. Configure environment variables**
 
Create a `.env` file in the project root. These keys are read by `flutter_dotenv` in `lib/main.dart`:
 
```env
our_url_key=YOUR_SUPABASE_PROJECT_URL
our_publishableKey=YOUR_SUPABASE_PUBLISHABLE_KEY
```
 
> [!IMPORTANT]
> Never commit your `.env` file. Make sure it is listed in `.gitignore`.
 
**3. Set up the database**
 
Run [`supabase/favorites_schema.sql`](supabase/favorites_schema.sql) once in your Supabase SQL editor. It creates the `favorite_providers` and `favorite_plans` tables along with their Row Level Security policies.
 
> [!NOTE]
> Favorites are available to signed-in users only, not in guest (**Skip for now**) mode.
 
**4. Run the app**
 
```bash
flutter run
```
 
### Running Tests
 
```bash
flutter test
```
 
## Roadmap
 
Features we plan to add in future versions:
 
### Phase 1: Users
- [ ] In-app booking so users can reserve providers directly from their plan
- [ ] Ratings and reviews for service providers
- [ ] Guest list management with RSVP tracking for sent invitations
- [ ] Budget tracker that updates as providers are added or swapped
### Phase 2: Service Providers
- [ ] Provider dashboard for managing listings, pricing and availability
- [ ] Provider verification and onboarding flow
- [ ] In-app chat between users and providers
- [ ] Secure online payments
### Phase 3: Expansion
- [ ] Expansion to additional cities across Saudi Arabia
- [ ] English language support alongside Arabic
- [ ] Push notifications for bookings, RSVPs and event reminders
- [ ] Release on the Google Play Store and Apple App Store
## Brand Identity
 
### The Name
 
**Unus** is an Arabic word that means the comfort of being with the people you love. We chose it because that is the feeling we want every event planned with the app to have.
 
### The Logo
 
The logo is four gold rings linked together in a diamond shape. The rings represent people gathered together, and the gold on burgundy matches the app's colors.
 
### Color Palette
 
| Name | Hex | Usage |
|---|---|---|
| Burgundy | `#4A1620` | Primary brand color: app bars, primary buttons, icons and most text |
| Burgundy White | `#683E46` | Softer secondary accent: toggles and buttons on onboarding and sign-up |
| Beige | `#F4EEE4` | Default background across the app |
| Gold | `#D4AF6A` | Borders, selected states and badges |
| White | `#FFFFFF` | Cards, input fields and elevated surfaces |
 
All colors are defined in [`lib/constants/app_colors.dart`](lib/constants/app_colors.dart).
 
## Team
 
| Name | Links |
|---|---|
| **Amna Ahmed Mohammed** | [GitHub](https://github.com/Amna-0) · [LinkedIn](https://www.linkedin.com/in/amna-mohammed-612623381) |
| **Aryam Mohammed Alshahrani** | [GitHub](https://github.com/AryamAlshahrani46) · [LinkedIn](https://www.linkedin.com/in/aryam-alshahrani-5b12b341b) |
 
## Contributing
 
To report a bug or suggest an idea, open an [issue](../../issues) or a pull request.
 
---
 
<div align="center">
Built with 🤎 by Amna & Aryam as a graduation project for **Flutter Bootcamp**
 
</div>
 
