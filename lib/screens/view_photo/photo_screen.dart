import 'package:flutter/material.dart';
class PhotoScreen extends StatefulWidget {
  final String docId;
  final String photo;
  const PhotoScreen({super.key, required this.docId, required this.photo});
  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(
          widget.photo,
          fit: BoxFit.cover,
        ),
      )
    );
  }
}
