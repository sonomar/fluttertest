import 'dart:async';

import 'package:flutter/material.dart';
import './home_screen.dart';
import './collection_screen.dart';
import './scan_screen.dart';
import './community_screen.dart';
import './game_screen.dart';
import './openCards/login_page.dart';
import 'package:lottie/lottie.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Kloppocar App',
        theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a purple toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            fontFamily: 'ChakraPetch',
            useMaterial3: true,
            bottomSheetTheme:
                BottomSheetThemeData(backgroundColor: Colors.white),
            appBarTheme: AppBarTheme(backgroundColor: Colors.white),
            scaffoldBackgroundColor: Colors.white),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen());
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final navigator = Navigator.of(context);
    SharedPreferences.getInstance().then((prefValue) =>
        Future.delayed(const Duration(seconds: 3)).then((value) => {
              if ((prefValue.containsKey('jwtCode')))
                {
                  navigator.pushReplacement(MaterialPageRoute(
                      builder: (context) => const MyHomePage(
                          title: 'Kloppocar App Home',
                          qrcode: 'Scan a Collectible!'))),
                }
              else
                {
                  navigator.pushReplacement(MaterialPageRoute(
                      builder: (context) => const LoginPage())),
                }
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo here
            Image.asset(
              'assets/images/deins_logo.png',
              height: 200,
              width: 200,
            ),
            SizedBox(
              height: 40,
            ),
            SizedBox(
                height: 40,
                width: 40,
                child: Lottie.asset('assets/lottie/pinkspin1.json')),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.qrcode});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String qrcode;

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
      const ScanScreen(key: PageStorageKey('scan')),
      const CommunityScreen(key: PageStorageKey('community')),
      const GameScreen(key: PageStorageKey('game')),
    ];
  }

  // Future<void> _setUsername() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _username = prefs.setString('username', _username) as String;
  //   });
  // }

  // Future<void> _getUsername() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _username = prefs.getString('username') as String;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
