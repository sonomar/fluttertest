import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'widgets/openCards/login_page.dart';
import 'screens/collection_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/community_screen.dart';
import 'screens/game_screen.dart';
import './models/collectible_model.dart';
import './models/user_model.dart';
import 'models/mission_model.dart';
import './widgets/splash_screen.dart';
import 'auth/auth_service.dart';
import './models/app_auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './app_lifefycle_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(providers: [
      Provider<AuthService>(
        create: (context) => AuthService(),
      ),
      ChangeNotifierProvider(
        create: (context) => AppAuthProvider(context.read<AuthService>()),
      ),
      ChangeNotifierProvider(create: (context) => CollectibleModel()),
      ChangeNotifierProvider(create: (context) => UserModel()),
      ChangeNotifierProvider(create: (context) => MissionModel()),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
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
        home: Consumer<AppAuthProvider>(
          builder: (context, authProvider, _) {
            print(
                'RootApp Consumer (Auth): Status = ${authProvider.status}'); // Debug print

            switch (authProvider.status) {
              case AuthStatus.uninitialized:
              case AuthStatus.authenticating:
                return const SplashScreen();

              case AuthStatus.authenticated:
                return Consumer<UserModel>(
                  // Listen to UserModel changes
                  builder: (context, userModel, __) {
                    print(
                        'RootApp Consumer (User): isLoading=${userModel.isLoading}, currentUser=${userModel.currentUser != null ? 'loaded' : 'null'}, errorMessage=${userModel.errorMessage}'); // Debug print

                    // If user data is not yet loaded and not currently loading, trigger loadUser
                    if (userModel.currentUser == null &&
                        !userModel.isLoading &&
                        userModel.errorMessage == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        print('RootApp: Triggering UserModel.loadUser()');
                        userModel.loadUser();
                      });
                      return const SplashScreen(); // Show splash while loading user data
                    }

                    // If user data is loading, show splash
                    if (userModel.isLoading) {
                      return const SplashScreen();
                    }

                    // If user data is loaded, show MyHomePage
                    if (userModel.currentUser != null) {
                      print(
                          'RootApp: Navigating to MyHomePage with user data.');
                      final userId =
                          userModel.currentUser['userId']?.toString();
                      if (userId != null) {
                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setString('userId', userId);
                        });
                      }
                      return MyHomePage(
                        title: 'Kloppocar App Home',
                        qrcode: 'Scan a Collectible!',
                        userData: userModel.currentUser,
                      );
                    }

                    // If there was an error loading user data, sign out and go to login
                    if (userModel.errorMessage != null) {
                      print(
                          'RootApp: UserModel Error: ${userModel.errorMessage}. Signing out.');
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        authProvider
                            .signOut(); // This will change auth status to unauthenticated
                        userModel.clearUser(); // Clear user model state too
                      });
                      return const LoginPage(
                          userData: {}); // Go to login immediately
                    }

                    // Fallback, should theoretically not be reached if states are handled
                    return const SplashScreen();
                  },
                );

              case AuthStatus.unauthenticated:
                print(
                    'RootApp: Navigating to LoginPage (unauthenticated).'); // Debug print
                return const LoginPage(userData: {});
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
      const CommunityScreen(key: PageStorageKey('community')),
      GameScreen(key: PageStorageKey('game'), userData: widget.userData),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
              setState(() {
                _currentIndex = index;
              });
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
                    'assets/images/community.svg',
                    colorFilter: ColorFilter.mode(
                        _currentIndex == 3 ? Color(0xffd622ca) : Colors.black,
                        BlendMode.srcIn),
                  ),
                ),
                label: 'Community',
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
                label: 'Game Center',
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
