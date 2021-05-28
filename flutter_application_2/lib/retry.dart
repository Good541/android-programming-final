import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
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
        backgroundColor: Colors.grey[900],
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Connection Error', 
                      style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.left
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
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
                  // TextButton(
                  //   child: Text(
                  //     'Skip login',
                  //     style: TextStyle(color: Colors.black54),
                  //   ),
                  //   onPressed: () {
                  //     Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => MyApp()),
                  //   );
                  //   },
                  // ),
                ],
                
            )
        ),
      );
  }
}
