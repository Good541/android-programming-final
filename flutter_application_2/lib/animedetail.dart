import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/retry.dart';
import 'package:html/parser.dart';
import 'package:page_transition/page_transition.dart';
import 'package:requests/requests.dart';
import 'main.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:http/http.dart' as http;
                                           
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
  _AnimeDetailState(int animeID){
    this.animeID = animeID;
  }
  @override
  void initState() {
    super.initState();
    print(animeID.toString());
    queryAnimeInfo();
  }

  queryAnimeInfo() async {
    //print("querydata--------------");
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
    //debugPrint(jsonEncode(json));
    var client = http.Client();

    // make POST request
    var response = await client.post(url, headers: headers, body: jsonEncode(json));
    // check the status code for the result
    if (this.mounted) {
      this.setState(() {
        var searchList = {};
        searchList = jsonDecode(response.body);
        // print(jsonDecode(response.body));
        //print(jsonEncode(searchList));
        if (searchList['data'] != null) {
          var data = searchList['data']['Media'];
          //debugPrint(str['title']['romaji']);
          //print(searchList['studios']['nodes'].toString());
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
          // debugPrint(titleList[i][1]);
        }
      });
    }
    client.close();
    _loading = false;
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
    return 
      Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          title: animeInfo.isEmpty ? Text('Loading...') : Text(animeInfo[0][1]),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                children: [
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
                        child: animeInfo.isEmpty ? Text('') : animeInfo == null ? Text('') : Image.network(animeInfo[0][4]),
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
                            Text(animeInfo[0][1], 
                                style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.left
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
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
                            Text(animeInfo[0][6], 
                                style: TextStyle(
                                fontWeight: FontWeight.normal,
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
                        child: animeInfo.isEmpty ? Text('') : 
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
                        child: Text(''),
                      ),
                    ],
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
                  _loading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue)),
                    ))
                  : Container(),
                ],
              ),      

            ],
          ),
        ),
        
      );
  }
}
