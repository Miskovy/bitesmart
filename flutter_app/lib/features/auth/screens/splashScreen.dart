import 'package:bite_smart/features/auth/data/bloc/auth_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_state.dart';
import 'package:bite_smart/features/auth/screens/language.dart';
import 'package:bite_smart/features/home/screens/navBar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  bool _timerDone = false;
  bool _navigationTriggered = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _timerDone = true;
        });
        _checkAndNavigate();
      }
    });
  }

  void _checkAndNavigate() {
    if (!_timerDone || _navigationTriggered || !mounted) return;
    
    final state = context.read<AuthBloc>().state;
    // If the auth check is still in progress (Initial or Loading), wait for listener to trigger.
    if (state is AuthInitial || state is AuthLoading) {
      return;
    }

    _navigationTriggered = true;
    
    if (state is AuthAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainHome()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LanguageSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _checkAndNavigate();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
                ),
              ),
              Text(
                'splash.tagline'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              SizedBox(height: .2 * MediaQuery.of(context).size.height),
              Image.asset(
                'assets/load.jpg',
                width: .08 * MediaQuery.of(context).size.width,
                height: .08 * MediaQuery.of(context).size.height,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF50),
                      strokeWidth: 2,
                    ),
                  );
                },
              ),
              Text(
                'splash.loading'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}