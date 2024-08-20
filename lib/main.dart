import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vial_dashboard/screens/home.dart';
import 'package:vial_dashboard/screens/auth/signin.dart';
import 'screens/config/firebase_options.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());

  doWhenWindowReady(() {
    final win = appWindow;
    win.minSize = const Size(640, 360);
    win.alignment = Alignment.center;
    win.title = "Vial Solutions";
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vial Solutions',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C3E50),
          elevation: 0,
        ),
      ),
      initialRoute: '/signin',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/signin':
            page = const LoginPage();
            break;
          case '/home':
            page = const HomePage();
            break;
          default:
            page = const LoginPage();
        }
        return MaterialPageRoute(builder: (_) => page);
      },
      home: const MainWindow(),
    );
  }
}

class MainWindow extends StatelessWidget {
  const MainWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WindowBorder(
        color: const Color(0xFF2C3E50),
        width: 1,
        child: Column(
          children: [
            WindowTitleBarBox(
              child: MoveWindow(
                child: Container(
                  color: const Color(0xFF2C3E50),
                  child: Row(
                    children: [
                      Expanded(child: MoveWindow()),
                      const WindowButtons(),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Navigator(
                onGenerateRoute: (settings) {
                  Widget page;
                  switch (settings.name) {
                    case '/signin':
                      page = const LoginPage();
                      break;
                    case '/home':
                      page = const HomePage();
                      break;
                    default:
                      page = const LoginPage();
                  }
                  return MaterialPageRoute(builder: (_) => page);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
  iconNormal: Colors.white,
  mouseOver: const Color(0xFF3E5871),
  mouseDown: const Color(0xFF2C3E50),
  iconMouseOver: Colors.white,
  iconMouseDown: Colors.white,
);

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

final closeButtonColors = WindowButtonColors(
  mouseOver: Colors.red[400],
  mouseDown: Colors.red[700],
  iconNormal: Colors.white,
  iconMouseOver: Colors.white,
);
