import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:requests/requests.dart';
import 'animedetail.dart';

class Add extends StatefulWidget {
  static const routeName = '/add';

  @override
  State<StatefulWidget> createState() {
    return _AddState();
  }
}

class _AddState extends State<Add> {
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";
  TabController controller;
  bool _loading = false;
  var searchList = {};
  List animeList = new List();
  var mediaformat = ['TV', 'TV_SHORT', 'MOVIE', 'SPECIAL', 'OVA', 'ONA'];
  List mediaStatus = ['FINISHED', 'RELEASING', 'NOT_YET_RELEASED'];
  List mediaSeson = ['WINTER', 'SPRING', 'SUMMER', 'FALL'];
  int fetchPage;
  String queryState = "initdata";

  List currentFilter;
  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
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
              //Navigator.of(context, rootNavigator: true).pop();
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
          // _dropDownAiringStatus = null;
          // _dropDownType = null;
          // _dropDownSeasonRelease = null;
          // _dropDownYearRelease = null;
          // _dropDownTypeIndex = null;
          // _dropDownAiringStatusIndex = null;
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
      queryData();
      debugPrint('updateSearchQuery');
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
      queryState = "initdata";
      initData();
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

  initData() async {
    fetchPage = 1;
    queryState = "initData";
    currentFilter = [null, null, thisSeason(DateTime.now()), DateTime.now().year] ;
    _loading = true;
    animeList = new List();
    final url = Uri.parse('https://graphql.anilist.co');
    Map<String, String> headers = {"Content-type": "application/json"};
      Map variables = {
        'season': thisSeason(DateTime.now()),
        'seasonYear': DateTime.now().year,
        'page': 1,
        'perPage': 20,
        'isAdult': false,
        'countryOfOrigin': 'JP',
        'format_in': mediaformat
      };
      //print(variables.toString());
      String query =
          '''query (\$id: Int, \$page: Int, \$perPage: Int, \$season: MediaSeason, \$seasonYear:Int, \$isAdult:Boolean, \$countryOfOrigin:CountryCode, \$format_in:[MediaFormat]) {
                    Page (page: \$page, perPage: \$perPage) {
                        pageInfo {
                            total
                            currentPage
                            lastPage
                            hasNextPage
                            perPage
                        }
                        media (id: \$id, season: \$season, seasonYear:\$seasonYear, isAdult:\$isAdult, countryOfOrigin:\$countryOfOrigin, format_in:\$format_in, type: ANIME) {
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
                            countryOfOrigin
                        }
                    }
                }''';
      var json = {'query': query, 'variables': variables};
      debugPrint(jsonEncode(json));
      // make POST request
      var client = http.Client();
      var response =
          await client.post(url, headers: headers, body: jsonEncode(json));
      // check the status code for the result
      if (this.mounted) {
        this.setState(() {
          searchList = jsonDecode(response.body);
          var media = searchList['data']['Page']['media'];
          for (var str in media) {

              animeList.add([
                str['id'],
                str['title']['romaji'],
                str['episodes'],
                str['idMal'],
                str['coverImage']['extraLarge']
              ]);
            
          }
        });
      }
      // searchList = jsonDecode(response.body);
      // List<String> anime = new List();
      // print(page.toString());
      // page = 1;
      client.close();
    

    // for (String i in animeList){
    //   debugPrint(i);

    // }
    // for(int i=0; i<animeList.length; i++){
    //   print(animeList[i][0]);
    //   print(animeList[i][1]);
    // }
    if (animeList.length < 20) {
      amountListView = animeList.length;
    } else {
      amountListView = 20;
    }
    _loading = false;
  }

