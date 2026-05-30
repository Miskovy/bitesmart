import 'package:bite_smart/core/services/secure_storage_service.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_event.dart';
import 'package:bite_smart/features/auth/data/repositories/auth_repository.dart';
import 'package:bite_smart/features/auth/screens/splashScreen.dart';
import 'package:bite_smart/features/profile/data/repositories/profile_repository.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_bloc.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await SecureStorageService.instance.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'EG')],
      path: 'lang',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<IProfileRepository>(
          create: (context) => ProfileRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<IAuthRepository>(),
            )..add(const CheckAuthStatusEvent()),
          ),
          BlocProvider<ProfileSetupBloc>(
            create: (context) => ProfileSetupBloc(
              profileRepository: context.read<IProfileRepository>(),
            ),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              profileRepository: context.read<IProfileRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          home: const Splashscreen(),
        ),
      ),
    );
  }
}

