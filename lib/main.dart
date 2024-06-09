import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/homeView.dart';
import 'views/loginView.dart';
import 'views/registerView.dart';
import 'firebase_options.dart'; // Asegúrate de tener este archivo configurado

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => RegisterView(),
        '/login': (context) => LoginView(),
        '/home': (context) => HomeView(),
        '/register': (context) => RegisterView(),
      },
    );
  }
}