  nextInitData(page) async {
    currentFilter = [null, null, thisSeason(DateTime.now()), DateTime.now().year];
    _loading = true;
    final url = Uri.parse('https://graphql.anilist.co');
    Map<String, String> headers = {"Content-type": "application/json"};
      Map variables = {
        'season': currentFilter[2],
        'seasonYear':currentFilter[3],
        'page': page,
        'perPage': 20,
        'isAdult': false,
        'countryOfOrigin': 'JP',
        'format_in': mediaformat
      };
      //print(variables.toString());
      String query =
          '''query (\$id: Int, \$page: Int, \$perPage: Int, \$season: MediaSeason, \$seasonYear:Int, \$isAdult:Boolean, \$countryOfOrigin:CountryCode, \$format_in:[MediaFormat]) {
                    Page (page: \$page, perPage: \$perPage) {
                        pageInfo {
                            total
                            currentPage
                            lastPage
                            hasNextPage
                            perPage
                        }
                        media (id: \$id, season: \$season, seasonYear:\$seasonYear, isAdult:\$isAdult, countryOfOrigin:\$countryOfOrigin, format_in:\$format_in, type: ANIME) {
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
                            countryOfOrigin
                        }
                    }
                }''';
      var json = {'query': query, 'variables': variables};
      debugPrint(jsonEncode(json));
      // make POST request
      var client = http.Client();
      var response =
          await client.post(url, headers: headers, body: jsonEncode(json));
      // check the status code for the result
      if (this.mounted) {
        this.setState(() {
          searchList = jsonDecode(response.body);
          var media = searchList['data']['Page']['media'];
          for (var str in media) {

              animeList.add([
                str['id'],
                str['title']['romaji'],
                str['episodes'],
                str['idMal'],
                str['coverImage']['extraLarge']
              ]);
            
          }
          page = searchList['data']['Page']['pageInfo']['lastPage'];
        });
      }
      // searchList = jsonDecode(response.body);
      // List<String> anime = new List();
      // print(page.toString());
      // page = 1;
      client.close();

    // for (String i in animeList){
    //   debugPrint(i);

    // }
    // for(int i=0; i<animeList.length; i++){
    //   print(animeList[i][0]);
    //   print(animeList[i][1]);
    // }
    setState(() {
      // if (animeList.length < 20) {
      //   amountListView = amountListView + animeList.length;
      // } else {
      //   amountListView = amountListView + 20;
      // }
      amountListView = animeList.length;
    });
    _loading = false;
  }

  queryData() async {
    queryState = "queryData";
    fetchPage = 1;
    _loading = true;
    //print("querydata--------------");
    animeList = new List();
    final url = Uri.parse('https://graphql.anilist.co');
    Map<String, String> headers = {"Content-type": "application/json"};
      Map variables = {
        'search': searchQuery,
        'page': fetchPage,
        'perPage': 20,
        'isAdult': false,
        'countryOfOrigin': 'JP',
        'format_in': mediaformat
      };
      String query =
          '''query (\$page: Int, \$perPage: Int, \$search: String, \$isAdult:Boolean, \$countryOfOrigin:CountryCode, \$format_in:[MediaFormat]) {
                    Page (page: \$page, perPage: \$perPage) {
                        pageInfo {
                            total
                            currentPage
                            lastPage
                            hasNextPage
                            perPage
                        }
                        media (search:\$search, isAdult:\$isAdult, countryOfOrigin:\$countryOfOrigin, format_in:\$format_in, type: ANIME) {
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
                        }
                    }
                }''';
      var json = {'query': query, 'variables': variables};
      //debugPrint(jsonEncode(json));
      var client = http.Client();
      // make POST request
      var response =
          await client.post(url, headers: headers, body: jsonEncode(json));
      // check the status code for the result
      if (this.mounted) {
        this.setState(() {
          searchList = jsonDecode(response.body);
          //print(searchList);
          if (searchList['data'] != null) {
            var media = searchList['data']['Page']['media'];
            for (var str in media) {
              //debugPrint(str['title']['romaji']);
              if (mediaformat.contains(str['format'])) {
                animeList.add([
                  str['id'],
                  str['title']['romaji'],
                  str['episodes'],
                  str['idMal'],
                  str['coverImage']['extraLarge']
                ]);
              }
            }
          } else {
        }
      });
    }
    client.close();

    setState(() {
      // if (animeList.length < 20) {
      //   amountListView = amountListView + animeList.length;
      // } else {
      //   amountListView = amountListView + 20;
      // }
      amountListView = animeList.length;
    });
    _loading = false;
  }

