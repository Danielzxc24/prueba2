import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/screen/pacientes.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/screen/login.dart';
import 'package:flutter_application_1/screen/HomePage.dart';
import 'package:flutter_application_1/screen/doctores.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/doctor',
        builder: (context, state) => DoctorCrudPage(),
      ),
      GoRoute(
        path: '/HomePage',
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: '/paciente',
        builder: (context, state) => PacienteCrudPage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: "App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
