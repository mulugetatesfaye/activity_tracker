import 'package:flutter/cupertino.dart';
import 'package:activity_tracker/src/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Kids Activities',
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.systemBlue,
        barBackgroundColor: CupertinoColors.systemBackground,
        scaffoldBackgroundColor: CupertinoColors.systemGrey6,
        textTheme: CupertinoTextThemeData(
          navTitleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
          textStyle: TextStyle(
            fontSize: 17,
            color: CupertinoColors.label,
          ),
          actionTextStyle: TextStyle(
            fontSize: 17,
            color: CupertinoColors.systemBlue,
          ),
        ),
      ),
      home: const HomeScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, // Disable font scaling
          ),
          child: child!,
        );
      },
    );
  }
}
