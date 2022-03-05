// ignore_for_file: file_names

import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';

class ChangeProfileScreen extends StatefulWidget {
  const ChangeProfileScreen({Key? key}) : super(key: key);

  @override
  _ChangeProfileScreenState createState() => _ChangeProfileScreenState();
}

class _ChangeProfileScreenState extends State<ChangeProfileScreen> {
  File? selectedImage;
  final fbStorage = FirebaseStorage.instance.ref().child('userProfile');
  final dbIns = FirebaseFirestore.instance.collection('users');
  bool isUpLoading = false;

  Future<void> selectPicture() async {
    PickedFile? im =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);

    if (im == null) {
      return;
    }
    setState(() {
      selectedImage = File(im.path);
    });
  }

  Future<void> updateInDb() async {
    if (selectedImage == null) {
      return;
    }
    setState(() {
      isUpLoading = true;
    });
    final fbUser = FirebaseAuth.instance.currentUser;

    final auth = Provider.of<Auth>(context, listen: false);
    final f = fbStorage.child(auth.currentUser!.id + '.jpg');
    final uploaded = await f.putFile(selectedImage!);
    String photoURL = await uploaded.ref.getDownloadURL();
    dbIns.doc(auth.currentUser!.id).update({'photoUrl': photoURL});
    if (fbUser != null) {
      fbUser.updatePhotoURL(photoURL);
    }
    DocumentSnapshot userInfo = await dbIns.doc(auth.currentUser!.id).get();
    auth.currentUser = AppUser.toDocument(userInfo);
    setState(() {
      isUpLoading = false;
    });
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Profile updated'),
        backgroundColor: Colors.green,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (isUpLoading) return false;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [IconButton(onPressed: updateInDb, icon: Icon(Icons.save))],
          backgroundColor: kPrimaryColor,
          title: const Text('Change Profile'),
          centerTitle: true,
        ),
        body: Container(
          width: size.width,
          height: size.height,
          child: Column(
            children: [
              if (isUpLoading) LinearProgressIndicator(),
              SizedBox(
                height: size.height * 0.09,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 210,
                    width: 210,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPrimaryColor.withOpacity(0.7)),
                  ),
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPrimaryColor.withOpacity(0.7)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      child: selectedImage != null
                          ? Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: auth.currentUser!.photoUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(primary: kPrimaryColor),
                  onPressed: selectPicture,
                  icon: const Icon(Icons.camera),
                  label: const Text('SELECT IMAGE')),
            ],
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
        ),
      ),
    );
  }
}
