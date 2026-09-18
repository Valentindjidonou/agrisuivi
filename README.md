> **Prérequis** : Flutter ≥ 3.27 (le thème utilise `Color.withValues` et
> `CardThemeData`, disponibles à partir de cette version). Vérifiez votre
> version avec `flutter --version` et mettez à jour avec `flutter upgrade`
> si nécessaire.

# 🌾 AgriSuivi

Application mobile Flutter destinée aux petits exploitants agricoles pour suivre
leurs cultures, consulter des conseils saisonniers et recevoir des rappels —
**entièrement hors-ligne**.

## ✨ Fonctionnalités

- **Suivi des cultures** — fiche par culture/parcelle (type, date de semis, stade,
  superficie, note libre, photo).
- **Carnet d'activités** — arrosage, traitement, désherbage, récolte, avec date et remarque.
- **Conseils saisonniers** — base de conseils pré-remplie, filtrée par saison et type de culture.
- **Alertes et rappels** — notifications locales programmées (`flutter_local_notifications`).
- **Tableau de bord** — cultures actives, prochaines alertes, conseils du moment.

## 🖼️ Design

Interface Material 3 moderne : thème vert agriculture, cartes arrondies,
dégradés doux, typographie Inter/Poppins (`google_fonts`), gros boutons et
icônes explicites pour un usage simple sur smartphone d'entrée de gamme.

## 🏗️ Architecture

```
lib/
├── models/        # Culture, Activite, Alerte, ConseilSaisonnier
├── services/       # DatabaseService (sqflite), NotificationService
├── repositories/   # Requêtes sqflite isolées (Culture, Activity, Alert, Advice)
├── providers/      # Gestion d'état (Provider / ChangeNotifier)
├── screens/        # Écrans (accueil, cultures, détail, formulaires, conseils, paramètres)
├── widgets/        # Composants réutilisables (cartes, empty states, stat tiles)
├── theme/          # Thème visuel centralisé
└── utils/          # Détermination de la saison en cours
```

## 📦 Stack technique

| Domaine | Choix |
|---|---|
| Framework | Flutter / Dart |
| Gestion d'état | Provider (ChangeNotifier) |
| Stockage | sqflite (local, hors-ligne) |
| Notifications | flutter_local_notifications + timezone |
| Photos | image_picker |
| Police | google_fonts (Inter / Poppins) |

## 🚀 Installation

Ce dossier contient le **code source Dart** du projet (`lib/`, `pubspec.yaml`,
`test/`). Comme il ne contient pas encore les projets natifs (Android/iOS/
Windows/macOS/Linux), générez-les d'abord avec Flutter avant de lancer
l'application.

### Sur desktop (Windows / macOS / Linux)

Le stockage local utilise `sqflite`, qui n'a pas d'implémentation native sur
desktop : le projet bascule donc automatiquement sur `sqflite_common_ffi`
lorsqu'il détecte Windows, macOS ou Linux (voir `DatabaseService`). Rien à
configurer côté code, mais il faut activer la plateforme desktop dans Flutter :

```bash
# 1. Activez la plateforme souhaitée (une seule fois par machine)
flutter config --enable-windows-desktop   # ou --enable-macos-desktop / --enable-linux-desktop

# 2. Depuis le dossier agrisuivi/, générez les projets natifs
flutter create . --project-name agrisuivi --platforms=windows,macos,linux

# 3. Installez les dépendances
flutter pub get

# 4. Lancez l'application
flutter run -d windows   # ou -d macos / -d linux
```

### Sur mobile (Android / iOS)

```bash
flutter create . --project-name agrisuivi --platforms=android,ios
flutter pub get
flutter run
```

> Aucune configuration réseau ou clé API n'est nécessaire : toutes les données
> restent stockées localement sur l'appareil.

> ⚠️ **Flutter Web n'est pas supporté par ce projet** : `sqflite` n'a pas
> d'équivalent web viable pour cette architecture ; l'application est conçue
> pour desktop et mobile.

### Permission de notifications (Android 13+)

Après `flutter create .`, ajoutez cette ligne dans
`android/app/src/main/AndroidManifest.xml` (au même niveau que les autres
`<uses-permission>`, si elle n'y figure pas déjà) :

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### Générer l'icône de l'application

Placez une image carrée (1024×1024) dans `assets/icon/app_icon.png`, puis :

```bash
flutter pub run flutter_launcher_icons
```

## 🧪 Tests

```bash
flutter test
```

- **Test unitaire** — `CultureRepository` : ajout puis lecture d'une culture en base.
- **Test de widget** — validation des champs obligatoires du formulaire de culture.

## 📱 Écrans principaux

1. Accueil (tableau de bord)
2. Liste des cultures
3. Détail culture (onglets Activités / Alertes)
4. Formulaire culture (ajout / modification)
5. Formulaire activité
6. Formulaire alerte
7. Conseils saisonniers
8. Paramètres

## 🔒 Limites assumées (v1)

- Un seul utilisateur par installation, pas de compte ni de synchronisation multi-appareils.
- Pas de carte géographique (localisation des parcelles par simple étiquette texte).
- Les conseils saisonniers sont embarqués localement ; une synchronisation distante
  (Firebase) pourrait être envisagée comme évolution future.
