import 'dart:async';
import 'dart:convert';
import 'package:readmore/readmore.dart';
import 'package:requests/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transparent_image/transparent_image.dart';
import 'animedetail.dart';
import 'package:http/http.dart' as http;
import 'requesturl.dart';

class Home extends StatefulWidget {
  static const routeName = '/home';

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController controller;
  List myList;
  List queryid;
  bool _loading = false;
  var requestURrl = RequestURL();
  @override
  void initState() {
    super.initState();

    getMyList();
    controller = TabController(length: 3, vsync: this);
  }

  getMyList() async {
    _loading = true;
    myList = new List();
    var r = await Requests.get(requestURrl.getApiURL+'/getanimelist');
    r.raiseForStatus();
    String rs1 = r.content();
    if (this.mounted) {
      this.setState(() {
        var resp = jsonDecode(rs1);
        for (var str in resp) {
          myList.add(str);  
        }
      });
    }
    _loading = false;
  }

  myListStatusFilter(filter) {
    List filterlist = new List();
    for (var status in myList) {
      if (status['status'] == filter) {
        filterlist.add(status);
      }
    }
    return filterlist;
  }

  queryId(animeid, listid, status, episode, rating, totaleps) async {
    queryid = new List();
    final url = Uri.parse('https://graphql.anilist.co');
    Map<String, String> headers = {"Content-type": "application/json"};
    Map variables = {'id': animeid};
    String query = '''query (\$id: Int) {
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
                      }
              }''';
    var json = {'query': query, 'variables': variables};
    var client = http.Client();
    var response =
        await client.post(url, headers: headers, body: jsonEncode(json));
    if (this.mounted) {
      this.setState(() {
        var searchList = {};
        searchList = jsonDecode(response.body);
        if (searchList['data'] != null) {
          var data = searchList['data']['Media'];
          //debugPrint(str['title']['romaji']);
          queryid.add([
            data['id'],
            data['title']['romaji'],
            data['episodes'],
            data['idMal'],
            data['coverImage']['extraLarge']
          ]);
        }
      });
    }
    client.close();
    editList(animeid, listid, status, episode, rating, totaleps);
  }

