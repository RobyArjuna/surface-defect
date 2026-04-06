// lib/app/routes/app_routes.dart
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const HISTORY = _Paths.HISTORY; // <-- Pastikan ini ada
  static const DASHBOARD = _Paths.DASHBOARD; // <-- Pastikan ini ada
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const HISTORY = '/history'; // <-- Pastikan ini ada
  static const DASHBOARD = '/dashboard'; // <-- Pastikan ini ada
}
