import 'package:flutter/material.dart';
import 'launcher.dart';
import 'splash.dart';
void main () async
{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SplashScrren());

}

class SplashScrren extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: Color(0xffe9ebee),
            primaryColor: Colors.blue,
            accentColor: Colors.pinkAccent),
        title: 'Your App Name',
        home: SplashPage());
  }
}

class MyApp extends StatelessWidget{
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
          theme: ThemeData(
              primaryColor: Colors.blue,
              accentColor: Colors.black,
              textTheme: TextTheme(body1: TextStyle(color: Colors.black), subtitle: TextStyle(color: Colors.black)),
              pageTransitionsTheme: PageTransitionsTheme(builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(),}),
          ),
          title: 'First Flutter App',
          initialRoute: '/', // สามารถใช้ home แทนได้
          routes: {
              Launcher.routeName: (context) => Launcher(),
          },
        );
    }
}



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Home Page'),),
      body: new Text('This is Body Home Page'),
    );
  }
}