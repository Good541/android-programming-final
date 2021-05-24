import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:requests/requests.dart';
import 'main.dart';
import 'retry.dart';
import 'requesturl.dart';
import 'login.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _loading = false;
  var requestURrl = RequestURL();
  @override
  void initState() {
    super.initState();
    verifyLoginSession();
  }
  verifyLoginSession() async{
    _loading= true;
    String rs1;
    try {
      var r = await Requests.get(requestURrl.getApiURL+'/loginstatus');
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
                  _loading
                  ? Container(
                      child: Center(
                      child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue)),
                    ))
                  : Container(),
                ],
                
            )
        ),
      );
  }
}