import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:requests/requests.dart';
import 'requesturl.dart';
import 'main.dart';
import 'register.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  login(uname, pwd, context) async{
    var requestURrl = RequestURL();
    var json = {
      'uname': uname,
      'pwd': pwd,
      'rememberme': 'y'
    };
    String rs;
    try {
      var r = await Requests.post(requestURrl.getApiURL+"/login", json: json);
      r.raiseForStatus();
      rs = r.content();
    }
    catch(e){
      print(e);
    }
    return rs;
  }

  loginDialog(context, status){
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login warning"),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                   Text(status, textAlign: TextAlign.left),
                    ],
                );
              },
            ),
          ),
          actions: [
            new ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: false).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _passwordVisible = false;
  //String loginStatus;
@override
  Widget build(BuildContext context) {

    
    final logo = Text('Login', 
          style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 30,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center
      );

    final username = TextField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: usernameController,
      decoration: InputDecoration(
        hintText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: !_passwordVisible,
      controller: passwordController,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        suffixIcon: IconButton(
          icon: Icon(
            // Based on passwordVisible state choose the icon
            _passwordVisible
            ? Icons.visibility
            : Icons.visibility_off,
            color: Theme.of(context).primaryColorDark,
            ),
          onPressed: () {
            // Update the state i.e. toogle the state of passwordVisible variable
            setState(() {
                _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () async {
          String rs = await login(usernameController.text, passwordController.text, context);
          print(rs);
          if (rs == "Login successful" || rs == "Authorized"){
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyApp()));
          }
          else
            loginDialog(context, rs);
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
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Register())
        );
      
      },
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
            logo,
            SizedBox(height: 48.0),
            username,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
            registerLabel,
            //skipLoginLabel,
          ],
        ),
      ),
    );
  }
}