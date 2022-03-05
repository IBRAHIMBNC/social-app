import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as Im;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/models/post.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/login_screen.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/welcome_screen.dart';
import 'package:uuid/uuid.dart';
import '../constants.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _controller = TextEditingController();
  File? image;
  String postId = const Uuid().v4();
  final postsRef = FirebaseFirestore.instance.collection('posts');
  bool isUploading = false;

  Future<void> addImage() async {
    PickedFile? im =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    if (im != null) {
      setState(() {
        image = File(im.path);
      });
    }
  }

  void compreseImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    Im.Image? decodeImage = Im.decodeImage(image!.readAsBytesSync());
    final comImage = File('$path/$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(decodeImage!, quality: 80));
    setState(() {
      image = comImage;
    });
  }

  void post() async {
    setState(() {
      isUploading = true;
    });
    // compreseImage();
    final auth = Provider.of<Auth>(context, listen: false);
    String mediaUrl = '';
    if (image != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('postsMedia')
          .child(postId + '.jpg');
      TaskSnapshot storageSnap = await storageRef.putFile(image!);
      mediaUrl = await storageSnap.ref.getDownloadURL();
    }
    String description = _controller.text.toString();

    await postsRef
        .doc(auth.currentUser!.id)
        .collection('usersPosts')
        .doc(postId)
        .set({
      'description': description,
      'timeStamp': Timestamp.now(),
      'likes': {},
      'mediaUrl': mediaUrl,
      'ownerId': auth.currentUser!.id,
      'postId': postId,
    });
    await FirebaseFirestore.instance.collection('timeline').doc(postId).set({
      'description': description,
      'timeStamp': Timestamp.now(),
      'isAdminPost': auth.currentUser!.isAdmin,
      'isStudentOrgPost': auth.currentUser!.isStudentOrg,
      'likes': {},
      'ownerName': auth.currentUser!.name,
      'profilePic': auth.currentUser!.photoUrl,
      'mediaUrl': mediaUrl,
      'ownerId': auth.currentUser!.id,
      'postId': postId,
    });
    final newPost = await postsRef
        .doc(auth.currentUser!.id)
        .collection('usersPosts')
        .doc(postId)
        .get();
    Provider.of<Posts>(context, listen: false).addPost(Post.fromDoc(newPost));
    setState(() {
      isUploading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (isUploading) return false;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Create Post',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SizedBox(
          width: double.infinity,
          height: size.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isUploading) const LinearProgressIndicator(),
                const SizedBox(
                  height: 8,
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(auth.currentUser!.photoUrl),
                  ),
                  title: Text(
                    auth.currentUser!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextFieldContainer(
                  size: size,
                  child: TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "What's in your mind?",
                    ),
                    controller: _controller,
                  ),
                ),
                GestureDetector(
                  onTap: addImage,
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kPrimaryLightColor,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      width: size.width * 0.9,
                      height: size.height * 0.45,
                      child: image == null
                          ? Center(
                              child: Image.asset('assets/images/add_image.png'))
                          : Image.file(
                              image!,
                              fit: BoxFit.cover,
                            )),
                ),
                RoundedButton(
                  text: 'POST',
                  color: kPrimaryColor,
                  textColor: Colors.white,
                  press: (image != null ||
                              _controller.text.toString().trim().isNotEmpty) &&
                          !isUploading
                      ? post
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
