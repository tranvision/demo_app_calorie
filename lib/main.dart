import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/app_database.dart';
import 'database/entity/settings.dart';
import 'pages/home_page.dart';
import 'pages/history_page.dart';
import 'pages/discover_page.dart';
import 'pages/settings_page.dart';

AppDatabase? _database;
AppDatabase get database {
  if (_database == null) {
    throw StateError('Database not initialized. Call initializeApp() first.');
  }
  return _database!;
}
bool _isInitialized = false;

Future<void> initializeApp({bool clearData = false}) async {
  if (_isInitialized && !clearData) return;

  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Initialize database
  _database = await $FloorAppDatabase.databaseBuilder('calorie_tracker.db').build();

  // Clear data if requested (for testing)
  if (clearData) {
    await _database!.foodRecordDao.deleteAll();
  }

  // Initialize default settings if not exists
  final settingsDao = _database!.settingsDao;
  final existingSettings = await settingsDao.getSettings();
  if (existingSettings == null) {
    await settingsDao.insertOrUpdate(Settings(id: 1, dailyTarget: 1800));
  }

  _isInitialized = true;
}

void main() {
  // Reset initialization flag for tests
  _isInitialized = false;

  // Call runApp immediately so tests can find widgets
  runApp(const MyApp(initialThemeMode: ThemeMode.system));

  // Initialize app asynchronously with data clearing for tests
  initializeApp(clearData: true).then((_) async {
    // Load theme mode and update if needed
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('theme_mode') ?? 'system';
    ThemeMode themeMode;
    switch (themeModeString) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    // Update theme mode if different from default
    if (themeMode != ThemeMode.system) {
      // This will be handled by MyApp's state management
    }
  });
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;

  const MyApp({super.key, required this.initialThemeMode});

  static MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<MyAppState>();
  }

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '自律茄子',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B4FCF)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B4FCF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: FutureBuilder(
        future: _isInitialized ? null : initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !_isInitialized) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return const MainScreen();
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final GlobalKey<HomePageState> _homePageKey = GlobalKey();
  final GlobalKey<HistoryPageState> _historyPageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(key: _homePageKey),
          HistoryPage(key: _historyPageKey),
          const DiscoverPage(),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF1E1E1E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 0) {
              _homePageKey.currentState?.refresh();
            } else if (index == 1) {
              _historyPageKey.currentState?.refresh();
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: '历史',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: '发现',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }
}