  nextQueryData(page) async {
    _loading = true;
    //print("querydata--------------");
    final url = Uri.parse('https://graphql.anilist.co');
    Map<String, String> headers = {"Content-type": "application/json"};
      Map variables = {
        'search': searchQuery,
        'page': page,
        'perPage': 20,
        'isAdult': false,
        'countryOfOrigin': 'JP',
        'format_in': mediaformat
      };
      String query =
          '''query (\$page: Int, \$perPage: Int, \$search: String, \$isAdult:Boolean, \$countryOfOrigin:CountryCode, \$format_in:[MediaFormat]) {
                    Page (page: \$page, perPage: \$perPage) {
                        pageInfo {
                            total
                            currentPage
                            lastPage
                            hasNextPage
                            perPage
                        }
                        media (search:\$search, isAdult:\$isAdult, countryOfOrigin:\$countryOfOrigin, format_in:\$format_in type: ANIME) {
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
                        }
                    }
                }''';
      var json = {'query': query, 'variables': variables};
      //debugPrint(jsonEncode(json));
      var client = http.Client();
      // make POST request
      var response =
          await client.post(url, headers: headers, body: jsonEncode(json));
      // check the status code for the result
      if (this.mounted) {
        this.setState(() {
          searchList = jsonDecode(response.body);
          //print(searchList);
          if (searchList['data'] != null) {
            var media = searchList['data']['Page']['media'];
            for (var str in media) {
              //debugPrint(str['title']['romaji']);
              if (mediaformat.contains(str['format'])) {
                animeList.add([
                  str['id'],
                  str['title']['romaji'],
                  str['episodes'],
                  str['idMal'],
                  str['coverImage']['extraLarge']
                ]);
              }
            }
            page = searchList['data']['Page']['pageInfo']['lastPage'];
          } else {
            page = 1;
          }
        });
      }
      client.close();
      // searchList = jsonDecode(response.body);
      // List<String> anime = new List();
      // print(page.toString());
      // page = 1;


    // for (String i in animeList){
    //   debugPrint(i);

    // }
    // for(int i=0; i<animeList.length; i++){
    //   print(animeList[i][0]);
    //   print(animeList[i][1]);
    // }

    setState(() {
      // if (animeList.length < 20) {
      //   amountListView = amountListView + animeList.length;
      // } else {
      //   amountListView = amountListView + 20;
      // }
      amountListView = animeList.length;
    });
    _loading = false;
  }

  filterQueryData(statusIndex, typeIndex, seasonReleaseIndex, yearRelease) async {
    fetchPage = 1;
    queryState = "filterData";
    currentFilter = [statusIndex, typeIndex, seasonReleaseIndex, yearRelease];
    _loading = true;
    //print("querydata--------------");
    animeList = new List();
    final url = Uri.parse('https://graphql.anilist.co');
    Map<String, String> headers = {"Content-type": "application/json"};
      Map variables = {
        'page': fetchPage,
        'perPage': 20,
        'isAdult': false
      };
      String filterQueryStr = '''''';
      String filterMediaStr = '''''';
      if (statusIndex != null) {
        variables['status'] = mediaStatus[_dropDownAiringStatusIndex];
        filterQueryStr = filterQueryStr+''',\$status:MediaStatus''';
        filterMediaStr = filterMediaStr+''',status:\$status''';
      }
      if (typeIndex != null) {
        variables['format'] = mediaformat[typeIndex];
        filterQueryStr = filterQueryStr+''',\$format:MediaFormat''';
        filterMediaStr = filterMediaStr+''',format:\$format''';
      }
      else if(typeIndex == null){
        variables['format_in'] = mediaformat;
        filterQueryStr = filterQueryStr+''',\$format_in:[MediaFormat]''';
        filterMediaStr = filterMediaStr+''',format_in:\$format_in''';
      }
      if (_dropDownSeasonReleaseIndex != null) {
        variables['season'] = mediaSeson[_dropDownSeasonReleaseIndex];
        filterQueryStr = filterQueryStr+''',\$season:MediaSeason''';
        filterMediaStr = filterMediaStr+''',season:\$season''';
      }
      if (yearRelease != null) {
        variables['seasonYear'] = yearRelease;
        filterQueryStr = filterQueryStr+''',\$seasonYear:Int''';
        filterMediaStr = filterMediaStr+''',seasonYear:\$seasonYear''';
      }
      if(filterMediaStr.length == 0 || filterQueryStr.length == 0){
        return "You must select at least 1 filter";
      }
      String query =
          '''query (\$page: Int, \$perPage: Int, \$isAdult:Boolean '''+filterQueryStr+''') {
                    Page (page: \$page, perPage: \$perPage) {
                        pageInfo {
                            total
                            currentPage
                            lastPage
                            hasNextPage
                            perPage
                        }
                        media (isAdult:\$isAdult, type: ANIME'''+filterMediaStr+''') {
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
                        }
                    }
                }''';
      var json = {'query': query, 'variables': variables};
      //debugPrint(jsonEncode(json));
      var client = http.Client();
      // make POST request
      var response =
          await client.post(url, headers: headers, body: jsonEncode(json));
      // check the status code for the result
      if (this.mounted) {
        this.setState(() {
          searchList = jsonDecode(response.body);
          //print(searchList);
          if (searchList['data'] != null) {
            var media = searchList['data']['Page']['media'];
            for (var str in media) {
              //debugPrint(str['title']['romaji']);
              if (mediaformat.contains(str['format'])) {
                animeList.add([
                  str['id'],
                  str['title']['romaji'],
                  str['episodes'],
                  str['idMal'],
                  str['coverImage']['extraLarge']
                ]);
              }
            }
          } else {
          }
        });
      }
      client.close();
      // searchList = jsonDecode(response.body);
      // List<String> anime = new List();
      // print(page.toString());
      // page = 1;

    

    // for (String i in animeList){
    //   debugPrint(i);

    // }
    // for(int i=0; i<animeList.length; i++){
    //   print(animeList[i][0]);
    //   print(animeList[i][1]);
    // }
    if (animeList.length < 20) {
      amountListView = animeList.length;
    } else {
      amountListView = 20;
    }
    _loading = false;
  }

