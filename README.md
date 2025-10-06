# Excel Planner

A Flutter-based spreadsheet application inspired by Google Sheets and Microsoft Excel.  
This project was built as part of an interview task to demonstrate clean architecture, UI/UX design, and local data persistence.

---

## Overview

Excel Planner allows users to create and manage multiple sheets, each containing an editable grid of cells.  
The app supports adding and deleting rows and columns, saving data locally, and exporting content as CSV files.  
It provides a fast, lightweight, and intuitive spreadsheet experience built entirely with Flutter.

---

## Features

- Splash screen with custom app theme  
- Multi-sheet management: create, rename, delete, and view sheets  
- Editable grid with dynamic row and column operations  
- Auto-save with debounce (saves automatically after edits)  
- Persistent local storage using Hive  
- Export sheets to CSV format  
- Clean, responsive UI with both horizontal and vertical scrolling  
- Consistent color scheme and simple layout

---

## Architecture

This app follows the Clean Architecture pattern, separating the codebase into clear layers for scalability and testability.

lib/
├── core/ # App constants and shared utilities
├── data/ # Local data source (Hive implementation)
├── domain/ # Entities and UseCases
├── presentation/ # UI, Providers, and Widgets
│ ├── pages/
│ ├── providers/
│ └── widgets/
└── main.dart # Application entry point



- **State Management:** Provider  
- **Local Storage:** Hive  
- **Architecture Pattern:** Clean Architecture  
- **Language:** Dart (Flutter SDK 3.7+)  

---

## Tech Stack

| Category | Package / Tool |
|-----------|----------------|
| Framework | Flutter |
| State Management | Provider |
| Local Storage | Hive, hive_flutter |
| Utilities | path_provider, uuid, intl, csv |
| Build Tools | flutter_launcher_icons |
| Version Control | Git / GitHub |

---

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ShamsiFarooq/excel_planner.git
   cd excel_planner
