import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:requests/requests.dart';
import 'requesturl.dart';
import 'main.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _passwordVisible = false;


  login(uname, pwd,) async{
    var requestURrl = RequestURL();
    var json = {
      'uname': uname,
      'pwd': pwd,
      'rememberme': 'y'
    };
    try {
      var r = await Requests.post(requestURrl.getApiURL+"/login", json: json);
      r.raiseForStatus();
      String rs = r.content();
      print(rs);
    }
    catch(e){
      print(e);
    }
  }

  register(uname, pwd) async{
    var requestURrl = RequestURL();
    var json = {
      'uname': uname,
      'pwd': pwd,
      'rememberme': 'y'
    };
    String rs;
    try {
      var r = await Requests.post(requestURrl.getApiURL+"/signup", json: json);
      r.raiseForStatus();
      rs = r.content();
      print(rs);
    }
    catch(e){
      print(e);
    }
    return rs;
  }

  registerDialog(context, status){
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Register warning"),
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
  @override
  Widget build(BuildContext context) {

  
    final logo = 
      Text('Register', 
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
      // initialValue: 'alucard@gmail.com',
      decoration: InputDecoration(
        hintText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      autofocus: false,
      // initialValue: 'some password',
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

    final registerButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () async{
          //register(usernameController.text, passwordController.text, context);
          String rs = await register(usernameController.text, passwordController.text);
          print(rs);
          print(rs);
          if (rs == "Register successful"){
            await login(usernameController.text, passwordController.text);
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyApp()));
          }
          else if(rs == "Authorized"){
            registerDialog(context, "You're already login. If you want to create new account, please restart app and try again");
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyApp()));
          }
          else
            registerDialog(context, rs);
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Register', style: TextStyle(color: Colors.white)),
      ),
    );

    final goLoginPage = FlatButton(
      child: Text(
        'Log in with exist account',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: false).pop();
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
            registerButton,
            goLoginPage,
          ],
        ),
      ),
    );
  }
}