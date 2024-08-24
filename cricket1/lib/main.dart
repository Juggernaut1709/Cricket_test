import 'package:cricket1/pages/loggedin/l_homepage.dart';
import 'package:cricket1/pages/loggedin/match/game.dart';
import 'package:cricket1/pages/login_view.dart';
import 'package:cricket1/pages/register_view.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cricket Cricket',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(255, 173, 96, 0.2)),
        useMaterial3: true,
      ),
      home: const LoginView(),
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/home': (context) => const HomePage(),
        '/game': (context) {
          final String roomId =
              ModalRoute.of(context)!.settings.arguments as String;
          return GameScreen(roomId: roomId);
        },
      },
    );
  }
}
