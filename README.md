<div align="center">

<img src="assets/images/logo.png" alt="Unus" width="120" />

# Unus (أُنس)

A Flutter app that helps you plan your event with ease — from a family gathering to a wedding night — by suggesting a complete plan that fits your budget and guest count, and connecting you with the best service providers in one place.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com)

</div>

---

## About Unus 

**Unus** is a comprehensive Flutter Camp graduation project designed to be an all-in-one digital companion that guides users seamlessly from the initial concept of an event all the way to its full execution.

The application streamlines event planning through a smart, user-centric journey:

**Interactive Onboarding & Assessment:**
The app begins by asking a few quick, targeted questions regarding the event type, location, guest count, budget, and specific requirements.

## Smart Plan Generation:
Based on the user's inputs, Unus instantly suggests a complete, customized event plan that bundles the best-fit service providers—including venues, catering, decor, hospitality, photography, and specialized bridal services.

## Seamless Management & Favorites: 
Users can easily explore options, save their favorite service providers and customized plans to their profile, and revisit them anytime for effortless decision-making.


## The Name & Logo

**"Unus" (أُنس)** is an Arabic word for the warmth of companionship — the comfort and ease of being surrounded by people you love. It's the feeling every gathering the app helps plan is meant to create.

The logo carries that same idea: four interlocking gold rings arranged in a diamond, each one looping into the next — like people gathered close and bonded together in one continuous circle, rather than standing apart. Set in Gold against a deep Burgundy backdrop, it reflects the warmth and togetherness at the heart of the app.

## Key Features

- **Onboarding** — an interactive question flow (selectable cards, sliders, collapsible categories) that captures the user's preferences.
- **Recommended plan** — a service-provider recommendation built from the user's answers, with details for each provider and the option to swap in an alternative.
- **Favorites** — save individual providers or full plans, synced through Supabase per signed-in user.
- **Account** — sign in / sign up via Supabase Auth, with a "Skip for now" flow to browse the app without an account.
- **Profile** — edit the display name, a "Who we are" page, and an interactive "Where are we?" card showing available and upcoming cities.
- **Full Arabic support** — RTL layout and Google Fonts (Amiri) throughout every screen.

## Screenshots

> soon ...

## Tech Stack

| Category | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) (Dart SDK ^3.13.1) |
| Database & Auth | [Supabase](https://supabase.com) (`supabase_flutter`) |
| Environment config | `flutter_dotenv` |
| Fonts | `google_fonts` (Amiri) |
| Local storage | `shared_preferences` |
| Bottom navigation | `curved_navigation_bar` |
| Video playback | `video_player` + `fvp` (desktop support) |
| Link launching | `url_launcher` |

## Brand Colors

| Swatch | Hex Code | Meaning & Usage |
|---|---|---|
| ![#4A1620](https://placehold.co/60x24/4A1620/4A1620.png) | `#4A1620` **Burgundy** | The primary brand color. Used for app bars, primary buttons, icons, and most Burgundy-colored text — conveys the elegance and warmth fitting for an event-planning app. |
| ![#683E46](https://placehold.co/60x24/683E46/683E46.png) | `#683E46` **Burgundy White** | A lighter, muted burgundy used for secondary accents — toggle switches and buttons on the onboarding questions and sign-up screens — softer than the primary Burgundy so it doesn't compete with it. |
| ![#F4EEE4](https://placehold.co/60x24/F4EEE4/F4EEE4.png) | `#F4EEE4` **Beige** | The default background color across almost every screen. A warm, low-contrast backdrop that lets the Burgundy and Gold accents stand out. |
| ![#D4AF6A](https://placehold.co/60x24/D4AF6A/D4AF6A.png) | `#D4AF6A` **Gold** | An accent color for borders, selected-state highlights (e.g. the floating circle on the bottom nav bar), and badges — evokes celebration and a touch of luxury. |
| ![#FFFFFF](https://placehold.co/60x24/FFFFFF/CCCCCC.png) | `#FFFFFF` **White** | Used for card backgrounds, input fields, and surfaces that need to stand out clearly against the Beige background. |

Defined in [`lib/constants/app_colors.dart`](lib/constants/app_colors.dart).

## Project Structure

```
lib/
├── constants/    # Brand colors
├── models/       # Data models
├── screens/      # App screens
├── service/      # Supabase data access
├── widgets/      # Shared UI widgets
└── main.dart     # App entry point

supabase/
└── favorites_schema.sql   # SQL script to create the favorite providers/plans tables in Supabase
```

### Classes  

| Class | Description |
|---|---|
| `AppColors` | The app's color palette |
| `FavoritePlan` | A saved recommended plan |
| `OnboardingAnswers` | The user's onboarding answers |
| `OnboardingSession` | Holds the app's current onboarding answers |
| `Providers` | A service provider record |
| `QuestionModel` | One onboarding question |
| `AboutUsScreen` | "من نحن" page |
| `CreatAcountScreen` | Sign in / sign up screen |
| `FavoritePlanDetailScreen` | Details of a saved plan |
| `FavoritesScreen` | Saved providers and plans |
| `HelloScreen` | Splash/welcome screen |
| `MyInfoScreen` | Edit account info |
| `ProfileScreen` | User profile page |
| `ProviderDetailScreen` | Details of one service provider |
| `QuestionScreen` | Renders one onboarding question |
| `RecommendedPlanScreen` | Home screen with the recommended plan |
| `FavoritesDatabaseService` | Saves/loads favorites in Supabase |
| `ProvidersDatabaseService` | Loads service providers from Supabase |
| `AppBottomNavBar` | The bottom navigation bar |
| `MainApp` | App root widget |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and configured (`flutter doctor`).
- A [Supabase](https://supabase.com) account with a project set up.

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure environment variables

Create a `.env` file at the project root with the following keys (read via `flutter_dotenv` in `lib/main.dart`):

```env
our_url_key=YOUR_SUPABASE_PROJECT_URL
our_publishableKey=YOUR_SUPABASE_PUBLISHABLE_KEY
```

### 3. Set up the database

Run [`supabase/favorites_schema.sql`](supabase/favorites_schema.sql) once in your Supabase project's SQL editor to create the `favorite_providers` and `favorite_plans` tables along with their RLS policies. This feature only works for signed-in users (not the "Skip for now" flow).

### 4. Run the app

```bash
flutter run
```

## Testing

```bash
flutter test
```

## Contributing

This is a graduation project built as part of Flutter Camp. Contributions and suggestions are welcome via [Issues](https://github.com/Amna-0/Final_Project/issues) or Pull Requests.

---

<div align="center">Made with 🤎 by Amna & Aryam for Flutter Boot Camp</div>
