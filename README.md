# CycleTracker iOS App

CycleTracker is an iOS application designed to help bodybuilders and athletes track their medication and injection administration with precision and ease. The app provides comprehensive tracking capabilities along with advanced data visualization for monitoring serum levels based on compound half-lives.

## Features

### Core Functionality
- **Medication Logging**: Easy-to-use interface for logging daily administrations
- **Calendar Integration**: Visual timeline of all administrations
- **Serum Level Tracking**: Real-time calculations of estimated serum levels
- **Data Visualization**: Interactive charts and graphs
- **Compound Database**: Comprehensive database of common compounds with half-lives

### Advanced Features
- **Smart Reminders**: Customizable notifications for scheduled administrations
- **Site Rotation**: Track and optimize injection site rotation
- **Export Capabilities**: Secure data export for backup or analysis
- **Privacy Focused**: Local data storage with optional biometric security

## Technical Architecture

### Data Layer
- CoreData for persistent storage
- MVVM architecture
- SwiftUI framework
- Charts integration for visualization

### Security
- Local data storage only
- Optional FaceID/TouchID integration
- Data encryption at rest

## Development Setup

### Requirements
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Installation
1. Clone the repository
2. Open `CycleTracker.xcodeproj` in Xcode
3. Build and run the project

## Project Structure

```
CycleTracker/
├── App/
│   ├── CycleTrackerApp.swift
│   └── AppDelegate.swift
├── Models/
│   ├── Compound.swift
│   ├── Administration.swift
│   └── CycleLog.swift
├── ViewModels/
│   ├── CycleLogViewModel.swift
│   └── DashboardViewModel.swift
├── Views/
│   ├── Dashboard/
│   ├── LogEntry/
│   ├── Calendar/
│   └── Settings/
├── Utilities/
│   ├── SerumCalculator.swift
│   └── Notifications.swift
└── Resources/
    ├── Assets.xcassets
    └── CompoundDatabase.json
```

## Contributing

This project is currently in development. Contribution guidelines will be added soon.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Privacy Policy

CycleTracker is designed with privacy in mind. All data is stored locally on your device and is never transmitted to external servers.
