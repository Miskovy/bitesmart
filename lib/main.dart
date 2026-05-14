import 'package:bite_smart/ui/screens/OTPScreen.dart';
import 'package:bite_smart/ui/screens/forgetPass.dart';
import 'package:bite_smart/ui/screens/chooseGoalScreen.dart';
import 'package:bite_smart/ui/screens/language.dart';
import 'package:bite_smart/ui/screens/loginScreen.dart';
import 'package:bite_smart/ui/screens/permission.dart';
import 'package:bite_smart/ui/screens/signup.dart';
import 'package:bite_smart/ui/screens/splashScreen.dart';
import 'package:bite_smart/ui/screens/premium.dart';
import 'package:bite_smart/ui/screens/welcomeScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('ar', 'EG')],
      path: 'lang', // <-- change the path of the translation files
      fallbackLocale: Locale('en', 'US'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      home: const Splashscreen(),
    );
  }
}
