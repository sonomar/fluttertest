import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './models/app_localizations.dart';
import 'screens/home_screen.dart';
import 'widgets/openCards/login_page.dart';
import 'screens/collection_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/community_screen.dart';
import 'screens/profile_screen.dart';
// import 'screens/game_screen.dart';
import 'screens/subscreens/missions/missions.dart';
import './models/collectible_model.dart';
import './models/notification_provider.dart';
import './models/user_model.dart';
import 'models/mission_model.dart';
import 'models/community_model.dart';
import 'models/news_post_model.dart';
import 'models/locale_provider.dart';
import './widgets/splash_screen.dart';
import 'auth/auth_service.dart';
import './models/app_auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kloppocar_app/models/app_auth_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './app_lifefycle_observer.dart';
import './screens/auth_loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<LocaleProvider>(
        create: (context) => LocaleProvider(),
      ),
      Provider<AuthService>(
        create: (context) => AuthService.uninitialized(),
        lazy: false, // Ensure it's created immediately
      ),
      ChangeNotifierProvider<AppAuthProvider>(
        create: (context) {
          final authService =
              context.read<AuthService>(); // Get the AuthService instance
          final appAuthProvider =
              AppAuthProvider(authService); // Create AppAuthProvider
          // Now, inject AppAuthProvider back into AuthService
          authService.setAppAuthProvider(appAuthProvider);
          return appAuthProvider;
        },
        lazy: false, // Ensure it's created immediately
      ),
      ChangeNotifierProxyProvider<AppAuthProvider, CollectibleModel>(
        create: (context) => CollectibleModel(context.read<AppAuthProvider>()),
        update: (context, appAuthProvider, previousCollectibleModel) {
          return previousCollectibleModel ?? CollectibleModel(appAuthProvider);
        },
      ),
      ChangeNotifierProxyProvider<AppAuthProvider, UserModel>(
        create: (context) => UserModel(context.read<AppAuthProvider>()),
        update: (context, appAuthProvider, previousUserModel) {
          return previousUserModel ?? UserModel(appAuthProvider);
        },
      ),
      ChangeNotifierProxyProvider<AppAuthProvider, MissionModel>(
        create: (context) => MissionModel(context.read<AppAuthProvider>()),
        update: (context, appAuthProvider, previousMissionModel) {
          return previousMissionModel ?? MissionModel(appAuthProvider);
        },
      ),
      ChangeNotifierProxyProvider<AppAuthProvider, NewsPostModel>(
        create: (context) => NewsPostModel(context.read<AppAuthProvider>()),
        update: (context, appAuthProvider, previousNewsPostModel) {
          return previousNewsPostModel ?? NewsPostModel(appAuthProvider);
        },
      ),
      ChangeNotifierProxyProvider<AppAuthProvider, CommunityModel>(
        create: (context) => CommunityModel(context.read<AppAuthProvider>()),
        update: (context, appAuthProvider, previousCommunityModel) {
          return previousCommunityModel ?? CommunityModel(appAuthProvider);
        },
      ),
      ChangeNotifierProxyProvider2<AppAuthProvider, UserModel,
          NotificationProvider>(
        create: (context) => NotificationProvider(
          context.read<AppAuthProvider>(),
          context.read<UserModel>(),
        ),
        update: (context, appAuthProvider, userModel,
            previousNotificationProvider) {
          // Re-create or update. Simpler to re-create if dependencies change significantly.
          // Or, if NotificationProvider has an update method: previousNotificationProvider..updateDependencies(appAuthProvider, userModel);
          return previousNotificationProvider ??
              NotificationProvider(appAuthProvider, userModel);
        },
        lazy: false, // Load it eagerly
      ),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  // Keep as StatelessWidget as the Observer handles lifecycle
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    // Wrap your MaterialApp with AppLifecycleObserver
    return AppLifecycleObserver(
      onAppResumed: () {
        print(
            'AppLifecycleObserver: App resumed callback triggered in main.dart. Checking user session...');
        // Access AppAuthProvider and call checkCurrentUser here
        // Check if context is mounted before using it (good practice, though usually true here)
        if (context.mounted) {
          Provider.of<AppAuthProvider>(context, listen: false)
              .checkCurrentUser();
        }
      },
      onAppPaused: () {
        print(
            'AppLifecycleObserver: App paused callback triggered in main.dart.');
        // Optional: Perform actions when app is paused
      },
      child: MaterialApp(
        title: 'Kloppocar App',
        theme: ThemeData(
            fontFamily: 'ChakraPetch',
            useMaterial3: true,
            bottomSheetTheme:
                BottomSheetThemeData(backgroundColor: Colors.white),
            appBarTheme: AppBarTheme(backgroundColor: Colors.white),
            scaffoldBackgroundColor: Colors.white),
        debugShowCheckedModeBanner: false,
        locale: localeProvider.locale, // Use the locale from the provider
        supportedLocales: [
          Locale('en', ''),
          Locale('de', ''),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // This callback is still useful as a fallback for the initial load.
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        home: Consumer<AppAuthProvider>(
          builder: (context, authProvider, _) {
            print(
                'RootApp Consumer (Auth): Status = ${authProvider.status}'); // Debug print

            switch (authProvider.status) {
              case AuthStatus.uninitialized:
              case AuthStatus.authenticating:
                return const SplashScreen();

              case AuthStatus.authenticated:
                print(
                    'RootApp: Returning AuthLoadingScreen() at ${DateTime.now()}.');
                return const AuthLoadingScreen();

              case AuthStatus.unauthenticated:
                print(
                    'RootApp: Navigating to LoginPage (unauthenticated).'); // Debug print
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    Provider.of<UserModel>(context, listen: false).clearUser();
                  }
                });
                return const LoginPage(
                    userData: {}); // <--- This is the correct way
            }
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key,
      required this.title,
      required this.qrcode,
      required this.userData});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String qrcode;
  final dynamic userData;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

