import 'package:flutter/material.dart';

class AdminConnect {

  static void goToDashboard(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/admin/dashboard');
  }

  static void goToExhibitions(BuildContext context) {
    Navigator.pushNamed(context, '/admin/exhibitions');
  }

  static void goToFloorPlans(BuildContext context) {
    Navigator.pushNamed(context, '/admin/floorplans');
  }

  static void goToUsers(BuildContext context) {
    Navigator.pushNamed(context, '/admin/users');
  }

  static void goToApplications(BuildContext context) {
    Navigator.pushNamed(context, '/admin/applications');
  }

  static void logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }
}