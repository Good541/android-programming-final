import 'package:flutter/material.dart';
import 'launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:crypt/crypt.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:password_hash/password_hash.dart';
import 'package:requests/requests.dart';
import 'splash.dart';
void main () async
{
  WidgetsFlutterBinding.ensureInitialized();
  //final url = Uri.parse('http://shirakami.trueddns.com:60181/loginstatus');
  // final url = Uri.parse('http://localhost:8000/loginstatus');
  
  // var r1 = await Requests.post("http://shirakami.trueddns.com:60181/login", json: {
  //     'uname': "user0",
  //     'pwd': "12345",
  //     'rememberme': 'y'
  //   } ); 
  // r1.raiseForStatus();
  // String rs = r1.content();
  // print(rs);
  
  // String rs1;
  // try {
  //   var r = await Requests.get('http://shirakami.trueddns.com:60181/loginstatus');
  //   r.raiseForStatus();
  //   rs1 = r.content();
  //   print(rs1);
  //   if(rs1 == 'Unauthorized'){
  //     runApp(MaterialApp(
  //         title: 'Login',
  //         home: Login(),
  //         ),
  //     );
  //   }
  //   else{
  //     runApp(MyApp());
  //   }
  // }
  // catch(e){
  //   print(e);
  //   runApp(MaterialApp(
  //       title: 'Login',
  //       home: Login(),
  //       ),
  //   );
  // }

  // make POST request
  //var client = http.Client();
  //var response = await client.get(url);
  // check the status code for the result
  //String result = "";
  // if (this.mounted) {
  //   this.setState(() {
  //     result = response.body;
  //   });
  // }
  //result = response.body;
  //debugPrint(result);

 // client.close();
  runApp(SplashScrren());

}

// verifyLogin() async{
//   final url = Uri.parse('http://shirakami.trueddns.com:60181/loginstatus');
//   // make POST request
//   var client = http.Client();
//   var response = await client.get(url);
//   // check the status code for the result
//   String result = "";
//   // if (this.mounted) {
//   //   this.setState(() {
//   //     result = response.body;
//   //   });
//   // }
//   result = response.body;
//   debugPrint(result);

//   client.close();
//   return result;
// }

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
              textTheme: TextTheme(body1: TextStyle(color: Colors.grey), subtitle: TextStyle(color: Colors.black)),
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

class Login extends StatelessWidget {

  login(uname, pwd, context) async{
    // final url = Uri.parse('http://shirakami.trueddns.com:60181/login');
    // // final url = Uri.parse('http://localhost:8000/login');
    // Map<String, String> headers = {"Content-type": "application/json"};
    var json = {
      'uname': uname,
      'pwd': pwd,
      'rememberme': 'y'
    };
    // debugPrint(jsonEncode(json));
    // // make POST request
    // var client = http.Client();
    // var response = await client.post(url, headers: headers, body: jsonEncode(json));
    // // check the status code for the result
    // String result = response.body;
    // if (this.mounted) {
    //   this.setState(() {
    //     result = response.body;
    //   });
    // }
    // client.close();
    try {
      var r = await Requests.post("http://shirakami.trueddns.com:60181/login", json: json);
      //var r = await Requests.post('http://192.168.1.57:8000/login', json: json);
      r.raiseForStatus();
      String rs = r.content();
      print(rs);
      if (rs != "Successful"){
        return rs;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    }
    catch(e){
      print(e);
    }
  }
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    
    // final logo = Hero(
    //   tag: 'hero',
    //   child: CircleAvatar(
    //     backgroundColor: Colors.transparent,
    //     radius: 48.0,
    //     child: Image.asset('assets/logo.png'),
    //   ),
    // );

    final username = TextField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: usernameController,
      // initialValue: 'alucard@gmail.com',
      decoration: InputDecoration(
        hintText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextField(
      autofocus: false,
      // initialValue: 'some password',
      obscureText: true,
      controller: passwordController,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          login(usernameController.text, passwordController.text, context);
          // String byte = Crypt.sha256(passwordController.text).toString();
          // print(byte);
          // var generator = new PBKDF2();
          // var salt = Salt.generateAsBase64String(1);
          // var hash = generator.generateKey("mytopsecretpassword", salt, 1000, 32);
          // print(hash.toString());
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );

    final registerLabel = FlatButton(
      child: Text(
        'Register',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );
    final skipLoginLabel = FlatButton(
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
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            // logo,
            // SizedBox(height: 48.0),
            username,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
            registerLabel,
            skipLoginLabel,
          ],
        ),
      ),
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