# 🌾 AgriSuivi

Application mobile Flutter permettant à un petit exploitant agricole de suivre
ses cultures parcelle par parcelle, de consulter des conseils adaptés à la
saison en cours et de recevoir des rappels — **entièrement hors-ligne**.

> **Prérequis** : Flutter ≥ 3.27 (le thème utilise `Color.withValues` et
> `CardThemeData`, disponibles à partir de cette version). Vérifiez votre
> version avec `flutter --version`.

## Objectif

De nombreux petits exploitants gèrent encore leurs parcelles sur carnet
papier ou de mémoire, ce qui entraîne des oublis (dates de traitement, de
récolte) et une difficulté à suivre l'évolution des cultures d'une saison à
l'autre. AgriSuivi répond à ce besoin avec une application simple, utilisable
sans connexion internet, adaptée à un smartphone d'entrée ou moyenne gamme.

## Fonctionnalités principales

- 🌱 **Suivi des cultures** — fiche par culture/parcelle : type, date de
  semis, stade de croissance, superficie, note libre et photo optionnelle.
- 📗 **Carnet d'activités** — enregistrement des actions réalisées (arrosage,
  traitement, désherbage, récolte) avec date et remarque.
- 💡 **Conseils saisonniers** — base de conseils pré-remplie (~19 conseils),
  filtrée automatiquement selon la saison en cours et le type de culture.
- 🔔 **Alertes et rappels** — notifications locales programmées pour ne pas
  manquer une étape importante (ex. « Traiter le maïs dans 3 jours »).
- 📊 **Tableau de bord** — cultures actives, prochaines alertes et conseils du
  moment, dès l'écran d'accueil.

## Technologies et packages utilisés

| Domaine | Choix | Package |
|---|---|---|
| Framework | Flutter / Dart | — |
| Gestion d'état | Provider (ChangeNotifier) | `provider` |
| Stockage | SQLite local, hors-ligne | `sqflite` (+ `sqflite_common_ffi` sur desktop) |
| Notifications | Rappels locaux programmés | `flutter_local_notifications`, `timezone`, `flutter_timezone` |
| Photos | Sélection d'image galerie | `image_picker` |
| Typographie | Police moderne (Inter/Poppins) | `google_fonts` |
| Icône d'app | Génération multi-résolutions | `flutter_launcher_icons` |

**Choix de stockage** : local uniquement (sqflite), justifié par la
connectivité internet irrégulière des utilisateurs cibles (zones rurales).
Les conseils saisonniers sont embarqués localement dans une base pré-remplie
à la première ouverture.

## Architecture du projet

```
lib/
├── models/        # Classes métier : Culture, Activite, Alerte, ConseilSaisonnier
├── services/      # DatabaseService (sqflite), NotificationService
├── repositories/  # Requêtes sqflite isolées (Culture, Activity, Alert, Advice)
├── providers/     # Gestion d'état (Provider / ChangeNotifier)
├── screens/       # Écrans : accueil, cultures, détail, formulaires, conseils, paramètres
├── widgets/       # Composants réutilisables (cartes, empty states, stat tiles)
├── theme/         # Thème visuel centralisé (Material 3)
└── utils/         # Détermination de la saison en cours
```

## Installation

Ce dépôt contient le **code source Dart** du projet (`lib/`, `pubspec.yaml`,
`test/`). Les projets natifs (Android/iOS/Windows/macOS/Linux) ne sont pas
versionnés (voir `.gitignore`) : ils doivent être générés localement.

### Sur mobile (Android / iOS)

```bash
git clone https://github.com/Valentindjidonou/agrisuivi.git
cd agrisuivi
flutter create . --project-name agrisuivi --platforms=android,ios
flutter pub get
flutter run
```

### Sur desktop (Windows / macOS / Linux)

Le plugin `sqflite` n'a pas d'implémentation native sur desktop : le projet
bascule automatiquement sur `sqflite_common_ffi` lorsqu'il détecte Windows,
macOS ou Linux (voir `DatabaseService`). Il faut simplement activer la
plateforme :

```bash
flutter config --enable-linux-desktop   # ou --enable-windows-desktop / --enable-macos-desktop
flutter create . --project-name agrisuivi --platforms=linux
flutter pub get
flutter run -d linux
```

