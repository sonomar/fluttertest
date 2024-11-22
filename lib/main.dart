import 'package:flutter/material.dart';
import './home_screen.dart';
import './collection_screen.dart';
import './scan_screen.dart';
import './community_screen.dart';
import './profile_screen.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';

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
      ),
      home: const MyHomePage(
          title: 'Kloppocar App Home', qrcode: 'Scan a Collectible!'),
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
    // _setUsername();

    _screens = [
      HomeScreen(key: const PageStorageKey('home'), qrcode: widget.qrcode),
      const CollectionScreen(key: PageStorageKey('collection')),
      const ScanScreen(key: PageStorageKey('scan')),
      const CommunityScreen(key: PageStorageKey('community')),
      const ProfileScreen(key: PageStorageKey('profile')),
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
      body: PageStorage(
        bucket: bucket,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.house_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Collection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined, size: 40),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
        unselectedIconTheme: const IconThemeData(color: Colors.black),
        selectedItemColor: const Color(0xffd622ca),
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
