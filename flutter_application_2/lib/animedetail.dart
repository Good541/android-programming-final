import 'dart:convert';
import 'package:android_intent/android_intent.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:requests/requests.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:http/http.dart' as http;
import 'package:readmore/readmore.dart';
import 'requesturl.dart';
                                           
class AnimeDetail extends StatefulWidget {
  int animeID;
  AnimeDetail(animeID){
    this.animeID = animeID;
  }

  @override
  _AnimeDetailState createState() => _AnimeDetailState(animeID);
}

class _AnimeDetailState extends State<AnimeDetail> {
  bool _loading = false;
  int animeID;
  List animeInfo;
  List lcButtonList;
  List availableLicensors = new List();
  List streamingServiceList = ['musethyt',	'bilibili',	'aisplay',	'netflix',	'anioneyt',	'iqiyi',	'flixer',	'wetv',	'trueid',	'viu',	'pops',	'linetv',	'amazon',	'iflix'];
  List streamingServiceView = ['Muse Thailand (Youtube)', 'BiliBili', 'AIS Play', 'Netflix', 'Ani-One Asia (Youtube)', 'iQiyi', 'FLIXER', 'WeTV', 'TrueID', 'Viu', 'POPS', 'LINE TV', 'Amazon', 'iflix'];
  List streamingServiceLink = ['com.google.android.youtube', 'com.bstar.intl', 'com.ais.mimo.AISPlay', 'com.netflix.mediaclient','com.google.android.youtube', 'com.iqiyi.i18n', 'com.flixer.flixer'];
  List lcAnimeList = new List();
  var requestURrl = RequestURL();
  _AnimeDetailState(int animeID){
    this.animeID = animeID;
  }
  @override
  void initState() {
    super.initState();
    print(animeID.toString());
    queryAnimeInfo();
    getLcAnimeByID();
  }

  queryAnimeInfo() async {
    _loading = true;
    animeInfo = new List();
    final url = Uri.parse('https://graphql.anilist.co');
    Map<String, String> headers = {"Content-type": "application/json"};
    Map variables = {'id': animeID, 'isMain': true, 'asHtml': true};
    String query = '''query (\$id: Int, \$isMain: Boolean, \$asHtml: Boolean) {
                      Media (id:\$id, type: ANIME) {
                          id
                          idMal
                          episodes
                          title {
                              romaji
                          }
                          startDate{
                            month
                          }
                          coverImage{
                            extraLarge
                          }
                          studios(isMain:\$isMain){
                            nodes{
                              name
                            }
                          }
                          description(asHtml:\$asHtml)
                          format
                      }
              }''';
    var json = {'query': query, 'variables': variables};
    var client = http.Client();
    var response = await client.post(url, headers: headers, body: jsonEncode(json));
    if (this.mounted) {
      this.setState(() {
        var searchList = {};
        searchList = jsonDecode(response.body);
        if (searchList['data'] != null) {
          var data = searchList['data']['Media'];
          String studioStr;
          String descriptionStr;
          data['studios']['nodes'].forEach((var x) {
            if(studioStr == null) studioStr = x['name'];
            else studioStr = studioStr+", "+x['name'];
          });
          final document = parse(data['description']);
          descriptionStr = parse(document.body.text).documentElement.text;
          print(descriptionStr);
          animeInfo.add([
            data['id'],
            data['title']['romaji'],
            data['episodes'],
            data['idMal'],
            data['coverImage']['extraLarge'],
            studioStr,
            descriptionStr,
            data['format']
          ]);
        }
      });
    }
    client.close();
    _loading = false;
  }

  getLcAnimeByID() async{
    //_loading = true;
    lcAnimeList = new List();
    var json = {"anilistid": animeID};
    var r = await Requests.post(requestURrl.getApiURL+'/getlcbyid', json: json);
    r.raiseForStatus();
    String rs1 = r.content();
    var resp = jsonDecode(rs1);
    if(resp.isEmpty){
      print("empty");
      return;
    }

    // if (this.mounted) {
    //   this.setState(() {
    for (var str in resp) {
      lcAnimeList.add(str);
    }        
    //   });
    // }
    addLicensor();
    
  }