late List<Widget> _screens;

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final PageStorageBucket bucket = PageStorageBucket();

  // var _username = 'Guest';

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(key: const PageStorageKey('home'), qrcode: widget.qrcode),
      const CollectionScreen(key: PageStorageKey('collection')),
      ScanScreen(key: const PageStorageKey('scan'), userData: widget.userData),
      Missions(key: PageStorageKey('mission'), userData: widget.userData),
      const ProfileScreen(key: PageStorageKey('profile')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final collectibleModel =
        Provider.of<CollectibleModel>(context, listen: false);
    // final missionModel = Provider.of<MissionModel>(context, listen: false); // If HomeScreen's missions need explicit refresh too
    // final userModel = Provider.of<UserModel>(context, listen: false); // If user data affecting screens needs refresh
    return Scaffold(
        backgroundColor: Colors.white,
        body: PageStorage(
          bucket: bucket,
          child: _screens[_currentIndex],
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: (index) {
              bool dataMayHaveChanged =
                  false; // Flag to see if a relevant screen is being targeted

              if (index == 0) {
                // HomeScreen
                print(
                    "BottomNav: Tapped HomeScreen (index 0). Forcing CollectibleModel reload for recentColl.");
                collectibleModel.loadCollectibles(forceClear: true);
                // HomeScreen also loads missions/user in its own initState, which should be fine.
                // If other models shown on HomeScreen need a direct refresh:
                // Provider.of<MissionModel>(context, listen: false).loadMissions();
                // Provider.of<UserModel>(context, listen: false).loadUser();
                dataMayHaveChanged = true;
              } else if (index == 1) {
                // CollectionScreen
                print(
                    "BottomNav: Tapped CollectionScreen (index 1). Forcing CollectibleModel reload.");
                collectibleModel.loadCollectibles(forceClear: true);
                dataMayHaveChanged = true;
              }
              // Add similar logic for other screens if they depend on shared, mutable models
              // and are not reliably refreshed by their own initState after global state changes.

              // Only update the index if it actually changes,
              // or always update if you want the tap on current tab to re-render (though reload is separate)
              if (_currentIndex != index || dataMayHaveChanged) {
                setState(() {
                  _currentIndex = index;
                });
              } else if (_currentIndex == index) {
                // If tapping the current tab again, and it's one we want to refresh:
                if (index == 0 || index == 1) {
                  print(
                      "BottomNav: Re-tapped current relevant screen. Data reload already triggered.");
                }
              }
            },
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: SizedBox(
                    width: 30,
                    height: 30,
                    child: SvgPicture.asset(
                      'assets/images/home.svg',
                      colorFilter: ColorFilter.mode(
                          _currentIndex == 0 ? Color(0xffd622ca) : Colors.black,
                          BlendMode.srcIn),
                    ),
                  ),
                  label: 'Home'),
              BottomNavigationBarItem(
                icon: SizedBox(
                  width: 30,
                  height: 30,
                  child: SvgPicture.asset(
                    'assets/images/galerie.svg',
                    colorFilter: ColorFilter.mode(
                        _currentIndex == 1 ? Color(0xffd622ca) : Colors.black,
                        BlendMode.srcIn),
                  ),
                ),
                label: 'Galerie',
              ),
              BottomNavigationBarItem(
                icon: SizedBox(
                  width: 40,
                  height: 40,
                  child: SvgPicture.asset(
                    'assets/images/scan.svg',
                    colorFilter: ColorFilter.mode(
                        _currentIndex == 2 ? Color(0xffd622ca) : Colors.black,
                        BlendMode.srcIn),
                  ),
                ),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: SizedBox(
                  width: 30,
                  height: 30,
                  child: SvgPicture.asset(
                    'assets/images/game.svg',
                    colorFilter: ColorFilter.mode(
                        _currentIndex == 3 ? Color(0xffd622ca) : Colors.black,
                        BlendMode.srcIn),
                  ),
                ),
                label: 'Missions',
              ),
              BottomNavigationBarItem(
                icon: SizedBox(
                  width: 30,
                  height: 30,
                  child: SvgPicture.asset(
                    'assets/images/profil.svg',
                    colorFilter: ColorFilter.mode(
                        _currentIndex == 4 ? Color(0xffd622ca) : Colors.black,
                        BlendMode.srcIn),
                  ),
                ),
                label: 'Profile',
              ),
            ],
            unselectedIconTheme: const IconThemeData(color: Colors.black),
            selectedItemColor: const Color(0xffd622ca),
            unselectedItemColor: Colors.black,
            showSelectedLabels: true,
            showUnselectedLabels: true,
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}
