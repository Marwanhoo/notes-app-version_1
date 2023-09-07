import 'package:flutter/material.dart';
import 'package:flutter_notes_app/screens/view_photo/photo_screen.dart';
class ViewNoteScreen extends StatefulWidget {
  final String docId;
  final String title;
  final String note;
  final String photo;
  const ViewNoteScreen({super.key, required this.docId, required this.title, required this.note, required this.photo});

  @override
  State<ViewNoteScreen> createState() => _ViewNoteScreenState();
}

class _ViewNoteScreenState extends State<ViewNoteScreen> {
  bool isShowingPhoto = false;
  void showPhoto(){
    setState(() {
      isShowingPhoto = true;
    });
  }
  void hidePhoto(){
    setState(() {
      isShowingPhoto = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Note"),
        actions: [
          CircleAvatar(
            child: IconButton(
              onPressed: (){},
              icon: const Icon(Icons.edit),
            ),
          ),
          const SizedBox(width: 20,),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: (){
                if(isShowingPhoto){
                  hidePhoto();
                }else{
                  showPhoto();
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Image.network(
                      widget.photo,
                      width: double.infinity,
                      height: 200,
                      fit: isShowingPhoto ? BoxFit.contain : BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                        bottom: 10,
                      ),
                      child: CircleAvatar(
                        child: IconButton(
                          color: Colors.black,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_)=> PhotoScreen(
                                docId: widget.docId,
                                photo: widget.photo,
                              ),),
                            );
                          },
                          icon: const Icon(Icons.image),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ),
            const SizedBox(height: 20,),
            Text(
                widget.title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const Divider(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "note :",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.note,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
