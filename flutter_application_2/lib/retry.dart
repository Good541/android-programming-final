import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/retry.dart';
import 'package:page_transition/page_transition.dart';
import 'package:requests/requests.dart';
import 'main.dart';
import 'splash.dart';
                                              
class RetryPage extends StatefulWidget {
  @override
  _RetryPageState createState() => _RetryPageState();
}

class _RetryPageState extends State<RetryPage> {
  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: (){
                      Navigator.pushReplacement(
                        context,
                        PageTransition(type: PageTransitionType.fade, 
                          child: SplashPage(),
                        ),
                      );
                    }, 
                    child: Column( // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Icon(Icons.refresh),
                        Text("Refresh")
                      ],
                    ),
                  ),
                  TextButton(
                    child: Text(
                      'Skip login',
                      style: TextStyle(color: Colors.black54),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                    },
                  ),
                ],
                
            )
        ),
      );
  }
}
