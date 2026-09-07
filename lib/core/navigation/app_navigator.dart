import 'package:flutter/material.dart';

/// Stable reference to the app's single root Navigator (the one go_router
/// manages, passed to `GoRouter(navigatorKey: ...)`).
///
/// [DialogHelper.hideLoading] uses this instead of the calling page's own
/// `BuildContext` — a loading dialog opened from e.g. the login page must
/// still be dismissible even after a redirect (login -> /scan) has already
/// unmounted that page by the time the deferred pop runs. The page's
/// context would be unmounted by then and get silently skipped; this key
/// stays valid for the app's whole lifetime.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
