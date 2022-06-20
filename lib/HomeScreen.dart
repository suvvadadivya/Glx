import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:olx_app/SearchProduct.dart';
import 'package:olx_app/globalVar.dart';
import 'package:olx_app/imageSliderScreen.dart';
import 'package:olx_app/profileScreen.dart';
import 'package:olx_app/uploadAdScreen.dart';
import 'Welcome/welcome_screen.dart';
import 'package:timeago/timeago.dart' as tAgo;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  FirebaseAuth auth = FirebaseAuth.instance;

  QuerySnapshot items;

  Future<bool> showDialogForUpdateData(selectedDoc, oldUserName, oldPhoneNumber, oldItemPrice, oldItemName, oldItemColor, oldItemDescription) async{
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
                    initialValue: oldUserName,
                    decoration: InputDecoration(
                      hintText: 'Enter Your Name',
                    ),
                    onChanged: (value){
                      setState(() {
                        oldUserName = value;
                      });
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextFormField(
                    initialValue: oldPhoneNumber,
                    decoration: InputDecoration(
                      hintText: 'Enter Your Phone Number',
                    ),
                    onChanged: (value) {
                      setState(() {
                        oldPhoneNumber = value;
                      });
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextFormField(
                    initialValue: oldItemPrice,
                    decoration: InputDecoration(
                      hintText: 'Enter Item Price',
                    ),
                    onChanged: (value) {
                      setState(() {
                        oldItemPrice = value;
                      });
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextFormField(
                    initialValue: oldItemName,
                    decoration: InputDecoration(
                      hintText: 'Enter Item Name',
                    ),
                    onChanged: (value) {
                      setState(() {
                        oldItemName = value;
                      });
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextFormField(
                    initialValue: oldItemColor,
                    decoration: InputDecoration(
                      hintText: 'Enter Item Color',
                    ),
                    onChanged: (value) {
                      setState(() {
                        oldItemColor = value;
                      });
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextFormField(
                    initialValue: oldItemDescription,
                    decoration: InputDecoration(
                      hintText: 'Write Item Description',
                    ),
                    onChanged: (value) {
                      setState(() {
                        oldItemDescription = value;
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
                      'userName': oldUserName,
                      'userNumber': oldPhoneNumber,
                      'itemPrice': oldItemPrice,
                      'itemModel': oldItemName,
                      'itemColor': oldItemColor,
                      'description': oldItemDescription,
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

  getMyData(){
    FirebaseFirestore.instance.collection('users').doc(userId).get().then((results) {
      setState(() {
        userImageUrl = results.data()['imgPro'];
        getUserName = results.data()['userName'];
      });
    });
  }

  getUserAddress() async{
    Position newPostiton = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    position = newPostiton;

    placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark placemark = placemarks[0];

    String newCompleteAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, '
        '${placemark.subThoroughfare} ${placemark.locality},  '
        '${placemark.subAdministrativeArea}, '
        '${placemark.administrativeArea} ${placemark.postalCode}, '
        '${placemark.country}'
    ;
    completeAddress = newCompleteAddress;
    print(completeAddress);

    return completeAddress;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserAddress();

    userId = FirebaseAuth.instance.currentUser.uid;
    userEmail = FirebaseAuth.instance.currentUser.email;

    FirebaseFirestore.instance.collection('items')
        .where("status", isEqualTo: "approved")
        .orderBy("time", descending: true)
        .get().then((results) {
      setState(() {
        items = results;
      });
    });

    getMyData();

  }



  @override
  Widget build(BuildContext context) {

    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

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
                      trailing: items.docs[i].get('uId') == userId ?
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: (){
                              if(items.docs[i].get('uId') == userId){
                                showDialogForUpdateData(
                                  items.docs[i].id,
                                  items.docs[i].get('userName'),
                                  items.docs[i].get('userNumber'),
                                  items.docs[i].get('itemPrice'),
                                  items.docs[i].get('itemModel'),
                                  items.docs[i].get('itemColor'),
                                  items.docs[i].get('description'),
                                );
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.refresh, color: Colors.white),
          onPressed: (){
            Route newRoute = MaterialPageRoute(builder: (_) => HomeScreen());
            Navigator.pushReplacement(context, newRoute);
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: (){
              Route newRoute = MaterialPageRoute(builder: (_) => ProfileScreen(sellerId: userId));
              print(userId);
              print("  this is id  ");
              print(userId);
              Navigator.pushReplacement(context, newRoute);
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: (){
              Route newRoute = MaterialPageRoute(builder: (_) => SearchProduct());
              Navigator.pushReplacement(context, newRoute);
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(Icons.search, color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: (){
              auth.signOut().then((_){
                Route newRoute = MaterialPageRoute(builder: (_) => WelcomeScreen());
                Navigator.pushReplacement(context, newRoute);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(Icons.login_outlined, color: Colors.white),
            ),
          ),
        ],
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
        title: Text("Home Page"),
        centerTitle: false,
      ),
      body: Center(
        child: Container(
          width: _screenWidth,
          child: showItemsList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Post',
        child: Icon(Icons.add),
        onPressed: (){
          Route newRoute = MaterialPageRoute(builder: (_) => UploadAdScreen());
          Navigator.pushReplacement(context, newRoute);
        },
      ),
    );
  }
}
