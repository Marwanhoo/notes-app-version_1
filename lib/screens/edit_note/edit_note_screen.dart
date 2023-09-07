import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_app/components/components.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../home/home_screen.dart';

class EditNoteScreen extends StatefulWidget {
  final String? docId;
  final String title;
  final String note;
  const EditNoteScreen({super.key, required this.docId, required this.title, required this.note});
  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  CollectionReference collectionReference = FirebaseFirestore.instance
      .collection("notes");
  Reference? ref;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  File? file;
  String? urlImage;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    titleController.text = widget.title;
    noteController.text = widget.note;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  // initialValue: widget.title,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => validateRequiredField(value, "title"),
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  //  initialValue: widget.note,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => validateRequiredField(value, "note"),
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'note',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                OutlinedButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            height: 175,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera),
                                  title: const Text("Camera"),
                                  onTap: () async {
                                    var pickedImage = await ImagePicker()
                                        .pickImage(source: ImageSource.camera);
                                    if (pickedImage != null) {
                                      file = File(pickedImage.path);
                                      var random = Random().nextInt(1000);
                                      var nameImage = "$random${basename(
                                          pickedImage.path)}";
                                      ref =
                                          FirebaseStorage.instance.ref("images")
                                              .child(nameImage);
                                      if (context.mounted) {
                                        Navigator.of(context)
                                          .pop();
                                      }
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.image),
                                  title: const Text("Gallery"),
                                  onTap: () async {
                                    var pickedImage = await ImagePicker()
                                        .pickImage(source: ImageSource.gallery);
                                    if (pickedImage != null) {
                                      file = File(pickedImage.path);
                                      var random = Random().nextInt(1000);
                                      var nameImage = "$random${basename(
                                          pickedImage.path)}";
                                      ref =
                                          FirebaseStorage.instance.ref("images")
                                              .child(nameImage);
                                      if (context.mounted) {
                                        Navigator.of(context)
                                          .pop();
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                  }, child: const Text(
                  "Edit Image For Note",
                ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      await editNotes(context);
                    },
                    child: const Text(
                      "Edit Note",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  editNotes(context) async {
    if (file == null) {
      if (formKey.currentState!.validate()) {
        showLoading(context);
        // await ref?.putFile(file!);
        // urlImage = await ref?.getDownloadURL();
        await collectionReference.doc(widget.docId).update({
          "title": titleController.text,
          "note": noteController.text,
          //"imageUrl" : urlImage,
          "user id": FirebaseAuth.instance.currentUser?.uid,
        });
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false);
      }
    } else {
      if (formKey.currentState!.validate()) {
        showLoading(context);
        await ref?.putFile(file!);
        urlImage = await ref?.getDownloadURL();
        await collectionReference.doc(widget.docId).update({
          "title": titleController.text,
          "note": noteController.text,
          "imageUrl": urlImage,
          "user id": FirebaseAuth.instance.currentUser?.uid,
        });
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false);
      }
    }
  }


}