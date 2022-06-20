import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:olx_app/DialogBox/loadingDialog.dart';
import 'package:olx_app/globalVar.dart';
import 'package:toast/toast.dart';
import 'package:path/path.dart' as Path;

import 'HomeScreen.dart';

class UploadAdScreen extends StatefulWidget {
  @override
  _UploadAdScreenState createState() => _UploadAdScreenState();
}

class _UploadAdScreenState extends State<UploadAdScreen> {

  bool uploading = false, next = false;
  double val = 0;
  CollectionReference imgRef;
  firebase_storage.Reference ref;
  String imgFile="", imgFile1="", imgFile2="", imgFile3="", imgFile4="", imgFile5="";

  List<File> _image = [];
  List<String> urlsList = [];
  final picker = ImagePicker();


  FirebaseAuth auth = FirebaseAuth.instance;
  String userName="";
  String userNumber="";
  String itemPrice="";
  String itemModel="";
  String itemColor="";
  String description="";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          next ? "Please write Items's Info" : 'Choose Item Images',
          style: TextStyle(fontSize: 18.0, fontFamily: "Lobster", letterSpacing: 2.0),
        ),
        actions: [
          next ? Container() :
          ElevatedButton(
            onPressed: (){
              if(_image.length == 5){
                setState(() {
                  uploading = true;
                  next = true;
                });
              }
              else{
                showToast(
                  "Please select 5 images only....",
                  duration: 2,
                  gravity: Toast.CENTER,
                );
              }
            },
            child: Text(
              'Next',
              style: TextStyle(fontSize: 18.0, color: Colors.white, fontFamily: "Varela"),
            ),
          ),
        ],
      ),

      body: next ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(hintText: 'Enter Your Name'),
                onChanged: (value) {
                  this.userName = value;
                },
              ),
              SizedBox(height: 5.0),
              TextField(
                decoration: InputDecoration(hintText: 'Enter Your Phone Number'),
                onChanged: (value) {
                  this.userNumber = value;
                },
              ),
              SizedBox(height: 5.0),
              TextField(
                decoration: InputDecoration(hintText: 'Enter Item Price'),
                onChanged: (value) {
                  this.itemPrice = value;
                },
              ),
              SizedBox(height: 5.0),
              TextField(
                decoration: InputDecoration(hintText: 'Enter Item Name'),
                onChanged: (value) {
                  this.itemModel = value;
                },
              ),
              SizedBox(height: 5.0),
              TextField(
                decoration: InputDecoration(hintText: 'Enter Item Color'),
                onChanged: (value) {
                  this.itemColor = value;
                },
              ),
              SizedBox(height: 5.0),
              TextField(
                decoration: InputDecoration(hintText: "Write some Item's Description"),
                onChanged: (value) {
                  this.description = value;
                },
              ),
              SizedBox(height: 10.0),
              Container(
                width: MediaQuery.of(context).size.width*0.5,
                child: ElevatedButton(
                  onPressed: (){
                    showDialog(context: context, builder: (con){
                      return LoadingAlertDialog(
                        message: 'Uploading...',
                      );
                    });

                    uploadFile().whenComplete((){
                      Map<String, dynamic> adData ={
                        'userName' : this.userName,
                        'uId' : auth.currentUser.uid,
                        'userNumber': this.userNumber,
                        'itemPrice': this.itemPrice,
                        'itemModel': this.itemModel,
                        'itemColor': this.itemColor,
                        'description': this.description,
                        'urlImage1': urlsList[0].toString(),
                        'urlImage2': urlsList[1].toString(),
                        'urlImage3': urlsList[2].toString(),
                        'urlImage4': urlsList[3].toString(),
                        'urlImage5': urlsList[4].toString(),
                        'imgPro': userImageUrl,
                        'lat': position.latitude,
                        'lng': position.longitude,
                        'address': completeAddress,
                        'time': DateTime.now(),
                        'status': "not approved",
                      };
                      FirebaseFirestore.instance.collection('items').add(adData).then((value){
                        print("Data added successfully.");
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                      }).catchError((onError){
                        print(onError);
                      });
                    });
                  },

                  child: Text('Upload', style: TextStyle(color: Colors.white),),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ) : Stack(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            child: GridView.builder(
                itemCount: _image.length + 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3
                ),
                itemBuilder: (context, index){
                  return index == 0
                      ? Center(
                    child: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () =>
                        !uploading ? chooseImage() : null),
                  ) : Container(
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(_image[index - 1]),
                          fit: BoxFit.cover
                      ),
                    ),
                  );
                }),
          ),
          uploading ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: Text(
                    'uploading...',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                CircularProgressIndicator(
                  value: val,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                )
              ],
            ),
          )
              : Container(),
        ],
      ),






    );
  }

  chooseImage() async{
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile?.path));
    });
    if (pickedFile.path == null) retrieveLostData();
  }

  Future<void> retrieveLostData() async{
    final LostData response = await picker.getLostData();
    if(response.isEmpty){
      return;
    }
    if (response.file != null){
      setState(() {
        _image.add(File(response.file.path));
      });
    }else{
      print(response.file);
    }
  }


  Future uploadFile() async{
    int i = 1;

    for(var img in _image){
      setState(() {
        val = i / _image.length;
      });
      ref = firebase_storage.FirebaseStorage.instance.ref().child('image/${Path.basename(img.path)}');

      await ref.putFile(img).whenComplete(() async{
        await ref.getDownloadURL().then((value){
          urlsList.add(value);
          i++;
        });
      });


    }
  }



  void showToast(String msg, {int duration, int gravity}){
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imgRef = FirebaseFirestore.instance.collection('imageUrls');
  }
}








