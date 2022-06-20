import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx_app/profileScreen.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'HomeScreen.dart';
import 'imageSliderScreen.dart';

class SearchProduct extends StatefulWidget {
  @override
  _SearchProductState createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {

  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "";

  FirebaseAuth auth= FirebaseAuth.instance;
  QuerySnapshot items;

  Widget _buildSearchField(){
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search here...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }


  List<Widget> _buildActions(){
    if(_isSearching){
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
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
    ];
  }

  _startSearch(){
    ModalRoute.of(context).addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching = true;
    });
  }

  updateSearchQuery(String newQuery){
    setState(() {
      getResults();
      searchQuery = newQuery;
    });
  }

  _stopSearching(){
    _clearSearchQuery();
    setState(() {
      _isSearching = false;
    });
  }

  _clearSearchQuery(){
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  _buildTitle(BuildContext context){
    return Text("Search Product");
  }

  _buildBackButton(){
    return IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: (){
          Route newRoute = MaterialPageRoute(builder: (_) => HomeScreen());
          Navigator.pushReplacement(context, newRoute);
        }
    );
  }

  getResults(){
    FirebaseFirestore.instance.collection('items').where("itemModel", isGreaterThanOrEqualTo: _searchQueryController.text.trim()).where("status", isEqualTo: "approved")
        .get()
        .then((results){
      setState(() {
        items = results;
      });
    });
  }




  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery
        .of(context)
        .size
        .width,
        _screenHeight = MediaQuery
            .of(context)
            .size
            .height;

    Widget showItemsList(){
      if(items != null){
        return ListView.builder(
          itemCount: items.docs.length,
          padding: EdgeInsets.all(8.0),
          itemBuilder: (context, i){
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: GestureDetector(
                        onTap: (){
                          Route newRoute = MaterialPageRoute(builder: (_) => ProfileScreen(sellerId: items.docs[i].get('uId'),));
                          Navigator.pushReplacement(context, newRoute);
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage(items.docs[i].get('imgPro'),),
                                fit: BoxFit.fill
                            ),
                          ),
                        ),
                      ),
                      title: GestureDetector(
                          onTap: (){
                            Route newRoute = MaterialPageRoute(builder: (_) => ProfileScreen(sellerId: items.docs[i].get('uId'),));
                            Navigator.pushReplacement(context, newRoute);
                          },
                          child: Text(items.docs[i].get('userName'))
                      ),
                    ),
                  ),
                  GestureDetector(
                    onDoubleTap: (){
                      Route newRoute = MaterialPageRoute(builder: (_) => ImageSliderScreen(
                        title: items.docs[i].get('itemModel'),
                        itemColor: items.docs[i].get('itemColor'),
                        userNumber:  items.docs[i].get('userNumber'),
                        description: items.docs[i].get('description'),
                        lat:  items.docs[i].get('lat'),
                        lng: items.docs[i].get('lng'),
                        address: items.docs[i].get('address'),
                        urlImage1: items.docs[i].get('urlImage1'),
                        urlImage2: items.docs[i].get('urlImage2'),
                        urlImage3: items.docs[i].get('urlImage3'),
                        urlImage4: items.docs[i].get('urlImage4'),
                        urlImage5: items.docs[i].get('urlImage5'),
                      ));
                      Navigator.pushReplacement(context, newRoute);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.network(items.docs[i].get('urlImage1'), fit: BoxFit.fill,),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      '\$ '+items.docs[i].get('itemPrice'),
                      style: TextStyle(
                        fontFamily: "Bebas",
                        letterSpacing: 2.0,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.image_sharp),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Align(
                                child: Text(items.docs[i].get('itemModel')),
                                alignment: Alignment.topLeft,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.watch_later_outlined),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Align(
                                child: Text(tAgo.format((items.docs[i].get('time')).toDate())),
                                alignment: Alignment.topLeft,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0,),
                ],
              ),
            );
          },
        );
      }
      else{
        return Text('Loading...');
      }
    }


    return Scaffold(
      appBar: AppBar(
        leading: _isSearching ? const BackButton() : _buildBackButton(),
        title: _isSearching ? _buildSearchField() : _buildTitle(context),
        actions: _buildActions(),
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  Colors.blueAccent,
                  Colors.redAccent,
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: _screenWidth,
          child: showItemsList(),
        ),
      ),
    );
  }
}
















