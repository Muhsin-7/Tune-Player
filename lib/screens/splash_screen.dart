import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../widgets/colors.dart';
import 'main_screen.dart';


class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  void _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    // If it's the first launch, show splash screen, else skip
    if (isFirstLaunch) {
      prefs.setBool('isFirstLaunch', false);

      await Future.delayed(Duration(seconds: 3));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => MainScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => MainScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Icon(Icons.graphic_eq_rounded,color: Colors.white,size: 40,)
      ),
    );
  }
}

