import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/bloc/theme_bloc.dart';
import 'package:photo_sharing_app/bloc/theme_state.dart';
import 'package:photo_sharing_app/services/auth/auth_gate.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/theme/light_mode.dart';
import 'package:photo_sharing_app/theme/dark_mode.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

final AuthServices authServices = locator.get();
List<CameraDescription> cameras = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: "unprocessedsns",
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await initSerivceLocator();

  runApp(BlocProvider(create: (context) => ThemeBloc(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is ThemeInitState) {
          return MaterialApp(
            navigatorObservers: [FlutterSmartDialog.observer],
            builder: FlutterSmartDialog.init(),
            locale: Locale('ja', 'JP'), // or 'en' for English
            supportedLocales: [
              // Locale('en', 'US'),
              Locale('ja', 'JP'),
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            theme: darkMode,
            home: AuthGate(),
          );
        }
        return MaterialApp(
          locale: Locale('ja', 'JP'), // or 'en' for English
          supportedLocales: [
            // Locale('en', 'US'),
            Locale('ja', 'JP'),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          theme: lightMode,
          home: AuthGate(),
        );
      },
    );
  }
}