  queryData() async {
    queryid = new List();
    final url = Uri.parse('https://graphql.anilist.co');
    Map<String, String> headers = {"Content-type": "application/json"};
    for (int i = 0; i < myList.length; i++) {
      Map variables = {'id': myList[i]['anilistid']};
      String query = '''query (\$id: Int) {
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
            queryid.add([
              data['id'],
              data['title']['romaji'],
              data['episodes'],
              data['idMal'],
              data['coverImage']['extraLarge']
            ]);
          }
        });
      }
      client.close();
    }
  }

  void runLoading() {
    setState(() {
      _loading = true;
    });
    Timer(Duration(milliseconds: 1000), () {
      setState(() {
        _loading = false;
      });
    });
  }

  editList(animeid, listid, status, episode, rating, totaleps) {
    if (textController.text != "" ||
        _dropDownStatus != null ||
        _dropDownStatus != null ||
        rating != null) {
      if (episode != "" && animeid != null) {
        if (totaleps != null) {
          totaleps = queryid[0][2];

          if (int.parse(episode) > totaleps) {
            episode = queryid[0][2];
          }
        }

        episode = int.parse(episode);
        rating = int.parse(rating);
        updatedb(animeid, listid, status, episode, rating, totaleps);

        textController.text = "";
        _dropDownStatus = null;
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

    var r = await Requests.post(requestURrl.getApiURL+'/updateanimelist', json: json);
    r.raiseForStatus();
    String rs1 = r.content();
    getMyList();
  }

  deletedb(listid) async {
    var json = {'listid': listid, 'uid': 0};

    var r = await Requests.post(requestURrl.getApiURL+'/deleteanimelist', json: json);
    r.raiseForStatus();
    String rs1 = r.content();
    getMyList();
  }

  List status = ['Watching', 'Completed', 'Considering', 'Dropped'];
  
  Future<void> _pullRefresh() async {
    setState(() {
      myList = new List();
      getMyList();
    });
  }

  filterMyListUI(filter) {
    List filterList = myListStatusFilter(filter);
    return RefreshIndicator(
      onRefresh: _pullRefresh,
      child: new ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filterList == null ? 0 : filterList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 150,
          child: Card(
            child: InkWell(
              child: Row(
                children: [
                  Expanded(
                    flex: 29,
                    child: //Image.network(filterList[index]['imgurl'])
                    FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: filterList[index]['imgurl'],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column() //Image.network(today[index][7]),
                      
                  ),
                  Expanded(
                    flex: 59,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10.0,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ReadMoreText(filterList[index]['romaji'],
                                              trimLines: 3,
                                              trimMode: TrimMode.Line,
                                              trimCollapsedText: ' ',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                              
                                            ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: new Text("Status: " + filterList[index]['status'],
                              textAlign: TextAlign.left),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: new Text(filterList[index]['totaleps'] == 0 ? 
                                  "Progress: " +
                                  filterList[index]['episode'].toString() +
                                  "/-"
                                  :
                                  "Progress: " +
                                  filterList[index]['episode'].toString() +
                                  "/" +
                                  filterList[index]['totaleps'].toString(),
                              textAlign: TextAlign.left),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: new Text(
                              "Score: " + filterList[index]['rating'].toString(),
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
                                child: Text("Edit",style: TextStyle(color: Colors.black),),
                              ),
                              PopupMenuItem<int>(
                                value: 2,
                                child: Text("Delete",style: TextStyle(color: Colors.black),),
                              ),
                            ],
                            onSelected: (item) {
                              switch (item) {
                                case 0:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AnimeDetail(filterList[index]['anilistid'])),
                                  );
                                  break;

                                case 1:
                                  textController.text = filterList[index]['episode'].toString(); //after add anime
                                  _dropDownStatus = filterList[index]['status'];
                                  _dropDownRating = filterList[index]['rating'].toString();
                                  _showDialog(context, filterList[index]);
                                  break;

                                case 2:
                                  deletedb(filterList[index]['listid']);
                                  break;
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
                textController.text = filterList[index]['episode'].toString(); //after add anime
                _dropDownStatus = filterList[index]['status'];
                _dropDownRating = filterList[index]['rating'].toString();
                _showDialog(context, filterList[index]);
              },
            ),
          ),
        );
      },
      ),
    );
  }

  allMyListUI() {
    return RefreshIndicator(
      onRefresh: _pullRefresh,
      child: new ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: myList == null ? 0 : myList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 150,
          child: Card(
            child: InkWell(
              child: Row(
                children: [
                  Expanded(
                    flex: 29,
                    child:                     FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: myList[index]['imgurl'],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column() //Image.network(today[index][7]),
                      
                  ),
                  Expanded(
                    flex: 59,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10.0,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ReadMoreText(myList[index]['romaji'],
                                              trimLines: 3,
                                              trimMode: TrimMode.Line,
                                              trimCollapsedText: ' ',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                              
                                            ),
                                              
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: new Text("Status: " + myList[index]['status'],
                              textAlign: TextAlign.left),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: new Text(myList[index]['totaleps'] == 0 ? 
                                  "Progress: " +
                                  myList[index]['episode'].toString() +
                                  "/-"
                                  :
                                  "Progress: " +
                                  myList[index]['episode'].toString() +
                                  "/" +
                                  myList[index]['totaleps'].toString(),
                              textAlign: TextAlign.left),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: new Text(
                              "Score: " + myList[index]['rating'].toString(),
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
                                child: Text("Edit",style: TextStyle(color: Colors.black),),
                              ),
                              PopupMenuItem<int>(
                                value: 2,
                                child: Text("Delete",style: TextStyle(color: Colors.black),),
                              ),
                            ],
                            onSelected: (item) {
                              switch (item) {
                                case 0:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AnimeDetail(myList[index]['anilistid'])),
                                  );
                                  break;

                                case 1:
                                  textController.text = myList[index]['episode'].toString(); //after add anime
                                  _dropDownStatus = myList[index]['status'];
                                  _dropDownRating = myList[index]['rating'].toString();
                                  _showDialog(context, myList[index]);
                                  break;

                                case 2:
                                  deletedb(myList[index]['listid']);
                                  break;
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
                textController.text = myList[index]['episode'].toString(); //after add anime
                _dropDownStatus = myList[index]['status'];
                _dropDownRating = myList[index]['rating'].toString();
                _showDialog(context, myList[index]);
              },
            ),
          ),
        );
      },
      ),
    );
  }

  Future _showDialog(context, selectedList) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(selectedList['romaji']),
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
                      items:
                          ['Watching', 'Completed', 'Considering', 'Dropped'].map(
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
                            _dropDownStatus = val;
                            if (_dropDownStatus == 'Completed' &&
                                selectedList['totaleps'] != null) {
                              textController.text = selectedList['totaleps'].toString();
                            } else if (_dropDownStatus == 'Considering') {
                              textController.text = "0";
                            } else {
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
                          if (int.parse(textController.text) > selectedList['totaleps'] ||
                              _dropDownStatus == 'Completed') {
                            if (selectedList['totaleps'] != null) {
                              textController.text = selectedList['totaleps'].toString();
                            }
                          } else if (_dropDownStatus == 'Considering') {
                            textController.text = "0";
                          }
                        } 
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
                      items:
                          ['10', '9', '8', '7', '6', '5', '4', '3', '2', '1'].map(
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
              onPressed: () {
                deletedb(selectedList['listid']);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("Delete"),
            ),
            new ElevatedButton(
              onPressed: () {
                queryId(selectedList['anilistid'], selectedList['listid'], _dropDownStatus,
                    textController.text, _dropDownRating, selectedList['totaleps']);
              },
              child: Text("Edit"),
            ),
          ],
        );
      },
    );
  }

  String _dropDownStatus;
  String _dropDownRating;
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context1) {
    return MaterialApp(
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(
                    text: "All",
                  ),
                  Tab(
                    text: "Watching",
                  ),
                  Tab(
                    text: "Completed",
                  ),
                  Tab(
                    text: "Considering",
                  ),
                  Tab(
                    text: "Dropped",
                  ),
                ],
                isScrollable: true,
              ),
              title: Text('My list'),
            ),
            body: Stack(
              children: <Widget>[
                TabBarView(
                  children: [
                    allMyListUI(),
                    filterMyListUI("Watching"),
                    filterMyListUI("Completed"),
                    filterMyListUI("Considering"),
                    filterMyListUI("Dropped"),
                  ],
                ),
                _loading
                    ? Container(
                        child: Center(
                        child: CircularProgressIndicator(),
                      ))
                    : Container(), //if isLoading flag is true it'll display the progress indicator
              ],
            )),
      ),
    );
  }
}
