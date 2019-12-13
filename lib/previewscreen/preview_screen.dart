import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:http/http.dart';

class PreviewImageScreen extends StatefulWidget {
  final String imagePath;
  PreviewImageScreen({this.imagePath});

  @override
  _PreviewImageScreenState createState() => _PreviewImageScreenState();
}

class UserLocation {
  final double latitude;
  final double longitude;
  UserLocation({this.latitude, this.longitude});
}

class _PreviewImageScreenState extends State<PreviewImageScreen> {
  UserLocation _currentLocation;
  var location = Location();
  final String url = "https://aars-server-eq41zqwqg.now.sh/api/accident/new";
  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
          latitude: userLocation.latitude, longitude: userLocation.longitude);
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
    print(_currentLocation.latitude.toString() +
        ',' +
        _currentLocation.longitude.toString() +
        ',' +
        DateTime.now().toString());
    return _currentLocation;
  }

  _makePostRequest(UserLocation userLocation) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    String json =
        '{"latitude": ${userLocation.latitude.toString()}, "longitude": ${userLocation.longitude.toString()}, "time": ${DateTime.now().toString()}}';
    // make POST request
    Response response = await post(url, headers: headers, body: json);
    // check the status code for the result
    int statusCode = response.statusCode;
    print(statusCode);
    // this API passes back the id of the new item added to the body
    //String body = response.body;
  }

  Future loadModel() async {
    String ress = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1 // defaults to 1
        );
    print(ress);
  }

  void runModel(filepath) async {
    var recognitions = await Tflite.runModelOnImage(
      path: filepath, // required
      numResults: 2,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    print(recognitions[0]["label"]);
    if (recognitions[0]["label"].toString() == "0 Accident") {
      getLocation().then((loc) {
        _makePostRequest(loc);
      });

      Fluttertoast.showToast(
          msg: "Accident",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (recognitions[0]["label"].toString() == "1 Not Accident") {
      getLocation().then((loc) {
        _makePostRequest(loc);
      });
      Fluttertoast.showToast(
          msg: "Not Accident",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);
    }
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
                  child: Text('Request Assistance'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
