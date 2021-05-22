import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:requests/requests.dart';
import 'package:flutter/material.dart';
import 'animedetail.dart';
 
class Schedule extends StatefulWidget {
    static const routeName = '/schedule';
 
    @override
    State<StatefulWidget> createState() {
        return _ScheduleState();
    }
}

class _ScheduleState extends State<Schedule> {
  
String _dropDownStatus;
String _dropDownRating;
final textController = TextEditingController();
ScrollController scrollController;
int amountListView = 20;
List today = new List();
List tomorrow = new List();
bool _loading = false;
int page = 1;

    void runLoading(){
      setState(() {
        _loading = true;
      });
      Timer(Duration(milliseconds: 1000), (){
        setState(() {
          _loading = false;
        });
      });
    }

    @override
    void initState(){
      super.initState();
      queryTodaySchedule();
      queryTomorrowSchedule();
    }

    getTimestamp(datedif){
      List timestamp = new List();
      DateTime scheduledate = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + datedif);
      DateTime nextdate = new DateTime(scheduledate.year, scheduledate.month, scheduledate.day + 1);
      double scheduletimesatmp = (scheduledate.millisecondsSinceEpoch / 1000) - 1;
      double nextdatetimesatmp = (nextdate.millisecondsSinceEpoch / 1000) - 1;
      timestamp.add(scheduletimesatmp.toInt());
      timestamp.add(nextdatetimesatmp.toInt());
      return timestamp;
    }

    queryTodaySchedule() async{
      List timestamp = getTimestamp(0);
      print(timestamp[0].toString()+"   "+timestamp[1].toString());
      _loading = true;
      int page = 1;
      print("querydata--------------");
      today = new List();
      final url = Uri.parse('https://graphql.anilist.co');
      Map<String, String> headers = {"Content-type": "application/json"};
      Map variables = {'airingAt_greater': timestamp[0] , 'airingAt_lesser': timestamp[1], 'page': 1, 'perPage': 50, 'sort': 'TIME'};
      for(int i=1; i<=page; i++){
        String query = '''
          query (\$page: Int, \$perPage: Int, \$airingAt_greater:Int, \$airingAt_lesser:Int, \$sort:[AiringSort]) {
              Page (page: \$page, perPage: \$perPage) {
                  pageInfo {
                      total
                      currentPage
                      lastPage
                      hasNextPage
                      perPage
                  }
                  airingSchedules(airingAt_greater:\$airingAt_greater, airingAt_lesser:\$airingAt_lesser, sort:\$sort){
                      id
                      airingAt
                      timeUntilAiring
                      episode
                      mediaId
                      media {
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
                          format
                          type
                          isAdult
                          countryOfOrigin
                      }
                  }
              }
          }
          ''';
        var json = {'query': query, 'variables': variables};
        //debugPrint(jsonEncode(json));
        var client = http.Client();
        // make POST request
        var response = await client.post(url, headers: headers, body: jsonEncode(json));
        // check the status code for the result
        if(this.mounted) {
          this.setState(() {
            var searchList = {};
            searchList = jsonDecode(response.body);
            if(searchList['data'] != null){
              var airingSchedules = searchList['data']['Page']['airingSchedules'];
              for (var str in airingSchedules){
                var date = DateTime.fromMillisecondsSinceEpoch(str['airingAt'] * 1000);
                if(str['media']['format'] == 'TV' || str['media']['format'] == 'TV_SHORT'|| str['media']['format'] == 'MOVIE'|| str['media']['format'] == 'SPECIAL' || str['media']['format'] == 'OVA' || str['media']['format'] == 'ONA'
                    && str['media']['type'] == 'ANIME' && str['media']['isAdult'] == false && str['media']['countryOfOrigin'] == 'JP')
                {
                  today.add([str['id'], date, str['episode'], str['media']['id'], str['media']['idMal'], str['media']['episodes'], str['media']['title']['romaji'], str['media']['coverImage']['extraLarge']]);
                }
              }
              page = searchList['data']['Page']['pageInfo']['lastPage'];
            }
            else {
              page = 1;
            }
          });
          
        }
        client.close();
      }
      _loading = false;
    }

    queryTomorrowSchedule() async{
      List timestamp = getTimestamp(1);
      print(timestamp[0].toString()+"   "+timestamp[1].toString());
      _loading = true;
      int page = 1;
      print("querydata--------------");
      tomorrow = new List();
      final url = Uri.parse('https://graphql.anilist.co');
      Map<String, String> headers = {"Content-type": "application/json"};
      Map variables = {'airingAt_greater': timestamp[0] , 'airingAt_lesser': timestamp[1], 'page': 1, 'perPage': 50, 'sort': 'TIME'};
      for(int i=1; i<=page; i++){
        String query = '''
          query (\$page: Int, \$perPage: Int, \$airingAt_greater:Int, \$airingAt_lesser:Int, \$sort:[AiringSort]) {
              Page (page: \$page, perPage: \$perPage) {
                  pageInfo {
                      total
                      currentPage
                      lastPage
                      hasNextPage
                      perPage
                  }
                  airingSchedules(airingAt_greater:\$airingAt_greater, airingAt_lesser:\$airingAt_lesser, sort:\$sort){
                      id
                      airingAt
                      timeUntilAiring
                      episode
                      mediaId
                      media {
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
                          format
                          type
                          isAdult
                          countryOfOrigin
                      }
                  }
              }
          }
          ''';
        var json = {'query': query, 'variables': variables};
        //debugPrint(jsonEncode(json));
        var client = http.Client();
        // make POST request
        var response = await client.post(url, headers: headers, body: jsonEncode(json));
        // check the status code for the result
        if(this.mounted) {
          this.setState(() {
            var searchList = {};
            searchList = jsonDecode(response.body);
            if(searchList['data'] != null){
              var airingSchedules = searchList['data']['Page']['airingSchedules'];
              for (var str in airingSchedules){
                var date = DateTime.fromMillisecondsSinceEpoch(str['airingAt'] * 1000);
                if((str['media']['format'] == 'TV' || str['media']['format'] == 'TV_SHORT'|| str['media']['format'] == 'MOVIE'|| str['media']['format'] == 'SPECIAL' || str['media']['format'] == 'OVA' || str['media']['format'] == 'ONA')
                  && str['media']['type'] == 'ANIME' && str['media']['isAdult'] == false && str['media']['countryOfOrigin'] == 'JP')
                {
                  tomorrow.add([str['id'], date, str['episode'], str['media']['id'], str['media']['idMal'], str['media']['episodes'], str['media']['title']['romaji'], str['media']['coverImage']['extraLarge']]);
                  print(str['media']['countryOfOrigin']);
                }
              }
              page = searchList['data']['Page']['pageInfo']['lastPage'];
            }
            else {
              page = 1;
            }
          });
          
        }
        client.close();
      }
      _loading = false;
    }

    thisSeason(date){
      if(date.month() >= 1 && date.month() <= 3)
        return "WINTER";
      else if(date.month() >= 4 && date.month() <= 6)
        return "SPRING";
      else if(date.month() >= 7 && date.month() <= 9)
        return "SUMMER";
      else if(date.month() >= 10 && date.month() <= 12)
        return "FALL";
    }

      addAnime(animeid, episode, status, rating, malid, romaji, imgurl,
      totaleps) {
    if (episode != "" ||
        _dropDownStatus != null ||
        _dropDownRating != null ||
        rating != null) {
      if (episode != "" && animeid != null) {
        if (totaleps == null) {
          totaleps = 0;
        } else if (int.parse(episode) > totaleps) {
          episode = totaleps.toString();
        }
        episode = int.parse(episode);
        rating = int.parse(rating);
        addTodb(animeid, episode, status, rating, malid, romaji, imgurl,
            totaleps);

        //after add anime
        Navigator.of(context, rootNavigator: true).pop();
        // debugPrint(animeid.toString());
        // debugPrint(episode);
        // debugPrint(status);
        // debugPrint(rating);

        textController.text = "";
        _dropDownStatus = null;
        _dropDownRating = null;
        rating = null;
      }
    }
  }

  addTodb(animeid, episode, status, rating, malid, romaji, imgurl,
      totaleps) async {
    var json = {
      'uid': 0,
      'anilistid': animeid,
      'malid': malid,
      'status': status,
      'episode': episode,
      'rating': rating,
      'romaji': romaji,
      'imgurl': imgurl,
      'totaleps': totaleps
    };
    var r = await Requests.post('http://shirakami.trueddns.com:60181/addanime', json: json);
    //var r = await Requests.post('http://192.168.1.57:8000/addanime', json: json);
    r.raiseForStatus();
    String rs1 = r.content();
  }

  editList(animeid, listid, status, episode, rating, totaleps) {
    if (episode != "" ||
        _dropDownStatus != null ||
        _dropDownRating != null ||
        rating != null) {
      if (episode != "" && animeid != null) {
        if (totaleps == null) {
          totaleps = 0;
        } else if (int.parse(episode) > totaleps) {
          episode = totaleps.toString();
        }
        episode = int.parse(episode);
        rating = int.parse(rating);
        updatedb(animeid, listid, status, episode, rating, totaleps);

        //after add anime

        textController.text = "";
        _dropDownStatus = null;
        rating = null;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  updatedb(animeid, listid, status, episode, rating, totaleps) async {
    var json = {
      'listid': listid,
      'uid': 0,
      'anilistid': animeid,
      'status': status,
      'episode': episode,
      'rating': rating,
      'totaleps': totaleps
    };

    var r = await Requests.post('http://shirakami.trueddns.com:60181/updateanimelist', json: json);
    //var r = await Requests.post('http://192.168.1.57:8000/updateanimelist', json: json);
    r.raiseForStatus();
    String rs1 = r.content();
  }

  deletedb(listid) async {
    var json = {'listid': listid, 'uid': 0};
    var r = await Requests.post('http://shirakami.trueddns.com:60181/deleteanimelist', json: json);
    //var r = await Requests.post('http://192.168.1.57:8000/deleteanimelist', json: json);
    r.raiseForStatus();
    String rs1 = r.content();
  }

  checkMyList(context, animeData) async {
    _loading = true;
    var r = await Requests.get('http://shirakami.trueddns.com:60181/getanimelist');
    //var r = await Requests.get('http://192.168.1.57:8000/getanimelist');
    r.raiseForStatus();
    String rs1 = r.content();
    int listid;
    if (this.mounted) {
      this.setState(() {
        var resp = jsonDecode(rs1);
        for (var str in resp) {
          //str['id'], date, str['episode'], str['media']['id'], str['media']['idMal'], str['media']['episodes'], str['media']['title']['romaji'], str['media']['coverImage']['extraLarge']
          if(animeData[3] == str['anilistid']){
            listid = str['listid'];
            textController.text = str['episode'].toString(); //after add anime
            _dropDownStatus = str['status'];
            _dropDownRating = str['rating'].toString();
            return _showEditDialog(context, animeData, listid);
          }
        }
      });
    }
    textController.text = ""; //after add anime
    _dropDownStatus = null;
    _dropDownRating = null;
    _loading = false;
    _showDialog(context, animeData);
  }

  Future _showDialog(context, animeData) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(animeData[6]),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Status', textAlign: TextAlign.left),
                    DropdownButton(
                      value: _dropDownStatus,
                      hint: Text('Status'),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: ['Watching', 'Completed', 'Considering', 'Dropped'].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(() {
                            _dropDownStatus = val;
                            if(_dropDownStatus == 'Completed' && animeData[5] != null){
                              textController.text = animeData[5].toString();
                            }
                            else if(_dropDownStatus == 'Considering'){
                              textController.text = "0";
                            }
                            else{
                              textController.text = "";
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text('Episode progress'),
                    TextField(
                      controller: textController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.blue),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onChanged: (text) {
                              if(animeData[5] == null){

                              }
                              else if(int.parse(textController.text) > animeData[5] || _dropDownStatus == 'Completed'){
                                textController.text = animeData[5].toString();
                              }
                              else if(_dropDownStatus == 'Considering'){
                                textController.text = "0";
                              }
                      } // Only numbers can be entered
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text('Rating'),
                    DropdownButton(
                      hint: _dropDownRating == null
                          ? Text('Rating')
                          : Text(
                              _dropDownRating,
                              style: TextStyle(color: Colors.blue),
                            ),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: ['10', '9', '8', '7', '6', '5', '4', '3', '2', '1'].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(
                          () {
                            _dropDownRating = val;
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            new ElevatedButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Text("Cancel"),
            ),
            new ElevatedButton(
              onPressed: () => addAnime(animeData[3], textController.text, _dropDownStatus, _dropDownRating, animeData[4], animeData[6], animeData[7], animeData[5]),
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future _showEditDialog(context, animeData, listid) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(animeData[6]),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Status', textAlign: TextAlign.left),
                    DropdownButton(
                      value: _dropDownStatus,
                      hint: Text('Status'),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: ['Watching', 'Completed', 'Considering', 'Dropped'].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(() {
                            _dropDownStatus = val;
                            if(_dropDownStatus == 'Completed' && animeData[5] != null){
                              textController.text = animeData[5].toString();
                            }
                            else if(_dropDownStatus == 'Considering'){
                              textController.text = "0";
                            }
                            else{
                              textController.text = "";
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text('Episode progress'),
                    TextField(
                      controller: textController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.blue),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onChanged: (text) {
                              if(animeData[5] == null){

                              }
                              else if(int.parse(textController.text) > animeData[5] || _dropDownStatus == 'Completed'){
                                textController.text = animeData[5].toString();
                              }
                              else if(_dropDownStatus == 'Considering'){
                                textController.text = "0";
                              }
                      } // Only numbers can be entered
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text('Rating'),
                    DropdownButton(
                      hint: _dropDownRating == null
                          ? Text('Rating')
                          : Text(
                              _dropDownRating,
                              style: TextStyle(color: Colors.blue),
                            ),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: ['10', '9', '8', '7', '6', '5', '4', '3', '2', '1'].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(
                          () {
                            _dropDownRating = val;
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            new ElevatedButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Text("Cancel"),
            ),
            new ElevatedButton(
              onPressed: (){
                deletedb(listid);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("Delete"),
            ),
            new ElevatedButton(
              onPressed: (){
                updatedb(animeData[4], listid, _dropDownStatus, textController.text, _dropDownRating, animeData[5]);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("Edit"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pullRefresh() async {
    setState(() {
      today = new List();
      tomorrow = new List();
      queryTodaySchedule();
      queryTomorrowSchedule();
    });
  }
    @override
    Widget build(BuildContext context) {
 
        return MaterialApp(
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(text: "Today",),
                    Tab(text: "Tomorrow",),
                  ],
                  isScrollable: false,
                ),
                title: Text('Schedule'),
              ),
              body:  Stack(
                children: <Widget>[
                  TabBarView(
                    children: [RefreshIndicator(
                    onRefresh: _pullRefresh,
                    child: 
                      new ListView.builder(
                        controller: scrollController,
                        itemCount: today == null ? 0 : today.length,
                        itemBuilder: (BuildContext context, int index){
                          return Container(
                            height: 150,
                            child: Card(
                              child: InkWell(
                              //color: Colors.orange,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 33,
                                    child: Image.network(today[index][7]),
                                  ),
                                  Expanded(
                                    flex: 66,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: new Text(today[index][6], 
                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,), 
                                                            textAlign: TextAlign.left),
                                        ),
                                    //),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                    // Expanded( 
                                    //   child: 
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: new Text("At: "+today[index][1].toString(), 
                                                            //style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,), 
                                                            textAlign: TextAlign.left),
                                        ),
                                    //),
                                    //Expanded( 
                                    //  child: 
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: new Text("Ep: "+today[index][2].toString(), 
                                                            //style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,), 
                                                            textAlign: TextAlign.left),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 10,
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: PopupMenuButton(
                                            icon: Icon(Icons.more_vert),  //don't specify icon if you want 3 dot menu
                                            color: Colors.white,
                                            itemBuilder: (context) => [
                                              PopupMenuItem<int>(
                                                value: 0,
                                                child: Text("Anime detail",style: TextStyle(color: Colors.black),),
                                              ),
                                              PopupMenuItem<int>(
                                                value: 1,
                                                child: Text("Add",style: TextStyle(color: Colors.black),),
                                              ),
                                            ],
                                            onSelected: (item) {
                                              switch (item) {
                                                case 0:
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => AnimeDetail(today[index][3])),
                                                  );
                                                  break;

                                                case 1:
                                                  // textController.text = myList[index][5].toString(); //after add anime
                                                  // _dropDownStatus = myList[index][4];
                                                  // _dropDownRating = myList[index][6].toString();
                                                  checkMyList(context, today[index]);
                                                  break;

                                                // case 2:
                                                //   //deletedb(myList[index]['listid']);
                                                //   break;
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                      
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AnimeDetail(today[index][3])),
                                );
                              },
                              
                            ),
                            ),
                          );
                        },
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: _pullRefresh,
                      child: 
                        new ListView.builder(
                          controller: scrollController,
                          itemCount: tomorrow == null ? 0 : tomorrow.length,
                          itemBuilder: (BuildContext context, int index){
                            return Container(
                              height: 150,
                              child: Card(
                                child: InkWell(
                                //color: Colors.orange,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 33,
                                      child: Image.network(tomorrow[index][7]),
                                    ),
                                    Expanded(
                                      flex: 66,
                                      child: Column(
                                        children: [
                                          //Expanded( 
                                            //child:
                                            //                                
                                              SizedBox(
                                                height: 10.0,
                                              ), 
                                              Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Text(tomorrow[index][6], 
                                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,), 
                                                                  textAlign: TextAlign.left),
                                              ),
                                          //),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                          // Expanded( 
                                          //   child: 
                                              Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Text("At: "+tomorrow[index][1].toString(), 
                                                                  //style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,), 
                                                                  textAlign: TextAlign.left),
                                              ),
                                          //),
                                          //Expanded( 
                                          //  child: 
                                              Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Text("Ep: "+tomorrow[index][2].toString(), 
                                                                  //style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,), 
                                                                  textAlign: TextAlign.left),
                                              ),
                                          //),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                              flex: 10,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: PopupMenuButton(
                                      icon: Icon(Icons.more_vert),  //don't specify icon if you want 3 dot menu
                                      color: Colors.white,
                                      itemBuilder: (context) => [
                                        PopupMenuItem<int>(
                                          value: 0,
                                          child: Text("Anime detail",style: TextStyle(color: Colors.black),),
                                        ),
                                        PopupMenuItem<int>(
                                          value: 1,
                                          child: Text("Add",style: TextStyle(color: Colors.black),),
                                        ),
                                      ],
                                      onSelected: (item) {
                                        switch (item) {
                                          case 0:
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => AnimeDetail(tomorrow[index][3])),
                                            );
                                            break;

                                          case 1:
                                            // textController.text = myList[index][5].toString(); //after add anime
                                            // _dropDownStatus = myList[index][4];
                                            // _dropDownRating = myList[index][6].toString();
                                            checkMyList(context, tomorrow[index]);
                                            break;

                                          // case 2:
                                          //   //deletedb(myList[index]['listid']);
                                          //   break;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              )
                                
                            ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AnimeDetail(tomorrow[index][3])),
                                  );
                                },
                                
                              ),
                              ),
                            );
                          },
                        ),
                    ),
                    ],
                  ),
                   _loading?  Container(child: Center(
                      child: CircularProgressIndicator(),
                  )): Container(), //if isLoading flag is true it'll display the progress indicator
                ],
          )
        ),
      ),
    );
  }
}