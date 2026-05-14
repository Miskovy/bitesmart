import 'package:bite_smart/ui/screens/welcomeScreen.dart';
import 'package:bite_smart/ui/screens/language.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override

  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LanguageSelectionScreen()),
      );
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.jpg',
              width: .50 * MediaQuery.of(context).size.width,
              height: .30 * MediaQuery.of(context).size.height,
            ),
            Text(
              'splash.brand'.tr(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )
        ),
            Text(
              'splash.tagline'.tr(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.black.withOpacity(0.5),
              )
        ),
        SizedBox( height: .2 * MediaQuery.of(context).size.height,),
         Image.network('https://i.postimg.cc/KYdnKxtk/load.jpg',
              width: .08 * MediaQuery.of(context).size.width,
              height: .08 * MediaQuery.of(context).size.height,
            ),
            Text(
              'splash.loading'.tr(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[700],
              )),
            ],
        ),
      ),
            backgroundColor: Colors.white,

    );
    
  }
}