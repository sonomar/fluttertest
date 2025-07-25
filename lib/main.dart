import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_localizations/flutter_localizations.dart';
import './models/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/home_screen.dart';
import './widgets/auth/onboarding.dart';
import 'screens/collection_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/subscreens/missions/missions.dart';
import './models/collectible_model.dart';
import './models/notification_provider.dart';
import './models/user_model.dart';
import './models/distribution_model.dart';
import 'models/mission_model.dart';
import 'models/community_model.dart';
import 'models/news_post_model.dart';
import 'models/locale_provider.dart';
import 'models/asset_provider.dart';
import './widgets/splash_screen.dart';
import 'auth/auth_service.dart';
import './models/app_auth_provider.dart';
import './helpers/localization_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './app_lifefycle_observer.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // When the app is in the background or terminated, Firebase needs to be
  // re-initialized to ensure it has access to necessary resources.
  // This is crucial for handling background messages.
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  print('Notification: ${message.notification?.title}');
  print('Data: ${message.data}');
  // You can perform heavy lifting here, e.g., show local notification
  // or update app state via shared preferences. Avoid direct UI updates.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
      ChangeNotifierProxyProvider<AppAuthProvider, UserModel>(
        create: (context) => UserModel(context.read<AppAuthProvider>()),
        update: (context, appAuthProvider, previousUserModel) {
          return previousUserModel ?? UserModel(appAuthProvider);
        },
      ),
      ChangeNotifierProxyProvider2<AppAuthProvider, UserModel,
          CollectibleModel>(
        create: (context) => CollectibleModel(
          context.read<AppAuthProvider>(),
          context.read<UserModel>(),
        ),
        update:
            (context, appAuthProvider, userModel, previousCollectibleModel) {
          return previousCollectibleModel ??
              CollectibleModel(appAuthProvider, userModel);
        },
      ),
      ChangeNotifierProxyProvider2<AppAuthProvider, UserModel,
          DistributionModel>(
        create: (context) => DistributionModel(
          context.read<AppAuthProvider>(),
          context.read<UserModel>(),
        ),
        update:
            (context, appAuthProvider, userModel, previousDistributionModel) {
          return previousDistributionModel ??
              DistributionModel(appAuthProvider, userModel);
        },
      ),
      ChangeNotifierProvider<AssetProvider>(
        create: (context) => AssetProvider(),
      ),
      ChangeNotifierProxyProvider2<AppAuthProvider, UserModel, MissionModel>(
        create: (context) => MissionModel(
          context.read<AppAuthProvider>(),
          context.read<UserModel>(),
        ),
        update: (context, appAuthProvider, userModel, previousMissionModel) {
          final model =
              previousMissionModel ?? MissionModel(appAuthProvider, userModel);
          model.update(appAuthProvider, userModel);
          return model;
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
        home: const SplashScreen(),
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
  final _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initAppLinks();
    final userModel = context.read<UserModel>();

    void showOnboardingIfNeeded() {
      userModel.removeListener(showOnboardingIfNeeded);

      final authProvider = context.read<AppAuthProvider>();

      if (authProvider.shouldShowOnboardingForNewUser ||
          userModel.needsOnboarding) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Onboarding();
          },
        );
      }
    }

    if (userModel.isUserLoaded) {
      // Use a post-frame callback to safely show a dialog after the build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showOnboardingIfNeeded();
      });
    } else {
      // Otherwise, add a listener that will call our function once the user data is loaded.
      userModel.addListener(showOnboardingIfNeeded);
    }
  }

  Widget _buildCurrentPage(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
            key: const PageStorageKey('home'), qrcode: widget.qrcode);
      case 1:
        return const CollectionScreen(key: PageStorageKey('collection'));
      case 2:
        return ScanScreen(
            key: const PageStorageKey('scan'), userData: widget.userData);
      case 3:
        return Missions(
            key: const PageStorageKey('mission'), userData: widget.userData);
      case 4:
        return const ProfileScreen(key: PageStorageKey('profile'));
      default:
        return HomeScreen(
            key: const PageStorageKey('home'), qrcode: widget.qrcode);
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _handleRedirect(Uri uri) {
    print('Received redirect: $uri');
    // Use a local variable for the provider to avoid async gaps with context
    final authProvider = context.read<AppAuthProvider>();
    authProvider.handleRedirect(uri).then((success) {
      if (success && mounted) {
        // If handling the redirect was successful, navigate to the splash screen
        // to re-evaluate the auth state and proceed to the home page.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      }
    });
  }

  Future<void> _initAppLinks() async {
    // Handle links that launched the app from a terminated state
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print("Initial link received: $initialUri");
        _handleRedirect(initialUri);
      }
    } catch (e) {
      print('Failed to get initial URI: $e');
    }

    // Listen for links that come in while the app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      if (mounted) {
        print("Link received while running: $uri");
        _handleRedirect(uri);
      }
    }, onError: (err) {
      print('Error listening for links: $err');
    });
  }

  @override
  Widget build(BuildContext context) {
    final collectibleModel =
        Provider.of<CollectibleModel>(context, listen: false);
    final missionModel = Provider.of<MissionModel>(context, listen: false);
    return Scaffold(
        backgroundColor: Colors.white,
        body: _buildCurrentPage(_currentIndex),
        bottomNavigationBar: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: (index) {
              if (_currentIndex != index) {
                setState(() {
                  _currentIndex = index;
                });
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
                  label: translate("home_header", context)),
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
                label: translate("collection_header", context),
              ),
              BottomNavigationBarItem(
                icon: SizedBox(
                  width: 50,
                  height: 50,
                  child: SvgPicture.asset(
                    'assets/images/scan.svg',
                    colorFilter: ColorFilter.mode(
                        _currentIndex == 2 ? Color(0xffd622ca) : Colors.black,
                        BlendMode.srcIn),
                  ),
                ),
                label: translate("scan_header", context),
              ),
              BottomNavigationBarItem(
                icon: SizedBox(
                  width: 30,
                  height: 30,
                  child: SvgPicture.asset(
                    'assets/images/trophy.svg',
                    colorFilter: ColorFilter.mode(
                        _currentIndex == 3 ? Color(0xffd622ca) : Colors.black,
                        BlendMode.srcIn),
                  ),
                ),
                label: translate("missions_header", context),
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
                label: translate("profile_header", context),
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
