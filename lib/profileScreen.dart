import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx_app/globalVar.dart';
import 'package:timeago/timeago.dart' as tAgo;

import 'HomeScreen.dart';
import 'imageSliderScreen.dart';

class ProfileScreen extends StatefulWidget {
  String sellerId;
  ProfileScreen({this.sellerId});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  FirebaseAuth auth = FirebaseAuth.instance;
  String userName;
  String userNumber;
  String itemPrice;
  String itemModel;
  String itemColor;
  String description;
  QuerySnapshot items;


  Future<bool> showDialogForUpdateData(selectedDoc) async{
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return SingleChildScrollView(
            child: AlertDialog(
              title: Text("Update   Data", style: TextStyle(fontSize: 24, fontFamily: "Bebas", letterSpacing: 2.0),),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter Your Name',
                    ),
                    onChanged: (value){
                      setState(() {
                        this.userName = value;
                      });
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter Your Phone Number',
                    ),
                    onChanged: (value) {
                      setState(() {
                        this.userNumber = value;
                      });
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter Item Price',
                    ),
                    onChanged: (value) {
                      setState(() {
                        this.itemPrice = value;
                      });
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter Item Name',
                    ),
                    onChanged: (value) {
                      setState(() {
                        this.itemModel = value;
                      });
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter Item Color',
                    ),
                    onChanged: (value) {
                      setState(() {
                        this.itemColor = value;
                      });
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Write Item Description',
                    ),
                    onChanged: (value) {
                      setState(() {
                        this.description = value;
                      });
                    },
                  ),
                  SizedBox(height: 5.0),
                ],
              ),
              actions: [
                ElevatedButton(
                  child: Text(
                    "Cancel",
                  ),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  child: Text(
                    "Update Now",
                  ),
                  onPressed: () {
                    Navigator.pop(context);

                    Map<String, dynamic> itemData = {
                      'userName': this.userName,
                      'userNumber': this.userNumber,
                      'itemPrice': this.itemPrice,
                      'itemModel': this.itemModel,
                      'itemColor': this.itemColor,
                      'description': this.description,
                    };

                    FirebaseFirestore.instance.collection('items').doc(selectedDoc).update(itemData).then((value) {
                      print("Data updated successfully.");
                    }).catchError((onError){
                      print(onError);
                    });
                  },
                ),
              ],
            ),
          );
        }
    );
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

  _buildUserImage(){
    return Container(
      width: 50,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: NetworkImage(adUserImageUrl,),
            fit: BoxFit.fill
        ),
      ),
    );
  }

  getResults(){
    FirebaseFirestore.instance.collection('items').where("uId", isEqualTo: widget.sellerId).where("status", isEqualTo: "approved")
        .get().then((results){
      setState(() {
        items = results;
        adUserName = items.docs[0].get('userName');
        adUserImageUrl = items.docs[0].get('imgPro');
      });
    });
  }

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
                        },
                        child: Text(items.docs[i].get('userName'))
                    ),
                    trailing: items.docs[i].get('uId') == userId ?
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: (){
                            if(items.docs[i].get("uId") == userId){
                              showDialogForUpdateData(items.docs[i].id);
                            }
                          },
                          child: Icon(Icons.edit_outlined,),
                        ),
                        SizedBox(width: 20,),
                        GestureDetector(
                            onDoubleTap: (){
                              if(items.docs[i].get('uId') == userId){
                                FirebaseFirestore.instance.collection('items').doc(items.docs[i].id).delete();
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext c) => HomeScreen()));
                              }
                            },
                            child: Icon(Icons.delete_forever_sharp)
                        ),
                      ],
                    ):Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [],
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getResults();
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

    return Scaffold(
      appBar: AppBar(
        leading: _buildBackButton(),
        title: Row(
          children: [
            _buildUserImage(),
            SizedBox(width: 10,),
            Text(adUserName),
          ],
        ),
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  Colors.deepPurple[300],
                  Colors.deepPurple,
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp
            ),
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






















