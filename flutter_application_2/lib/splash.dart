import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/retry.dart';
import 'package:page_transition/page_transition.dart';
import 'package:requests/requests.dart';
import 'main.dart';
import 'retry.dart';
                                              
class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    verifyLoginSession();
  }
  verifyLoginSession() async{
    _loading= true;
    String rs1;
    try {
      var r = await Requests.get('http://shirakami.trueddns.com:60181/loginstatus');
      //var r = await Requests.get('http://192.168.1.57:8000/loginstatus');
      r.raiseForStatus();
      rs1 = r.content();
      print(rs1);
      if(rs1 == 'Unauthorized'){
        _loading = false;
        Navigator.pushReplacement(
          context,
         PageTransition(type: PageTransitionType.fade, child: MaterialApp(
          title: 'Login',
          home: Login(),
          ),),
        );
      }
      else{
        _loading = false;
        Navigator.pushReplacement(
          context, PageTransition(type: PageTransitionType.fade, child:
          MyApp(),
          ),
        );
      }
    }
    catch(e){
      _loading = false;
      print(e);
      Navigator.pushReplacement(
        context,
       PageTransition(type: PageTransitionType.fade, child: RetryPage()),
      );
    }
    _loading = false;
  }
  
  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                  //backgroundImage: avatarImg == null? avatarImg: MemoryImage(avatarImg),
                  radius: 50.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  _loading
                  ? Container(
                      child: Center(
                      child: CircularProgressIndicator(),
                    ))
                  : Container(),
                ],
                
            )
        ),
      );
  }
}