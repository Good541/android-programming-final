import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:readmore/readmore.dart';
import 'package:requests/requests.dart';
import 'package:transparent_image/transparent_image.dart';
import 'animedetail.dart';
import 'requesturl.dart';

class LicensedAnime extends StatefulWidget {
  static const routeName = '/lcinfo';

  @override
  State<StatefulWidget> createState() {
    return _LicensedAnimeState();
  }
}

class _LicensedAnimeState extends State<LicensedAnime> {
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";
  TabController controller;
  bool _loading = false;
  List animeList = new List();
  var mediaformat = ['TV', 'TV_SHORT', 'MOVIE', 'SPECIAL', 'OVA', 'ONA'];
  List mediaStatus = ['FINISHED', 'RELEASING', 'NOT_YET_RELEASED'];
  List mediaSeson = ['WINTER', 'SPRING', 'SUMMER', 'FALL'];
  List streamingService = ['musethyt', 'anioneyt', 'bilibili', 'aisplay', 'flixer', 'iqiyi', 'netflix', 'iqiyi', 'trueid', 'viu', 'pops', 'linetv', 'amazon', 'iflix'];
  int fetchPage;
  String queryState = "initdata";
  List lcAnimeList;
  var requestURrl = RequestURL();

  List currentFilter;
  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: "Search anime...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
      IconButton(
        icon: const Icon(Icons.filter_alt_outlined),
        onPressed: (){
          _filterDialog(context);
        },
      ),
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
      debugPrint('_startSearch');
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      searchLcAnime();
      debugPrint('updateSearchQuery');
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
      queryState = "initdata";
      getLcAnime();
      debugPrint('_stopSearching');
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
      debugPrint('_clearSearchQuery');
    });
  }

  getLcAnime() async{
    fetchPage = 1;
    _loading = true;
    queryState = "initData";
    lcAnimeList = new List();
    var json = {"page": 1, "perPage": 20};
    var r = await Requests.post(requestURrl.getApiURL+'/getlclist', json: json);
    r.raiseForStatus();
    String rs1 = r.content();
    if (rs1 == "Page ended"){
      this.setState(() {
          _loading = false;
        }
      );
      return;
    }
    if (this.mounted) {
      this.setState(() {
        var resp = jsonDecode(rs1);
        for (var str in resp) {
          lcAnimeList.add(str);
        }
        amountListView = lcAnimeList.length;
    
      });
    }
    _loading = false;
    
  }

  getNextLcAnime() async{
    _loading = true;
    queryState = "initData";
    var json = {"page": fetchPage, "perPage": 20};
    var r = await Requests.post(requestURrl.getApiURL+'/getlclist', json: json);
    r.raiseForStatus();
    String rs1 = r.content();
    if (rs1 == "Page ended"){
      this.setState(() {
          _loading = false;
        }
      );
      return;
    }
    if (this.mounted) {
      this.setState(() {
        var resp = jsonDecode(rs1);
        for (var str in resp) {
          lcAnimeList.add(str);
        }
        amountListView = lcAnimeList.length;
      });
    }
    
    _loading = false;
  }

  filterLcAnime(licensor, streamingServiceIndex, season, year, format) async{
    _loading = true;
    fetchPage = 1;
    queryState = "filterData";
    lcAnimeList = new List();
    year == null? year = null : year = int.parse(year);
    currentFilter = [licensor, season, year, format, streamingServiceIndex];
    String streaming = streamingServiceIndex == null? null : streamingService[streamingServiceIndex];
    var json = {"licensor":licensor, "season":season, "year":year, "format":format, "streaming": streaming, 'page': 1, 'perPage': 20};
    var r = await Requests.post(requestURrl.getApiURL+'/filterlclist', json: json);
    r.raiseForStatus();
    String rs1 = r.content();
    if (rs1 == "Page ended"){
      this.setState(() {
          _loading = false;
        }
      );
      return;
    }
    if (this.mounted) {
      this.setState(() {
      var resp = jsonDecode(rs1);
      for (var str in resp) {
        lcAnimeList.add(str);
      }
      amountListView = lcAnimeList.length;
      });
    }
    print(lcAnimeList.length.toString());
    _loading = false;
  }

  filterNextLcAnime(licensor, season, year, format, streamingServiceIndex) async{
    _loading = true;
    queryState = "filterData";
    String streaming = streamingServiceIndex == null? null : streamingService[streamingServiceIndex];
    var json = {"licensor":licensor, "season":season, "year":year, "format":format, "streaming": streaming, 'page': fetchPage, 'perPage': 20};
    var r = await Requests.post(requestURrl.getApiURL+'/filterlclist', json: json);
    r.raiseForStatus();
    String rs1 = r.content();
    print(rs1);
    if (rs1 == "Page ended"){
      this.setState(() {
          _loading = false;
        }
      );
      return;
    }
    if (this.mounted) {
      this.setState(() {
        var resp = jsonDecode(rs1);
        for (var str in resp) {
          lcAnimeList.add(str);
        }
        amountListView = lcAnimeList.length;
            
      });
    }
    _loading = false;
  }


  
  @override
  void initState() {
    super.initState();
    fetchPage = 1;
    yearGenerator();
    this.getLcAnime();
    scrollController = new ScrollController()..addListener(_scrollListener);
  }

  searchLcAnime() async{
    _loading = true;
    fetchPage = 1;
    lcAnimeList = new List();
    queryState = "queryData";
    var json = {"search":searchQuery, 'page': fetchPage, 'perPage': 20};
    var r = await Requests.post(requestURrl.getApiURL+'/searchlclist', json: json);
    r.raiseForStatus();
    String rs1 = r.content();
    if (rs1 == "Page ended"){
      this.setState(() {
          _loading = false;
        }
      );
      return;
    }
    if (this.mounted) {
      this.setState(() {
        var resp = jsonDecode(rs1);
        for (var str in resp) {
          lcAnimeList.add(str);
        }
        amountListView = lcAnimeList.length;
      });
    }
    print(lcAnimeList.length.toString());
    _loading = false;
  }

  searchNextLcAnime() async{
    _loading = true;
    queryState = "queryData";
    var json = {"search":searchQuery, 'page': fetchPage, 'perPage': 20};
    var r = await Requests.post(requestURrl.getApiURL+'/searchlclist', json: json);
    r.raiseForStatus();
    String rs1 = r.content();
    if (rs1 == "Page ended"){
      this.setState(() {
          _loading = false;
        }
      );
      return;
    }
    if (this.mounted) {
      this.setState(() {
        var resp = jsonDecode(rs1);
        for (var str in resp) {
          lcAnimeList.add(str);
        }
        amountListView = lcAnimeList.length;
        
      });
    }
    _loading = false;
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
          fetchPage++;        
          switch(queryState){
            case "initData":
              setState(() {
                getNextLcAnime();
              });
              break;

            case "queryData":
              searchNextLcAnime();
              setState(() {

              });
              break;

            case "filterData":
              setState(() {
                filterNextLcAnime(currentFilter[0], currentFilter[1], currentFilter[2], currentFilter[3], currentFilter[4]);
              });
              break;

          }
        }
  }

  queryId(animeid) async {
    //print("querydata--------------");
    _loading = true;
    int malid;
    int totaleps;
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
    var response = await client.post(url, headers: headers, body: jsonEncode(json));
    var searchList = {};
    if (this.mounted) {
      this.setState(() {
        searchList = jsonDecode(response.body);
        _loading = false;
        // if (searchList['data'] != null) {
        //   
        //   client.close();
        //   return searchList['data']['Media'];
        // }
      });
      
    }
    client.close();
    return searchList['data']['Media'];
  }
  

  thisSeason(date){
    if(date.month >= 1 && date.month <= 3)
      return "WINTER";
    else if(date.month >= 4 && date.month <= 6)
      return "SPRING";
    else if(date.month >= 7 && date.month <= 9)
      return "SUMMER";
    else if(date.month >= 10 && date.month <= 12)
      return "FALL";
  }

  addAnime(animeid, episode, status, rating, malid, romaji, imgurl, totaleps) {
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
        addTodb(animeid, episode, status, rating, malid, romaji, imgurl, totaleps);

        Navigator.of(context, rootNavigator: true).pop();

        textController.text = "";
        _dropDownStatus = null;
        _dropDownRating = null;
        rating = null;
      }
    }
  }

  addTodb(animeid, episode, status, rating, malid, romaji, imgurl, totaleps) async {
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
    var r = await Requests.post(requestURrl.getApiURL+'/addanime', json: json);
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
        
        textController.text = "";
        _dropDownStatus = null;
        rating = null;
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
  }

  deletedb(listid) async {
    var json = {'listid': listid, 'uid': 0};
    var r = await Requests.post(requestURrl.getApiURL+'/deleteanimelist', json: json);
    r.raiseForStatus();
    String rs1 = r.content();
  }

  checkMyList(context, animeData) async {
    _loading = true;
    var r = await Requests.get(requestURrl.getApiURL+'/getanimelist');
    r.raiseForStatus();
    String rs1 = r.content();
    int listid;
    // if (this.mounted) {
    //   this.setState(() {
    var resp = jsonDecode(rs1);
    for (var str in resp) {
      if(animeData['id'] == str['anilistid']){
        listid = str['listid'];
        textController.text = str['episode'].toString(); //after add anime
        _dropDownStatus = str['status'];
        _dropDownRating = str['rating'].toString();
        setState(() {
          _loading = false;
        });
        return _showEditDialog(context, animeData, listid);
      }
    }
    //   });
    // }
    textController.text = ""; //after add anime
    _dropDownStatus = null;
    _dropDownRating = null;
    setState(() {
      _loading = false;
    });
    _showDialog(context, animeData);
  }

  void runLoading() {
    setState(() {
      _loading = true;
    });
    Timer(Duration(milliseconds: 500), () {
      setState(() {
        _loading = false;
      });
    });
  }

  Future _showDialog(context, animeData) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(animeData['title']['romaji']),
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
                            if(_dropDownStatus == 'Completed' && animeData['episodes'] != null){
                              textController.text = animeData['episodes'].toString();
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
                              if(animeData[2] == null){

                              }
                              else if(int.parse(textController.text) > animeData['episodes'] || _dropDownStatus == 'Completed'){
                                textController.text = animeData['episodes'].toString();
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
              onPressed: () async{
                var anilist = await queryId(animeData['id']);
                addAnime(anilist['id'], textController.text, _dropDownStatus, _dropDownRating, anilist['malid'], anilist['title']['romaji'], anilist['coverImage']['extraLarge'], anilist['episode']);
              },
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
          title: Text(animeData['title']['romaji']),
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
                            if(_dropDownStatus == 'Completed' && animeData['episodes'] != null){
                              textController.text = animeData['episodes'].toString();
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
                        if(animeData[2] == null){

                        }
                        else if(int.parse(textController.text) > animeData['episodes'] || _dropDownStatus == 'Completed'){
                          textController.text = animeData['episodes'].toString();
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
                editList(animeData['id'], listid, _dropDownStatus, textController.text, _dropDownRating, animeData['episodes']);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("Edit"),
            ),
          ],
        );
      },
    );
  }

  yearGenerator(){
    yearList = new List();
    int year = DateTime.now().year + 2;
    int minYear = 1990;
    for(int i = 0; year - i >= minYear;i++){
      yearList.add((year - i).toString());
    }
  }

  List yearList = new List();

  String _dropdownStreamingService;
  String _dropDownType;
  String _dropDownSeasonRelease;
  String _dropDownYearRelease;
  String _dropDownLicensor;
  String _dropDownstreamingService;
  int _dropDownTypeIndex;
  int _dropDownAiringStatusIndex;
  int _dropDownSeasonReleaseIndex;
  int _dropDownstreamingServiceIndex;
  List streamingServiceView = ['Muse Thailand (Youtube)', 'Ani-One Asia (Youtube)', 'BiliBili', 'AIS Play', 'FLIXER', 'iQiyi', 'Netflix', 'WeTV', 'TrueID', 'Viu', 'POPS', 'LINE TV', 'Amazon', 'iflix'];
  List formatView = ['TV', 'TV Short', 'Movie', 'Special', 'OVA', 'ONA'];
  List statusView = ['Finished', 'Airing', 'Not yet release'];
  List seasonView = ['Winter', 'Spring', 'Summer', 'Fall'];

  Future _filterDialog(context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filter anime"),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Licensor', textAlign: TextAlign.left),
                    DropdownButton(
                      value: _dropDownLicensor,
                      hint: Text('Licensor'),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: ['Muse Thailand', 'DEX', 'Aniplus Asia', 'Ani-One Asia'].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(() {
                            _dropDownLicensor = val;
                          },
                        );
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text('Streaming service', textAlign: TextAlign.left),
                    DropdownButton(
                      value: _dropDownstreamingService,
                      hint: Text('Streaming service'),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: streamingServiceView.map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(() {
                            _dropDownstreamingService = val;
                            _dropDownstreamingServiceIndex = streamingServiceView.indexOf(val);
                          },
                        );
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text('Type', textAlign: TextAlign.left),
                    DropdownButton(
                      value: _dropDownType,
                      hint: Text('Type'),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: formatView.map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(() {
                            _dropDownType = val;
                            _dropDownTypeIndex = formatView.indexOf(val);
                          },
                        );
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text('Seasons release', textAlign: TextAlign.left),
                    DropdownButton(
                      value: _dropDownSeasonRelease,
                      hint: Text('Seasons release'),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: seasonView.map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(() {
                            _dropDownSeasonRelease = val;
                            _dropDownSeasonReleaseIndex = seasonView.indexOf(val);
                            if(_dropDownYearRelease == null) _dropDownYearRelease = DateTime.now().year.toString();
                          },
                        );
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text('Year release', textAlign: TextAlign.left),
                    DropdownButton(
                      value: _dropDownYearRelease,
                      hint: Text('Year release'),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: yearList.map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(() {
                            _dropDownYearRelease = val;
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
                _dropDownLicensor = null;
                _dropDownType = null;
                _dropDownSeasonRelease = null;
                _dropDownYearRelease = null;
                _dropDownTypeIndex = null;
                _dropDownAiringStatusIndex = null;
                _dropDownSeasonReleaseIndex = null;
                _dropDownstreamingService = null;
                currentFilter = [null, null, null, null, null];
                getLcAnime();
                Navigator.of(context, rootNavigator: true).pop();
                _filterDialog(context);
              },
              child: Text("Reset"),
            ),
            new ElevatedButton(
              onPressed: () {
                this.setState(() {
                  //currentFilter = [null, null, null, null, null];
                  if(_dropDownLicensor == null && _dropDownstreamingServiceIndex == null && _dropDownSeasonRelease == null && _dropDownYearRelease == null && _dropDownType == null)
                    getLcAnime();
                  else
                    filterLcAnime(_dropDownLicensor, _dropDownstreamingServiceIndex, _dropDownSeasonRelease, _dropDownYearRelease, _dropDownType);
                  Navigator.of(context, rootNavigator: true).pop();
                  }
                );
              },
              child: Text("Apply"),
            ),
          ],
        );
      },
    );
  }
  Future<void> _pullRefresh() async {
    setState(() {
      lcAnimeList = new List();
      switch (queryState){
        case "initData":
          getLcAnime();
          break;
        
        case "queryData":
          searchLcAnime();
          break;

        case "filterData":
          filterLcAnime(_dropDownLicensor, _dropDownstreamingServiceIndex, _dropDownSeasonRelease, _dropDownYearRelease, _dropDownType);
          break;
      }
    });
  }
  String _dropDownStatus;
  String _dropDownRating;
  final textController = TextEditingController();
  ScrollController scrollController;
  int amountListView = 20;
  List status = ['Watching', 'Completed', 'Considering', 'Dropped'];
  List rating = ['10', '9', '8', '7', '6', '5', '4', '3', '2', '1'];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: _isSearching ? BackButton(onPressed: () => Navigator.of(context, rootNavigator: false).pop()): null,
          title: _isSearching ? _buildSearchField() : Text('Licensed anime in Thailand'),
          actions: _buildActions(),
        ),
        body: Stack(
          children: <Widget>[
            RefreshIndicator(
            color: Colors.blue,
            onRefresh: _pullRefresh,
            child: 
              new ListView.builder(
                controller: scrollController,
                itemCount: lcAnimeList.isEmpty ? 0 : amountListView,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 150,
                    child: Card(
                      child: InkWell(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 29,
                              child: //Image.network(lcAnimeList[index]['imgurl']),
                              FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: lcAnimeList[index]['imgurl'],
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
                                    alignment: Alignment.topLeft,
                                    child: ReadMoreText(
                                      lcAnimeList[index]['romaji'] ,
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
                                    alignment: Alignment.topLeft,
                                    child: new Text("Type: "+lcAnimeList[index]['format'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          //fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.left),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: new Text(lcAnimeList[index]['licensor'] == 0?
                                    "Licensor: -"
                                    :
                                    "Licensor: "+lcAnimeList[index]['licensor'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          //fontSize: 16,
                                          color: Colors.black,
                                        ),
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
                                      onSelected: (item) async {
                                        switch (item) {
                                          case 0:
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => AnimeDetail(lcAnimeList[index]['anilistid'])),
                                            );
                                            break;

                                          case 1:
                                            var anilist = await queryId(lcAnimeList[index]['anilistid']);
                                            checkMyList(context, anilist);
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AnimeDetail(lcAnimeList[index]['anilistid'])),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            _loading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue)),
                  ))
                : Container(), //if isLoading flag is true it'll display the progress indicator
          ],
        ),
      ),
      );
  }
}