> Aucune configuration réseau ni clé API n'est nécessaire : toutes les
> données restent stockées localement sur l'appareil. **Flutter Web n'est
> pas supporté** par ce projet (sqflite n'a pas d'équivalent web viable pour
> cette architecture).

### Permission de notifications (Android 13+)

Après `flutter create .`, ajouter dans
`android/app/src/main/AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### Générer l'icône de l'application

Une icône (`assets/icon/app_icon.png`, thème vert/feuille) est déjà fournie.
Pour l'appliquer au projet Android :

```bash
flutter pub run flutter_launcher_icons
```

### Générer l'APK installable

```bash
flutter build apk --release
# fichier généré dans build/app/outputs/flutter-apk/app-release.apk
```

## Lancement de l'application

```bash
flutter run
```

L'application s'ouvre directement sur le tableau de bord. Aucune
authentification n'est requise (un seul utilisateur par installation, voir
« Limites assumées » plus bas).

## Tests réalisés

```bash
flutter test
```

| Type de test | Fichier | Ce qui est vérifié |
|---|---|---|
| Test unitaire | `test/culture_repository_test.dart` | Ajout puis lecture d'une culture en base (CRUD de base du `CultureRepository`) |
| Test de widget | `test/culture_form_widget_test.dart` | Le formulaire d'ajout de culture affiche bien les erreurs de validation sur les champs obligatoires |
| Test d'intégration | `test/integration_flow_test.dart` | Parcours complet : ajouter une culture → la retrouver dans la liste des cultures → ouvrir son détail et vérifier ses informations |

Les trois tests utilisent `sqflite_common_ffi` pour s'exécuter sans appareil
ni émulateur (utile en CI ou sur desktop).

**Débogage effectué pendant le développement** :
- Observation des rebuilds de la liste des cultures avec Flutter DevTools.
- Correction d'un bug où une erreur d'enregistrement laissait le formulaire
  bloqué en chargement indéfiniment (voir « Difficultés rencontrées »).
- Vérification que `sqflite` ne fonctionne pas nativement sur desktop, d'où
  le basculement conditionnel vers `sqflite_common_ffi`.

## Captures d'écran

*(à compléter avant la remise finale — captures des écrans Accueil, Liste
des cultures, Détail d'une culture, Formulaire d'ajout, Conseils saisonniers)*

| Accueil | Cultures | Détail culture |
|---|---|---|
| _capture à ajouter_ | _capture à ajouter_ | _capture à ajouter_ |

## Difficultés rencontrées

- **Formulaires bloqués en cas d'erreur** : les premières versions des
  formulaires (culture, activité, alerte) ne géraient pas les exceptions
  lors de l'enregistrement en base. En cas d'échec, l'indicateur de
  chargement restait actif indéfiniment et l'écran semblait figé. Corrigé en
  encadrant chaque enregistrement d'un `try/catch/finally` avec message
  d'erreur explicite (`SnackBar`).
- **Notification bloquant l'enregistrement d'une alerte** : la programmation
  de la notification locale se faisait avant l'écriture en base ; un refus
  de permission empêchait donc l'alerte d'être sauvegardée. Corrigé en
  découplant les deux opérations : l'alerte est toujours enregistrée, la
  notification est programmée en best-effort.
- **`sqflite` non supporté sur desktop** : le plugin `sqflite` n'a pas
  d'implémentation native pour Windows/macOS/Linux, ce qui empêchait tout
  enregistrement lors des tests sur poste de développement Linux. Résolu en
  basculant automatiquement vers `sqflite_common_ffi` selon la plateforme
  détectée au runtime.
- **Fuseau horaire des rappels** : par défaut, la librairie `timezone`
  utilise UTC. Ajout de `flutter_timezone` pour récupérer le fuseau horaire
  réel de l'appareil et programmer les rappels à l'heure locale attendue.

## Limites assumées (v1)

- Un seul utilisateur par installation : pas de compte ni de synchronisation
  multi-appareils.
- Pas de carte géographique (localisation des parcelles par simple étiquette
  texte).
- Les conseils saisonniers sont embarqués localement ; une synchronisation
  distante (Firebase) pourrait être envisagée comme évolution future.

## Auteur

**Valentin Djidonou** — Projet individuel réalisé dans le cadre du cours
*Développement Mobile* (Semaine 5 : conception — Semaine 6 : réalisation).
