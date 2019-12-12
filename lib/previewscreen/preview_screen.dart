import 'dart:io';
import 'dart:typed_data';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

class PreviewImageScreen extends StatefulWidget {
  final String imagePath;

  PreviewImageScreen({this.imagePath});

  @override
  _PreviewImageScreenState createState() => _PreviewImageScreenState();
}

class _PreviewImageScreenState extends State<PreviewImageScreen> {
  Future loadModel() async {
    await Tflite.close();
    String ress = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/label.txt",
        numThreads: 1 // defaults to 1
        );
     print(ress)
  }

  void runModel(filepath) async {
    var recognitions = await Tflite.runModelOnImage(
        path: filepath, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );
   

    recognitions.map((res) {
      print(
          "${res["index"]} - ${res["label"]}: ${res["confidence"].toStringAsFixed(3)}");
    });
    await Tflite.close();
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover)),
            SizedBox(height: 10.0),
            Flexible(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(60.0),
                child: RaisedButton(
                  onPressed: () {
                    runModel(widget.imagePath);
                    //TODO: feed img model.
                  },
                  child: Text('Share'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
