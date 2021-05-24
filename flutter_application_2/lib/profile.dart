import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:requests/requests.dart';
import 'requesturl.dart';
import 'login.dart';
 
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
    bool _passwordVisibleOldPwd;
    bool _passwordVisibleNewPwd;
    var requestURrl = RequestURL();
    
    @override
    void initState() {
      _loading = true;
      _passwordVisibleNewPwd = false;
      _passwordVisibleOldPwd = false;
      getAvatar();
      getuserdata();
      super.initState();
      
    }

    changePassword(oldpwd, newpwd) async{
      var json = {'oldpwd': oldpwd, 'newpwd': newpwd};
      var r = await Requests.post(requestURrl.getApiURL+"/changepassword", json: json);
      r.raiseForStatus();
      String rs = r.content();
      return rs;
    }

    logout() async{

      if(_loginStatus == false){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MaterialApp(
          title: 'Login',
          home: Login(),
          ),),
        );
      }
      var r = await Requests.get(requestURrl.getApiURL+"/logout");
      r.raiseForStatus();
      String rs = r.content();
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
        var r = await Requests.get(requestURrl.getApiURL+'/userdata');
        if (this.mounted) {
          this.setState(() {
            r.raiseForStatus();
            dynamic rs = r.json();
            userdata.add(rs['uid']);
            userdata.add(rs['uname']);
          });
        }
      }
      catch(e){
        print(e);
        _loginStatus = false;
      }
      _loading = false;
    }

    final oldPwdtextController = TextEditingController();
    final newPwdtextController = TextEditingController();
    changePasswordDialog(context){
      oldPwdtextController.text = null;
      newPwdtextController.text = null;

      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Change password"),
            content: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                    //Text("Old password"),
                    TextFormField(
                      controller: oldPwdtextController,
                      obscureText: !_passwordVisibleOldPwd,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.blue),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onChanged: (text) {

                      },
                      decoration: InputDecoration(
                        labelText: 'Old password',
                        hintText: 'Enter old password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisibleOldPwd
                            ? Icons.visibility
                            : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                            ),
                          onPressed: () {
                            setState(() {
                                _passwordVisibleOldPwd = !_passwordVisibleOldPwd;
                            });
                          },
                        ),
                      ), 
                    
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: newPwdtextController,
                      obscureText: !_passwordVisibleNewPwd,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.blue),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onChanged: (text) {

                      },
                      decoration: InputDecoration(
                        labelText: 'New password',
                        hintText: 'Enter new password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisibleNewPwd
                            ? Icons.visibility
                            : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                            ),
                          onPressed: () {
                            setState(() {
                                _passwordVisibleNewPwd = !_passwordVisibleNewPwd;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
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
                child: Text("Cancel"),
              ),
              new ElevatedButton(
                onPressed: () async{
                  String status = await changePassword(oldPwdtextController.text, newPwdtextController.text);
                  print(status);
                  Navigator.of(context, rootNavigator: false).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }

    getAvatar() async {    
      try{
        var r = await Requests.get(requestURrl.getApiURL+'/getuseravatar');
        setState(() {
          r.raiseForStatus();
          var rs1 = r.bytes();
          avatarImg = rs1;
        });
      }
      catch(e){
        print(e);
        _loginStatus = false;
      }
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
                  onTap: () {
                    setState(() {
                      changePasswordDialog(context);
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout',textScaleFactor: 1.3,),
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