  nextFilterQueryData(statusIndex, typeIndex, seasonReleaseIndex, yearRelease, page) async {
    _loading = true;
    //print("querydata--------------");
    final url = Uri.parse('https://graphql.anilist.co');
    Map<String, String> headers = {"Content-type": "application/json"};

      Map variables = {
        'page': page,
        'perPage': 20,
        'isAdult': false
      };
      String filterQueryStr = '''''';
      String filterMediaStr = '''''';
      if (statusIndex != null) {
        variables['status'] = mediaStatus[_dropDownAiringStatusIndex];
        filterQueryStr = filterQueryStr+''',\$status:MediaStatus''';
        filterMediaStr = filterMediaStr+''',status:\$status''';
      }
      if (typeIndex != null) {
        variables['format'] = mediaformat[typeIndex];
        filterQueryStr = filterQueryStr+''',\$format:MediaFormat''';
        filterMediaStr = filterMediaStr+''',format:\$format''';
      }
      else if(typeIndex == null){
        variables['format_in'] = mediaformat;
        filterQueryStr = filterQueryStr+''',\$format_in:[MediaFormat]''';
        filterMediaStr = filterMediaStr+''',format_in:\$format_in''';
      }
      if (_dropDownSeasonReleaseIndex != null) {
        variables['season'] = mediaSeson[_dropDownSeasonReleaseIndex];
        filterQueryStr = filterQueryStr+''',\$season:MediaSeason''';
        filterMediaStr = filterMediaStr+''',season:\$season''';
      }
      if (yearRelease != null) {
        variables['seasonYear'] = yearRelease;
        filterQueryStr = filterQueryStr+''',\$seasonYear:Int''';
        filterMediaStr = filterMediaStr+''',seasonYear:\$seasonYear''';
      }
      if(filterMediaStr.length == 0 || filterQueryStr.length == 0){
        return "You must select at least 1 filter";
      }
      String query =
          '''query (\$page: Int, \$perPage: Int, \$isAdult:Boolean '''+filterQueryStr+''') {
                    Page (page: \$page, perPage: \$perPage) {
                        pageInfo {
                            total
                            currentPage
                            lastPage
                            hasNextPage
                            perPage
                        }
                        media (isAdult:\$isAdult, type: ANIME'''+filterMediaStr+''') {
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
                        }
                    }
                }''';
      var json = {'query': query, 'variables': variables};
      //debugPrint(jsonEncode(json));
      var client = http.Client();
      // make POST request
      var response =
          await client.post(url, headers: headers, body: jsonEncode(json));
      // check the status code for the result
      if (this.mounted) {
        this.setState(() {
          searchList = jsonDecode(response.body);
          //print(searchList);
          if (searchList['data'] != null) {
            var media = searchList['data']['Page']['media'];
            for (var str in media) {
              //debugPrint(str['title']['romaji']);
              if (mediaformat.contains(str['format'])) {
                animeList.add([
                  str['id'],
                  str['title']['romaji'],
                  str['episodes'],
                  str['idMal'],
                  str['coverImage']['extraLarge']
                ]);
              }
            }
            page = searchList['data']['Page']['pageInfo']['lastPage'];
          } else {
            page = 1;
          }
        });
      }
      client.close();
      // searchList = jsonDecode(response.body);
      // List<String> anime = new List();
      // print(page.toString());
      // page = 1;

    

    // for (String i in animeList){
    //   debugPrint(i);

    // }
    // for(int i=0; i<animeList.length; i++){
    //   print(animeList[i][0]);
    //   print(animeList[i][1]);
    // }

    setState(() {
      // if (animeList.length < 20) {
      //   amountListView = amountListView + animeList.length;
      // } else {
      //   amountListView = amountListView + 20;
      // }
      amountListView = animeList.length;
    });
    _loading = false;
  }