  addLicensor(){
    availableLicensors = new List();
    for (String streamingService in streamingServiceList){
      
      if (lcAnimeList[0][streamingService] == 1){
        availableLicensors.add({'name':streamingServiceView[streamingServiceList.indexOf(streamingService)], 'link': streamingServiceLink[streamingServiceList.indexOf(streamingService)]});
      }
    }
  }

  List<Widget> buttonsList;
  List<Widget> _buildButtonsWithNames() {
    buttonsList = [];
    for (int i = 0; i < availableLicensors.length; i+=2) {
      buttonsList.add(
        
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Expanded(
            flex: 5,
            child: Text(''),
          ),
          Expanded(
              flex: 44,
              child: new ElevatedButton(
                onPressed: () async {
                  if(availableLicensors[i]['name'] == 'Muse Thailand (Youtube)'){
                    const url = 'https://www.youtube.com/channel/UCn8hjQOnGYR1AZtYYMYP5jQ';
                    AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      data: url,
                    );
                    await intent.launch();
                  }
                  else if(availableLicensors[i]['name'] == 'Ani-One Asia (Youtube)'){
                    const url = 'https://www.youtube.com/channel/UC0wNSTMWIL3qaorLx0jie6A';
                    AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      data: url,
                    );
                    await intent.launch();
                  }
                  else{
                      await LaunchApp.openApp(
                        androidPackageName: availableLicensors[i]['link'],
                        openStore: false
                      ); 
                  }
                },
                child: Container(
                    child: Center(
                  child: Text(
                    availableLicensors[i]['name'],
                    textAlign: TextAlign.center,
                  ),
                )))),
          Expanded(
            flex: 2,
            child: Text(''),
          ),
          i+1>=availableLicensors.length? 
           Expanded(
              flex: 44,
              child: new Text(''))
          :
          Expanded(
              flex: 44,
              child: new ElevatedButton(
                onPressed: () async {
                  if(availableLicensors[i+1]['name'] == 'Muse Thailand (Youtube)'){
                    const url = 'https://www.youtube.com/channel/UCn8hjQOnGYR1AZtYYMYP5jQ';
                    AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      data: url,
                    );
                    await intent.launch();
                  }
                  else if(availableLicensors[i+1]['name'] == 'Ani-One Asia (Youtube)'){
                    const url = 'https://www.youtube.com/channel/UC0wNSTMWIL3qaorLx0jie6A';
                    AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      data: url,
                    );
                    await intent.launch();
                  }
                  else{
                      await LaunchApp.openApp(
                        androidPackageName: availableLicensors[i+1]['link'],
                        openStore: false
                      ); 
                  }
                },
                child: Container(
                    child: Center(
                  child: Text(
                    availableLicensors[i+1]['name'],
                    textAlign: TextAlign.center,
                  ),
                )))),
          Expanded(
            flex: 5,
            child: Text(''),
          ),
        ],
     ),);
    }
    return buttonsList;
  }

  openBrowser(url){
    FlutterWebBrowser.openWebPage(
    url: url,
    customTabsOptions: CustomTabsOptions(
      colorScheme: CustomTabsColorScheme.dark,
      toolbarColor: Colors.blue,
      secondaryToolbarColor: Colors.green,
      navigationBarColor: Colors.amber,
      addDefaultShareMenuItem: true,
      instantAppsEnabled: true,
      showTitle: true,
      urlBarHidingEnabled: true,
    ),
    safariVCOptions: SafariViewControllerOptions(
      barCollapsingEnabled: true,
      preferredBarTintColor: Colors.green,
      preferredControlTintColor: Colors.amber,
      dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
      modalPresentationCapturesStatusBarAppearance: true,
    ),
  );
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: BackButton(onPressed: () => Navigator.of(context, rootNavigator: false).pop()),
          title: animeInfo.isEmpty ? Text('Loading...') : Text(animeInfo[0][1]),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child:
                Column(
                  children: [
                    SizedBox(
                      height: 25.0,
                    ),
                                                  
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Text(''),
                        ),
                        Expanded(
                          flex: 90,
                          child: animeInfo.isEmpty ? Text('') : 
                              Text(animeInfo[0][1], 
                                  style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.left
                              ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(''),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Text(''),
                        ),
                        Expanded(
                          flex: 28,
                          child: animeInfo.isEmpty ? Text('') : 
                              animeInfo == null ? 
                              Text('') : //Image.network(animeInfo[0][4]),
                              FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: animeInfo[0][4],
                              ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(''),
                        ),
                        Expanded(
                          flex: 58,
                          child:  Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              animeInfo.isEmpty ? Text('') : 
                              animeInfo[0][5] == null ? Text('Studio: -', 
                                  style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.left
                              ) : 
                              Text('Studio: '+animeInfo[0][5], 
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.left
                              ),
                              animeInfo.isEmpty ? Text('') : 
                              animeInfo[0][7] == null ? Text('Type: -', 
                                  style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.left
                              ) : 
                              Text('Type: '+animeInfo[0][7], 
                                  style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.left
                              ),
                              animeInfo.isEmpty ? Text('') : 
                              animeInfo[0][2] == null ? 
                              Text('Episodes: -', 
                                  style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.left
                              ) : 
                              Text('Episodes: '+animeInfo[0][2].toString(), 
                                  style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.left
                              ),
                              Text(animeInfo.isEmpty ? "":'Licensor: '+ (lcAnimeList.isEmpty ? "-": lcAnimeList[0]['licensor'] == 0 ? "-" : lcAnimeList[0]['licensor']), 
                                  style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.left
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(''),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Text(''),
                        ),
                        Expanded(
                          flex: 90,
                          child: animeInfo.isEmpty ? Text('') :
                            ReadMoreText(
                                animeInfo[0][6],
                                trimLines: 5,
                                colorClickableText: Colors.blue,
                                trimMode: TrimMode.Line,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                                moreStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                                lessStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                              
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(''),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    availableLicensors.isEmpty ? Row():Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Row(),
                        ),
                        Expanded(
                          flex: 90,
                          child: animeInfo.isEmpty ? Row() : 
                              Text('Streaming services', 
                                  style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.left
                              ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(''),
                        ),
                      ],
                    ),
                    animeInfo.isEmpty ?                   
                    Row() : 
                      availableLicensors.isEmpty ? 
                      Row() : 
                      Container(
                        child: Column(
                          children: _buildButtonsWithNames(),
                        ),
                      ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Text(''),
                        ),
                        Expanded(
                          flex: 90,
                          child: animeInfo.isEmpty ? Row() : 
                              Text('More info', 
                                  style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.left
                              ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Row(),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Row(),
                        ),
                        Expanded(
                          flex: 44,
                          child: animeInfo.isEmpty ? Text('') : 
                            new ElevatedButton(
                              onPressed: () => openBrowser("https://myanimelist.net/anime/"+animeInfo[0][3].toString()),
                              child: Text("MyAnimeList"),
                            ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(''),
                        ),
                        Expanded(
                          flex: 44,
                          child: animeInfo.isEmpty ? Text('') : 
                            new ElevatedButton(
                              onPressed: () => openBrowser("https://anilist.co/anime/"+animeInfo[0][0].toString()),
                              child: Text("AniList"),
                            ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(''),
                        ),
                      ],
                    ),
                    
                    SizedBox(
                      height: 25.0,
                    ),              

                  ],
                ),                    
              ),
              _loading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue)),
                ))
              : Container(),      
            ],
          ),
      ),
      );
  }
}
