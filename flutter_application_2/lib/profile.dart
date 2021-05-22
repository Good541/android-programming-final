import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:requests/requests.dart';
import 'package:flutter_restart/flutter_restart.dart';


 
class Profile extends StatefulWidget {
    static const routeName = '/profile';
 
    @override
    State<StatefulWidget> createState() {
        return _ProfileState();
    }
}
 
class _ProfileState extends State<Profile> {
    List userdata = new List();
    List menu = new List();
    bool _loginStatus;
    @override
    void initState() {
      _loading = true;
      getAvatar();
      getuserdata();
      menuList();

      super.initState();
      
    }

    logout() async{
      // final url = Uri.parse('http://shirakami.trueddns.com:60181/login');
      // // final url = Uri.parse('http://localhost:8000/login');
      // Map<String, String> headers = {"Content-type": "application/json"};
      // var json = {
      //   'uname': uname,
      //   'pwd': pwd,
      //   'rememberme': 'y'
      // };
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
      if(_loginStatus == false){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MaterialApp(
          title: 'Login',
          home: Login(),
          ),),
        );
      }
      var r = await Requests.get("http://shirakami.trueddns.com:60181/logout");
      //var r = await Requests.get("http://192.168.1.57:8000/logout"); 
      r.raiseForStatus();
      String rs = r.content();
      //print(rs);
      if (rs != "Successful"){
        return rs;
      }        
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MaterialApp(
        title: 'Login',
        home: Login(),
        ),),
      );
    }

    usernamefield(){
      if(userdata.length != 0){
        return Text(
                      userdata[1],
                      style: TextStyle(
                        fontSize: 22.0,
                        color: Colors.black,
                      ),
                    );
      }
      return Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.black,
                    ),
                  );
    }
    getuserdata() async{
      userdata = new List();
      try{
        var r = await Requests.get('http://shirakami.trueddns.com:60181/userdata');
        //var r = await Requests.get('http://192.168.1.57:8000/userdata');
        if (this.mounted) {
          this.setState(() {
            r.raiseForStatus();
            dynamic rs = r.json();
            //print(r.content());
            userdata.add(rs['uid']);
            userdata.add(rs['uname']);
            //print(userdata[1]);
          });
        }
      }
      catch(e){
        print(e);
        _loginStatus = false;
      }
      _loading = false;
    }

    menuList(){
      menu = new List();
      menu.add(changePasswordMenu());
      menu.add(logoutMenu());
    }

    changePasswordMenu(){
      return ListTile(
        leading: Icon(Icons.edit),
        title: Text('Change password',textScaleFactor: 1.3,),
        //trailing: Icon(Icons.done),
        // subtitle: Text('Change password'),
        //selected: true,
        onTap: () {
          setState(() {
            // txt='List Tile pressed';
          });
        },
      );
    }

    logoutMenu(){
      return ListTile(
        leading: Icon(Icons.logout),
        title: Text('Logout',textScaleFactor: 1.3,),
        //trailing: Icon(Icons.done),
        // subtitle: Text('Change password'),
        //selected: true,
        onTap: () {
          setState(() {
            // txt='List Tile pressed';
          });
        },
      );
    }

    getAvatar() async {    
      try{
        var r = await Requests.get('http://shirakami.trueddns.com:60181/getuseravatar');
        //var r = await Requests.get('http://192.168.1.57:8000/getuseravatar');
        setState(() {
          r.raiseForStatus();
          var rs1 = r.bytes();
          //print(rs1);
          avatarImg = rs1;
          //return r;
        });
      }
      catch(e){
        print(e);
        _loginStatus = false;
      }
    }

    userMenu(){
      if(_loginStatus == null){
        return  <Widget>[
                      SizedBox(
                      height: 25.0,
                      ),
                      CircleAvatar(
                      backgroundImage: avatarImg == null? avatarImg: MemoryImage(avatarImg),
                      radius: 50.0,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      usernamefield(),
                      SizedBox(
                        height: 20.0,
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout',textScaleFactor: 1.3,),
                        //trailing: Icon(Icons.done),
                        // subtitle: Text('Change password'),
                        //selected: true,
                        
                        onTap: () {
                          setState(() {
                           logout();
                          });
                        },
                      ),

                    ];
      }
      else if(_loginStatus == false){
        return  <Widget>[
                      SizedBox(
                      height: 25.0,
                      ),
                      CircleAvatar(
                      backgroundImage: avatarImg == null? avatarImg: MemoryImage(avatarImg),
                      radius: 50.0,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Not sign in',
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout',textScaleFactor: 1.3,),
                        //trailing: Icon(Icons.done),
                        // subtitle: Text('Change password'),
                        //selected: true,
                        
                        onTap: () {
                          setState(() {
                           logout();
                          });
                        },
                      ),

                    ];
      }
      return <Widget>[
                      SizedBox(
                      height: 25.0,
                      ),
                      CircleAvatar(
                      backgroundImage: avatarImg == null? avatarImg: MemoryImage(avatarImg),
                      radius: 50.0,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      usernamefield(),
                      SizedBox(
                        height: 20.0,
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Change password',textScaleFactor: 1.3,),
                        //trailing: Icon(Icons.done),
                        // subtitle: Text('Change password'),
                        //selected: true,
                        onTap: () {
                          setState(() {
                            // txt='List Tile pressed';
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout',textScaleFactor: 1.3,),
                        //trailing: Icon(Icons.done),
                        // subtitle: Text('Change password'),
                        //selected: true,
                        
                        onTap: () {
                          setState(() {
                           logout();
                          });
                        },
                      ),

                    ];
    }
    var avatarImg;
    bool _loading = false;
    @override
    Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
              title: Text('Profile'),
          ),
          body: SingleChildScrollView(
          child: Center(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                height: 25.0,
                ),
                CircleAvatar(
                backgroundImage: avatarImg == null? avatarImg: MemoryImage(avatarImg),
                radius: 50.0,
                ),
                SizedBox(
                  height: 10.0,
                ),
                usernamefield(),
                SizedBox(
                  height: 20.0,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Change password',textScaleFactor: 1.3,),
                  //trailing: Icon(Icons.done),
                  // subtitle: Text('Change password'),
                  //selected: true,
                  onTap: () {
                    setState(() {
                      // txt='List Tile pressed';
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout',textScaleFactor: 1.3,),
                  //trailing: Icon(Icons.done),
                  // subtitle: Text('Change password'),
                  //selected: true,
                  
                  onTap: () {
                    setState(() {
                    logout();
                    });
                  },
                ),

              ],
                
            )
          ),
        ),
      );
    }
}

mixin Uint8List {
}