  dataList() {
    List<String> myList = List<String>(3);
    myList[0] = 'one';
    myList[1] = 'two';
    myList[2] = 'three';
    return myList;
  }

  searchData() {
    List<String> myList = dataList();
    List<String> searchList = new List();
    int found = 0;
    for (String str in myList) {
      if (str.contains(searchQuery)) {
        searchList.add(str);
        found++;
      }
    }
    // if (found <= 0){
    //   searchList.add("Not found");
    // }
    return searchList;
  }

  dataManager() {
    if (_isSearching) {
      queryData();
      return searchData();
    } else if (!_isSearching) {
      initData();
      return dataList();
    }
    initData();
    return dataList();
  }

  @override
  void initState() {
    super.initState();
    fetchPage = 1;
    yearGenerator();
    this.initData();
    scrollController = new ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    //print(scrollController.position.extentAfter);
    // if (scrollController.position.extentAfter < 500) {
    //   setState(() {
    //     animeList.addAll(new List.generate(42, (index) => 'Inserted $index'));
    //   });
    // }

    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      fetchPage++;        
      switch(queryState){
        case "initData":
          nextInitData(fetchPage);
          break;

        case "queryData":
          nextQueryData(fetchPage);
          break;

        case "filterData":
          nextFilterQueryData(currentFilter[0], currentFilter[1], currentFilter[2], currentFilter[3], fetchPage);
          break;

      }
      setState(() {
        // if (amountListView + 20 > animeList.length) {
        // } else if (amountListView + 20 > animeList.length) {
        //   runLoading();
        //   amountListView = amountListView + 20 - animeList.length;
        // } else {
        //   runLoading();
        //   amountListView = amountListView + 20;
        // }


      });
    }
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
          //debugPrint(str['title']['romaji']);
          if(animeData[0] == str['anilistid']){
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
          title: Text(animeData[1]),
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
                            if(_dropDownStatus == 'Completed' && animeData[2] != null){
                              textController.text = animeData[2].toString();
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
                              else if(int.parse(textController.text) > animeData[2] || _dropDownStatus == 'Completed'){
                                textController.text = animeData[2].toString();
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
              onPressed: () => addAnime(animeData[0], textController.text, _dropDownStatus, _dropDownRating, animeData[3], animeData[1], animeData[4], animeData[2]),
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
          title: Text(animeData[1]),
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
                            if(_dropDownStatus == 'Completed' && animeData[2] != null){
                              textController.text = animeData[2].toString();
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
                        else if(int.parse(textController.text) > animeData[2] || _dropDownStatus == 'Completed'){
                          textController.text = animeData[2].toString();
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
                updatedb(animeData[0], listid, _dropDownStatus, textController.text, _dropDownRating, animeData[2]);
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

  String _dropDownAiringStatus;
  String _dropDownType;
  String _dropDownSeasonRelease;
  String _dropDownYearRelease;
  int _dropDownTypeIndex;
  int _dropDownAiringStatusIndex;
  int _dropDownSeasonReleaseIndex;
  List formatView = ['TV', 'TV Short', 'Movie', 'Special', 'OVA', 'ONA'];
  List statusView = ['Finished', 'Airing', 'Not yet release'];
  List seasonView = ['Winter', 'Spring', 'Summer', 'Fall'];

  Future _filterDialog(context) async {
     _dropDownAiringStatus = null;
     _dropDownType = null;
     _dropDownSeasonRelease = null;
     _dropDownYearRelease = null;
     _dropDownTypeIndex = null;
     _dropDownAiringStatusIndex = null;
     _dropDownSeasonReleaseIndex = null;
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
                    Text('Airing status', textAlign: TextAlign.left),
                    DropdownButton(
                      value: _dropDownAiringStatus,
                      hint: Text('Airing status'),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: ['Finished', 'Airing', 'Not yet release'].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(() {
                            _dropDownAiringStatus = val;
                            _dropDownAiringStatusIndex = statusView.indexOf(val);
                            // if(_dropDownStatus == 'Completed' && animeList[index][2] != null){
                            //   textController.text = animeList[index][2].toString();
                            // }
                            // else if(_dropDownStatus == 'Considering'){
                            //   textController.text = "0";
                            // }
                            // else{
                            //   textController.text = "";
                            // }
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
                            // if(_dropDownStatus == 'Completed' && animeList[index][2] != null){
                            //   textController.text = animeList[index][2].toString();
                            // }
                            // else if(_dropDownStatus == 'Considering'){
                            //   textController.text = "0";
                            // }
                            // else{
                            //   textController.text = "";
                            // }
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
                      hint: Text('Airing status'),
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
                            // if(_dropDownStatus == 'Completed' && animeList[index][2] != null){
                            //   textController.text = animeList[index][2].toString();
                            // }
                            // else if(_dropDownStatus == 'Considering'){
                            //   textController.text = "0";
                            // }
                            // else{
                            //   textController.text = "";
                            // }
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
                      hint: Text('Airing status'),
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
                            // if(_dropDownStatus == 'Completed' && animeList[index][2] != null){
                            //   textController.text = animeList[index][2].toString();
                            // }
                            // else if(_dropDownStatus == 'Considering'){
                            //   textController.text = "0";
                            // }
                            // else{
                            //   textController.text = "";
                            // }
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
                initData();
                Navigator.of(context, rootNavigator: true).pop();
                _filterDialog(context);
              },
              child: Text("Reset"),
            ),
            new ElevatedButton(
              onPressed: () {
                filterQueryData(_dropDownAiringStatus, _dropDownTypeIndex, _dropDownSeasonReleaseIndex, _dropDownYearRelease);
                Navigator.of(context, rootNavigator: true).pop();
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
      animeList = new List();
      switch (queryState){
        case "initData":
          initData();
          break;
        
        case "queryData":
          queryData();
          break;

        case "filterData":
          filterQueryData(_dropDownAiringStatus, _dropDownTypeIndex, _dropDownSeasonReleaseIndex, _dropDownYearRelease);
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
    return Scaffold(
        appBar: AppBar(
          leading: _isSearching ? const BackButton() : null,
          title: _isSearching ? _buildSearchField() : Text('Add anime'),
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
                itemCount: animeList.length == 0 ? 0 : amountListView,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 150,
                    child: Card(
                      child: InkWell(
                        //color: Colors.orange,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 33,
                              child: Image.network(animeList[index][4]),
                            ),
                            Expanded(
                              flex: 66,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: 
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: new Text(animeList[index][1],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.left),
                                      ),
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
                                              MaterialPageRoute(builder: (context) => AnimeDetail(animeList[index][0])),
                                            );
                                            break;

                                          case 1:
                                            // textController.text = animeList[index][5].toString(); //after add anime
                                            // _dropDownStatus = animeList[index][4];
                                            // _dropDownRating = animeList[index][6].toString();
                                            checkMyList(context, animeList[index]);
                                            break;

                                          // case 2:
                                          //   //deletedb(myList[index][0]);
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
                          // print(animeList[index][0].toString());
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => AnimeDetail(animeList[index][0])),
                          // );
                          //_showDialog(context, index);
                          checkMyList(context, animeList[index]);
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
        )
      );
  }
}
