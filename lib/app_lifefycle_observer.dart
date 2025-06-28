import 'package:flutter/material.dart';

typedef AppLifecycleCallback = void Function();

class AppLifecycleObserver extends StatefulWidget {
  final Widget child;
  final AppLifecycleCallback? onAppResumed; // Define the named parameter
  final AppLifecycleCallback?
      onAppPaused; // Optional: add other lifecycle callbacks

  const AppLifecycleObserver({
    super.key,
    required this.child,
    this.onAppResumed,
    this.onAppPaused, // Add this if you want to handle paused state
  });

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
      // You can add more specific callbacks here if needed, e.g., onResume, onInactive, etc.
      // For simplicity, we'll route all state changes through onStateChange.
    );
  }

  void _onStateChanged(AppLifecycleState state) {
    print('AppLifecycleObserver: AppLifecycleState changed to $state');
    if (state == AppLifecycleState.resumed) {
      // Call the `onAppResumed` callback provided by the parent widget
      widget.onAppResumed?.call();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Call the `onAppPaused` callback if provided
      widget.onAppPaused?.call();
    }
    // You can add logic for other states (inactive, detached) as needed
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
