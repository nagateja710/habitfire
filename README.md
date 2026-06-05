# 🔥 HabitFire

A modern offline-first habit tracking application built with Flutter and Hive, designed to help users build consistency, maintain streaks, analyze progress, and preserve completed habit journeys.

HabitFire combines habit tracking, streak management, analytics, calendar visualization, and a unique **Journeys** system that allows users to archive completed habits instead of deleting them.

---

## ✨ Features

### 🏠 Habit Management

* Create and manage habits
* Custom habit names and categories
* Choose active days of the week
* Large built-in icon library
* Edit habits anytime
* Delete habits with confirmation
* Multiple logs per day
* Daily completion tracking

### 🔥 Streak Tracking

Track consistency across all habits with:

* Current streaks
* Best streaks
* Streak leaders
* Peak performance records
* Daily averages
* Habit performance comparisons

### 📅 Calendar View

Visualize your progress using an interactive calendar.

* Monthly, bi-weekly, and weekly views
* Fire-based progress heatmap
* Daily completion percentage
* Historical habit tracking
* Completed and missed habit breakdowns

### 📊 Analytics Dashboard

Gain insights into your productivity.

* Total habits
* Scheduled habits today
* Daily completion rate
* Combined streak count
* Best streak record
* Most consistent habit

### 🏆 Journeys System

HabitFire introduces a unique concept called **Journeys**.

Instead of deleting completed habits, users can retire them into a dedicated archive.

Journey statistics include:

* Start date
* Finish date
* Duration
* Completion rate
* Total logs
* Best streak
* Category information

This allows users to preserve their accomplishments while keeping active habits organized.

### 💾 Backup & Restore

* Export habit data
* Import backups
* Local data persistence
* Reset all data

### 🎨 Modern UI

* Material 3 design
* Dark mode support
* Responsive layouts
* Clean card-based interface
* Custom icon system

### ℹ️ About Page

* Application statistics
* Tracking summary
* Version information
* GitHub repository access
* Developer information

---

## 📱 Screenshots
<h2 align="center">📱 App Screenshots</h2>

<p align="center">
  <img src="assets/screenshots/home.jpg" width="180"/>
  <img src="assets/screenshots/calendar.jpg" width="180"/>
  <img src="assets/screenshots/streaks.jpg" width="180"/>
  <img src="assets/screenshots/journeys.jpg" width="180"/>
  
</p>

---

## 🛠️ Tech Stack

| Technology            | Purpose                      |
| --------------------- | ---------------------------- |
| Flutter               | Cross-platform UI framework  |
| Dart                  | Programming language         |
| Hive                  | Local database               |
| Hive Flutter          | Flutter integration for Hive |
| Table Calendar        | Calendar visualization       |
| File Picker           | Backup import/export         |
| Share Plus            | Sharing exported files       |
| Path Provider         | File system access           |
| Package Info Plus     | App version information      |
| URL Launcher          | External links               |
| Flutter Native Splash | Splash screen generation     |

---

## 📂 Project Structure

```text
lib/
│
├── main.dart
│
└── app/
    │
    ├── app.dart
    ├── router.dart
    │
    ├── models/
    │   ├── habit.dart
    │   └── habit.g.dart
    │
    ├── pages/
    │   ├── home/
    │   ├── addhabit/
    │   ├── calendar/
    │   ├── streak/
    │   ├── analytics/
    │   ├── journeys/
    │   └── about/
    │
    ├── shared/
    │   └── navigation/
    │
    ├── widgets/
    │   └── habit_card.dart
    │
    └── utils/
        ├── backup_service.dart
        ├── edit_habit_dialog.dart
        └── iconcolors.dart
```

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* Android Emulator or Physical Device

### Installation

```bash
git clone https://github.com/nagateja710/habitfire.git
```

```bash
cd habitfire
```

```bash
flutter pub get
```

```bash
flutter run
```

---

## 📦 Dependencies

Core packages used:

```yaml
hive
hive_flutter
table_calendar
file_picker
path_provider
share_plus
package_info_plus
url_launcher
flutter_native_splash
```

---

## 🎯 Key Concepts

### Habit

An active task that can be tracked daily.

Examples:

* Drink Water
* Exercise
* Read Books
* Wake Up Early

### Streak

Consecutive scheduled days with successful completion.

### Peak

Highest number of logs recorded in a single day.

### Journey

A completed habit that has been retired and archived for future reference.

---

## 🔮 Future Improvements

* Achievement badges
* Habit reminders
* Cloud backup
* Data synchronization
* Advanced analytics
* Charts and graphs
* Habit templates
* Goal tracking
* Widgets support

---

## 👨‍💻 Developer

**Naga Teja**

GitHub:
https://github.com/nagateja710

Project Repository:
https://github.com/nagateja710/habitfire

---

## 📄 License

This project is licensed under the MIT License.

---

### 🔥 Keep the fire burning.
