# Pocketly 💰

A modern, intuitive expense tracking Flutter application that helps you manage your finances with beautiful visualizations and comprehensive analytics.

## 📱 Features

### 🏠 Dashboard
- **Financial Overview**: Get a quick snapshot of your spending with key metrics
- **Interactive Charts**: 
  - Animated donut chart showing spending by category
  - Weekly spending bar chart with smooth animations
  - Category-wise spending breakdown with percentages
- **Smart Analytics**: Track total spent, transaction count, and spending trends
- **Visual Insights**: Beautiful, responsive charts that make data easy to understand

### 💸 Expense Management
- **Add Expenses**: Quick and easy expense entry with validation
- **Category System**: Pre-defined categories (Food, Transportation, Entertainment, Shopping, Bills, Healthcare, Others)
- **Expense Details**: Add descriptions, amounts, dates, and categories
- **Edit & Delete**: Full CRUD operations for expense management
- **Smart Filtering**: Filter expenses by date, category, and amount
- **Transaction History**: View all expenses in a clean, organized list

### 📊 Analytics & Insights
- **Monthly Spending**: Track current month expenses and trends
- **Category Breakdown**: See where your money goes with detailed category analysis
- **Weekly Patterns**: Understand your spending habits with weekly charts
- **Transaction Count**: Monitor your spending frequency
- **Visual Reports**: Interactive charts and graphs for better insights

## 🛠️ Technical Stack

### Core Technologies
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language (SDK ^3.9.0)
- **Riverpod**: State management and dependency injection
- **Go Router**: Navigation and routing
- **Hive**: Local database for data persistence

### Key Dependencies
- `flutter_riverpod: ^2.6.1` - State management
- `get_it: ^8.2.0` - Dependency injection
- `go_router: ^16.2.4` - Navigation
- `hive: ^2.2.3` - Local database
- `lucide_icons_flutter: ^3.1.1` - Beautiful icons
- `intl: ^0.20.2` - Internationalization
- `path_provider: ^2.1.4` - File system access

### Development Tools
- `flutter_lints: ^5.0.0` - Code quality
- `hive_generator: ^2.0.1` - Code generation
- `build_runner: ^2.4.9` - Build automation

## 🏗️ Architecture

### Clean Architecture Pattern
The app follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── app/                    # App configuration and entry point
├── core/                   # Core utilities and shared functionality
│   ├── navigation/         # Routing and navigation
│   ├── theme/             # App theming and styling
│   ├── utils/             # Utility functions
│   └── locator/           # Dependency injection
├── features/              # Feature modules
│   ├── dashboard/         # Dashboard feature
│   ├── expenses/          # Expense management
│   └── shared/            # Shared components
└── main.dart              # App entry point
```

### Feature Structure
Each feature follows a consistent structure:
- **Data Layer**: Hive database, repositories, models
- **Domain Layer**: Business logic, entities, use cases
- **Presentation Layer**: UI components, providers, views

### State Management
- **Riverpod**: Reactive state management
- **Providers**: Feature-specific state providers
- **Notifiers**: Business logic and state updates
- **Consumers**: UI state consumption

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator (for testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pocketly
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (if needed)**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Platform Support
- ✅ iOS
- ✅ Android
- ✅ Web

## 📱 App Screenshots

### Dashboard
- Financial overview with key metrics
- Interactive spending charts
- Category breakdown with percentages
- Weekly spending patterns

### Expense Management
- Add new expenses with validation
- Edit existing expenses
- Delete expenses with confirmation
- Filter and search expenses
- Category-based organization

### Analytics
- Monthly spending trends
- Category-wise spending analysis
- Transaction history
- Visual data representation

## 🎨 Design System

### Typography
- **Manrope**: Primary font family
- **Outfit**: Secondary font family
- **Plus Jakarta Sans**: Accent font
- **Raleway**: Display font

### Color Palette
- Modern, clean color scheme
- Category-specific colors for easy identification
- Consistent theming across the app

### Icons
- **Lucide Icons**: Beautiful, consistent iconography
- Category-specific icons for easy recognition
- Scalable vector icons

## 🔧 Development

### Code Generation
```bash
# Generate Hive adapters
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

### Linting
```bash
# Run linter
flutter analyze

# Fix linting issues
dart fix --apply
```

### Testing
```bash
# Run tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📦 Data Storage

### Hive Database
- **Local Storage**: All data stored locally on device
- **Offline First**: Works without internet connection
- **Fast Performance**: Optimized for mobile devices
- **Data Models**: Structured expense and category data

### Data Models
- **Expense**: Core expense entity with validation
- **Category**: Predefined spending categories
- **Filter**: Expense filtering and search
- **State**: Reactive state management

## 🚀 Future Enhancements

### Planned Features
- [ ] Budget tracking and alerts
- [ ] Export data (CSV, PDF)
- [ ] Data backup and sync
- [ ] Advanced analytics
- [ ] Receipt scanning
- [ ] Multi-currency support
- [ ] Dark mode
- [ ] Widget support
- [ ] Notifications and reminders

### Technical Improvements
- [ ] Unit tests coverage
- [ ] Integration tests
- [ ] Performance optimization
- [ ] Accessibility improvements
- [ ] Internationalization
- [ ] CI/CD pipeline

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused and small

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- Hive for efficient local storage
- Lucide for beautiful icons
- The open-source community for inspiration

---

**Pocketly** - Track your expenses, understand your spending, and take control of your finances! 💰✨