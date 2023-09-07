import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_app/authentication/signin_screen/sign_in_screen.dart';
import 'package:flutter_notes_app/screens/add_note/add_note_screen.dart';
import 'package:flutter_notes_app/screens/view_note/view_note_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../edit_note/edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection("notes");
  var fbm = FirebaseMessaging.instance;

  @override
  void initState() {
    fbm.getToken().then((token) => debugPrint("TOKEN : $token"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Notes App'),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const AlertDialog(
                      title: Text("About"),
                      content: Text("This is a simple notes app"),
                    );
                  },
                );
              },
              icon: const Icon(
                CupertinoIcons.profile_circled,
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            //padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Drawer Header"),
                        CircleAvatar(
                          child: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.arrow_back_ios)),
                        ),
                      ],
                    ),
                    const FlutterLogo(
                      size: 40,
                    ),
                    Text(
                      "${user?.displayName}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text("${user?.email}"),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.inbox),
                title: const Text("Home"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Sign Out"),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const SignInScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text("Delete Account"),
                onTap: () {

                },
              ),
            ],
          ),
        ),
        body: FutureBuilder(
          future:
              collectionReference.where("user id", isEqualTo: user?.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(),
                    secondaryBackground: Container(
                      color: Colors.grey,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.black,
                            ),
                            Text(
                              "Delete",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onDismissed: (DismissDirection direction)async{
                      if(direction == DismissDirection.endToStart){
                        await collectionReference.doc(snapshot.data!.docs[index].id).delete();
                        await FirebaseStorage.instance.refFromURL(snapshot.data!.docs[index]["imageUrl"]).delete();
                      }
                    },
                    child: InkWell(
                      onTap: (){
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (_)=> ViewNoteScreen(
                            docId: snapshot.data!.docs[index].id,
                            title: snapshot.data!.docs[index]["title"],
                            note: snapshot.data!.docs[index]["note"],
                            photo: snapshot.data!.docs[index]["imageUrl"],
                          ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Card(
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                  child: Image.network(
                                    snapshot.data!.docs[index]["imageUrl"],
                                    width: 125,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  height: 100,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            snapshot.data!.docs[index]["title"],
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => EditNoteScreen(
                                                    docId:
                                                        snapshot.data?.docs[index].id,
                                                    title: snapshot.data?.docs[index]
                                                        ["title"],
                                                    note: snapshot.data?.docs[index]
                                                        ["note"],
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.edit),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        snapshot.data!.docs[index]["note"],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Container(
                padding: const EdgeInsets.only(bottom: 5),
                width: 200.0,
                height: 100.0,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.withOpacity(0.5),
                  highlightColor: Colors.white,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        child: Container(
                          color: Colors.grey,
                          width: 125,
                          height: 100,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              color: Colors.grey,
                              width: 100,
                              height: 10,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              color: Colors.grey,
                              width: 100,
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddNoteScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
