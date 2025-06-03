import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kloppocar_app/models/app_auth_provider.dart'; // Adjust this import path if necessary

class AppLifecycleObserver extends StatefulWidget {
  final Widget child;

  const AppLifecycleObserver({super.key, required this.child});

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver> {
  // Declare the AppLifecycleListener
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    // Initialize the listener in initState
    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );
  }

  // This method is called when the app's lifecycle state changes
  void _onStateChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The app has resumed from the background or inactive state.
      // This is the ideal time to re-check the user's session validity.
      print(
          'AppLifecycleObserver: App has resumed. Re-checking user session...');
      // Access your AppAuthProvider and call checkCurrentUser
      if (!mounted) return;
      Provider.of<AppAuthProvider>(context, listen: false).checkCurrentUser();
    }
    // You can add conditions for other states if needed,
    // e.g., AppLifecycleState.paused for saving data before backgrounding.
  }

  @override
  void dispose() {
    // It's crucial to dispose of the listener when the widget is removed
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The child widget (your MaterialApp in this case) will be rendered
    return widget.child;
  }
}
