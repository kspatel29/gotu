import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:gotuappv1/autocomplete_prediction.dart';
import 'package:gotuappv1/placeAutoComplete.dart';
import 'package:gotuappv1/firestore.dart';
import 'package:gotuappv1/network_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floating_action_wheel/floating_action_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geolocator/geolocator.dart';

import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
// import 'package:file_picker_example/src/file_picker_demo.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MapSample extends StatefulWidget {

  final double? latitude;
  final double? longitude;

  // Assign them in the constructor using the @required annotation
  const MapSample(  {
    Key? key,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  // const MapSample({super.key});
  @override
  State<MapSample> createState() => MapSampleState();
}



class MapSampleState extends State<MapSample> {
  String mapTheme = '';
  // BitmapDescriptor customIcon;
  final FirestoreService firestoreService = FirestoreService();

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  
  bool? hereFromReportVerPage;

  File? image;
  File? video;
  // late VideoPlayerController _videoController;

  // CameraPosition _initialCameraPosition = CameraPosition(
  //   target: LatLng(53.631611, -113.4937),
  //   zoom: 11,
  // );
  CameraPosition? _initialCameraPosition;

  final MarkerId markerId = MarkerId('marker_1');
  final Marker marker = Marker(
    markerId: MarkerId('marker_1'),
    position: LatLng(53.5461, -113.4937), // Change this with the actual address coordinates
    infoWindow: InfoWindow(title: 'Address', snippet: 'This is the address you marked.'),
  );

  // Add the marker to a Set
  final Set<Marker> _markers = {};
  
  XFile? _image;
  XFile? _video;
  // late CameraPosition _currentCameraPosition;
  
  // XFile? get image => null;
  Future<void> _requestLocationAccess() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle permission denied scenario
        return;
      }
  }
  }

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  StreamSubscription<Position>? _positionStreamSubscription;
  @override
  void initState() {
    super.initState();
    _requestLocationAccess();
    _getCurrentLocation().then((position) {
      setState(() {
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.0,
        );
        print(_initialCameraPosition);
        _markers.add(Marker(
          markerId: MarkerId('user_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarker,
        ));
      });
    }).catchError((error) {
      // Handle error fetching current location
      print('Error fetching current location: $error');
    });
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings
    ).listen((Position position) {
      setState(() {
        _markers.clear(); // Clear the old marker
        _markers.add(Marker(
          markerId: MarkerId('user_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Your Location'),
        ));
      });
    });

    addCustomIcon();

    DefaultAssetBundle.of(context).loadString('assets/map_styles.json').then((value) {
      mapTheme = value;
    });
  }

  
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/marker_2.png")
        .then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }
  

  Position? position;
  Future<Position> _getCurrentLocation() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();
    return position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // List<String?>? location = [position.latitude.toStringAsFixed(8), position.longitude.toStringAsFixed(8)];
  }

  List<AutocompletePrediction> placePredictions =[];
  Future<void> placeAutoComplete(String query) async {
    Uri uri = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', 
    {
      "input":query,
      'key': 'AIzaSyC0Cb--NlC6ieCNt8jSQImz5bN1JhmvOsY', // REPLACE WITH YOUR
    });
    String? response = await NetworkUtility.fetchUrl(uri);
    print(response);
    if (response!= null) {
      PlaceAutocompleteResponse result = PlaceAutocompleteResponse.parseAutocompleteResult(response);
      setState(() {
        placePredictions = result.predictions;
      });       
        }
  }

  String demoText = '';
  Color backgroundColor = Colors.white;
  double? searchBarSpace = 50;

  _handleTap(LatLng point) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: FloatingActionWheel(
        
        buttons: [
          WheelButton(onPressed: () {
            Navigator.of(context).pop();
            _markLocation(point);


            setState(() {
              demoText = "button #1 pressed";
              backgroundColor= Colors.orangeAccent;
            });
          },
              text: 'button 1',
              backgroundColor: Colors.orange),
          WheelButton(onPressed: () {
            Navigator.of(context).pop();
            _markLocation(point);


            setState(() {
              demoText = "button #2 pressed";
              backgroundColor= Colors.greenAccent;
            });
          },
              icon: Icons.ac_unit,
              backgroundColor: Colors.green),
              
          WheelButton(onPressed: () {
            Navigator.of(context).pop();
            _markLocation(point);

            
            setState(() {
              demoText = "button #3 pressed";
              backgroundColor= Colors.cyanAccent;
            });
          },
              image: Image.asset('assets/your_image.png'),
              backgroundColor: Colors.cyan),
              
          WheelButton(
              onPressed: () {
                Navigator.of(context).pop();
            _markLocation(point);

            
            setState(() {
              demoText = "button #4 pressed";
              backgroundColor= Colors.pinkAccent;
            });
          },
              icon: Icons.home,
              backgroundColor: Colors.pink),
          
        ],
        
      )
          )
        ]
          );
      },
    );
  }

  Future<LatLng> getPlaceDetails(String placeId) async {
    final apiKey = 'AIzaSyC0Cb--NlC6ieCNt8jSQImz5bN1JhmvOsY'; // Replace with your actual API Key
    final response = await http.get(
      Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final lat = data['result']['geometry']['location']['lat'];
      final lng = data['result']['geometry']['location']['lng'];
      LatLng Point = LatLng(lat, lng);

      // _markLocation(Point);
      return LatLng(lat, lng);
    } else {
      throw Exception('Failed to load place details');
    }
  }

  Future<void> moveCameraToLocation(LatLng newPosition) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPosition,
            zoom: 17.0, // Adjust zoom level as necessary
          ),
        ),
    );
    }




  _markLocation(LatLng point) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(
          title: 'Suspicious activity reported',
        ),
        // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        icon: markerIcon,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: HexColor('#182530'),
        
        title: Image.asset(
            'assets/logo.png',
            height: 160, // Increase the height to make the image bigger
        ),
        
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: (){
                  _controller.future.then((value){
                    DefaultAssetBundle.of(context).loadString('assets/map_styles.json').then((String){
                      value.setMapStyle(String);
                      });
                    
                  });
                },
                child: Text("water"),
              ),
              PopupMenuItem(
                onTap: (){
                  _controller.future.then((value){
                    DefaultAssetBundle.of(context).loadString('assets/theme_2.json').then((String){
                      value.setMapStyle(String);
                      });
                    
                  });
                },
                child: Text("Theme 2"),
              ),
              PopupMenuItem(
                onTap: (){
                  _controller.future.then((value){
                    DefaultAssetBundle.of(context).loadString('assets/theme_3.json').then((String){
                      value.setMapStyle(String);
                      });
                    
                  });
                },
                child: Text("Theme 3"),
              ),
        ],
          
          )
        ],
      ),
      body:StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getReportOnMap(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List reportList = snapshot.data!.docs;
            _markers.clear(); // Clear old markers
            for (var document in reportList) {
              GeoPoint pos = document.data()['reportLocation']; // Get the GeoPoint
              String ReportType = document.data()['reportType']; // Get the report type
              // String? ReportDescription = document.data()['reportDescription']; // Get the report description
              _markers.add(Marker(
                markerId: MarkerId(document.id), // Use document ID as marker ID
                position: LatLng(pos.latitude, pos.longitude), // Convert GeoPoint to LatLng
                infoWindow: InfoWindow(
                  title: '$ReportType',
                  // snippet: '$ReportDescription',
                ),
              ));
              // _markLocation(pos); // Add marker to list
            }
            return Stack(
              children: <Widget>[
                (_initialCameraPosition == null)
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _initialCameraPosition!,
                    onMapCreated: (GoogleMapController controller) {
                    controller.setMapStyle(mapTheme);
                    _controller.complete(controller);
                },
                markers:_markers,
                onTap: (LatLng point) {
                  _openForm(true, point);
                },
                zoomControlsEnabled: false,
                compassEnabled: false,
                myLocationButtonEnabled: false,
              ),
              Positioned(
                top: 50.0,
                right: 15.0,
                left: 15.0,
                child: Container(
                  height: searchBarSpace,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.white,
                  ),
                  child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Enter a Location',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  placeAutoComplete(_searchController.text);
                                  setState(() {
                                    searchBarSpace = 300; // Expand the search bar
                                  });
                                },
                                iconSize: 30.0,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                searchBarSpace = 300; // Expand the search bar when tapped
                              });
                            },
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  searchBarSpace = 50; // Compress the search bar if the input is cleared
                                });
                              } else {
                                placeAutoComplete(value);
                              }
                            },
                          ),
                        ),
                        

                        Visibility(
                          visible: placePredictions.isNotEmpty,
                          child: Expanded(
                            child: ListView.builder(
                              itemCount: placePredictions.length,
                              itemBuilder: (context, index) => Card(
                                color: Colors.white,
                                elevation: 5, // This controls the shadow size
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5), // This makes the corners rounded
                                ),
                                child: ListTile(
                                  onTap: () async{
                                    String? placeId = placePredictions[index].placeId;
                                    LatLng placeCoordinates = await getPlaceDetails(placeId!); 
                                    print(placeCoordinates); 
                                    
                                    await moveCameraToLocation(placeCoordinates);
                                    // final GoogleMapController controller = await _controller.future;
                                    // controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                                    //   target: placeCoordinates,
                                    //   zoom: 20.0, // Adjust zoom level as necessary
                                    // )));

                                    // Optionally, clear existing markers and add a new marker at the selected place
                                    setState(() {
                                      _markers.clear(); // Remove existing markers if necessary
                                      _markers.add(Marker(
                                        markerId: MarkerId(placeId),
                                        position: placeCoordinates,
                                        infoWindow: InfoWindow(title: placePredictions[index].description),
                                        ));
                                      });
                                    print('Selected: ${placePredictions[index].description}');
                                    setState(() {
                                      searchBarSpace = 50; // Expand the search bar
                                    });
                                  },
                                  title: Text(placePredictions[index].description!),
                                ),
                              ),
                            ),
                          ),
                        ),


                        // Handle errors or empty suggestions
                        Visibility(
                          visible: placePredictions.isEmpty,
                          child: Text('No suggestions found'),
                        ),
                      ],
                    )
                ),
              ),
              ]
            );
          } else {
            return CircularProgressIndicator(); // Show loading spinner while waiting for data
          }
        },
      ),
 
      
      

      floatingActionButton: Padding(
        padding: EdgeInsets.only(right: 2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left:55.0),
              child: FloatingActionButton(
                onPressed: () async {
                  // Zoom In
                  GoogleMapController controller = await _controller.future;
                  controller.animateCamera(CameraUpdate.zoomIn());
                },
                child: Icon(Icons.zoom_in),
              ),
            ),
            SizedBox(height: 10), // Spacing between buttons
            Padding(
              padding: const EdgeInsets.only(left: 55.0),
              child: FloatingActionButton(
                onPressed: () async {
                  // Zoom Out
                  GoogleMapController controller = await _controller.future;
                  controller.animateCamera(CameraUpdate.zoomOut());
                },
                child: Icon(Icons.zoom_out),
              ),
            ),
            SizedBox(height: 10), // Spacing between buttons
            Padding(
              padding: const EdgeInsets.only(left: 55.0),
              child: FloatingActionButton(
                onPressed: () async {
                  Position currentLoc = await _getCurrentLocation();
                  LatLng currentLatLng = LatLng(currentLoc.latitude, currentLoc.longitude);
                  _openForm(true,currentLatLng);
                  setState(() {
                    if (position != null) {
                      _markers.add(Marker(
                        markerId: MarkerId('marker_1'),
                        position: LatLng(currentLoc.latitude, currentLoc.longitude),
                        infoWindow: InfoWindow(title: 'Address', snippet: 'This is the address you marked.'),
                      ));
                    }
                  });
                },
                child: Icon(Icons.add_location),
              ),
            ),
            SizedBox(height: 10), // Spacing between buttons
            FloatingActionButton.extended(
              onPressed: () async{_openForm(false, null);},
              label: const Text('Report!'),
              icon: const Icon(Icons.report, color: Color.fromARGB(255, 6, 1, 7)),
              backgroundColor: Colors.red,
            ),
          ],
          ),
      ),
    );
  }



  Future<void> _openForm(bool isLocationKnown, LatLng? reportedLocation) async {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();
  final TextEditingController extraController = TextEditingController();

  
  // Do something with the reportLocation or handle the null case

  if(isLocationKnown) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close dialog
      builder: (BuildContext context) {
        ReportType? _reportType = ReportType.suspicious;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Report'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Please select the type of your report.'),
                    Column(
                      children: ReportType.values.map((ReportType type) {
                        return RadioListTile<ReportType>(
                          title: Text(type.toString().split('.').last),
                          value: type,
                          groupValue: _reportType,
                          onChanged: (ReportType? value) {
                            setState(() {
                              _reportType = value;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(onPressed: () {
                  Navigator.of(context).pop();
                }, child: Text('cancel')),
                TextButton(
                  child: Text('Submit'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button to close dialog
                      builder: (BuildContext context) {
                        String? _additionalInfo;
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              title: Text('Additional Information'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    TextField(
                                      maxLines: 5, // Set the number of lines for the textbox
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Additional Information',
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          _additionalInfo = value;
                                        });
                                      },
                                    ),
                                    Row(
                                      children: [
                                        // Text(
                                        //   'Words: ${_additionalInfo?.split(' ').length ?? 0}',
                                        // ),
                                        // SizedBox(width: 8),
                                        Text(
                                            'At least: ${30 - (_additionalInfo?.length ?? 0)}',
                                        ),
                                      ],
                                    ),
                                    if (image != null) Image.file(image!), // Add a comma after the image widge
                                      SizedBox(height: 20), // Some spacing
                                      
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            child: Icon(Icons.image),
                                            onPressed: () async {
                                              final ImagePicker _picker = ImagePicker();
                                              final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                                          
                                              if (pickedImage != null) {
                                                setState(() {
                                                  image = File(pickedImage.path);
                                                  _image = pickedImage;
                                                });
                                              }
                                            },
                                          ),
                                          if (image != null) Icon(Icons.check),
                                          SizedBox(width:5),
                                          TextButton(
                                            child: Icon(Icons.camera_alt_rounded),
                                            onPressed: () async {
                                                final ImagePicker _picker = ImagePicker();
                                                final XFile? pickedVideo = await _picker.pickVideo(
                                                  source: ImageSource.gallery,
                                                  maxDuration: Duration(seconds: 45),
                                                  );
                                      
                                                if (pickedVideo != null) {
                                                  setState(() {
                                                    video = File(pickedVideo.path);
                                                    _video = pickedVideo;
                                                  });
                                                }
                                            },
                                            ),
                                            if (video != null) Icon(Icons.check),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                  TextButton(onPressed: () {
                                    Navigator.of(context).pop();
                                    image = null;
                                    video = null;
                                  }, child: Text('cancel')),
                                  TextButton(
                                    child: Text('Submit'),
                                    onPressed: () {
                                      if (_additionalInfo != null && _additionalInfo!.length >= 30) {
                                        
                                        firestoreService.addReport(user!, reportedLocation! , null, _reportType.toString().split('.').last, _additionalInfo, null, null, null, _image, _video);
                                        _image = null;
                                        _video = null;
                                        Navigator.of(context).pop();
                                        image = null;
                                        video = null;
                                        // Handle _additionalInfo here
                                      } else {
                                        // Show an error message or perform any desired action
                                      }
                                    },
                                  ),
                                  
                                ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );  

  }
  else{
  
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close dialog
      builder: (BuildContext context) {
        ReportType? _reportType = ReportType.suspicious;
        String? _location;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Report'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Please select the type of your report.'),
                    Column(
                      children: ReportType.values.map((ReportType type) {
                        return RadioListTile<ReportType>(
                          title: Text(type.toString().split('.').last),
                          value: type,
                          groupValue: _reportType,
                          onChanged: (ReportType? value) {
                            setState(() {
                              _reportType = value;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Location',
                      ),
                      onChanged: (String value) {
                        setState(() {
                          _location = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(onPressed: () {
                  Navigator.of(context).pop();
                }, child: Text('cancel')),
                TextButton(
                  child: Text('Submit'),
                  onPressed: () {
                    if (_reportType != null && _location != null && _location!.isNotEmpty) {
                      Navigator.of(context).pop();
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button to close dialog
                        builder: (BuildContext context) {
                          String? _additionalInfo;
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return AlertDialog(
                                title: Text('Additional Information'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      TextField(
                                        controller: extraController,
                                        maxLines: 5, // Set the number of lines for the textbox
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Additional Information',
                                        ),
                                        onChanged: (String value) {
                                          setState(() {
                                            _additionalInfo = value;
                                          });
                                        },
                                      ),
                                      Row(
                                        children: [
                                          // Text(
                                          //   'at least: ${_additionalInfo?.length ?? 0}',
                                          // ),
                                          // SizedBox(width: 8),
                                          Text(
                                            'At least: ${30 - (_additionalInfo?.length ?? 0)}',
                                          ),
                                        ],
                                      ),
                                      if (image != null) Image.file(image!), // Add a comma after the image widget
                                    
                                      SizedBox(height: 20), // Some spacing
                                      
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            child: Icon(Icons.image),
                                            onPressed: () async {
                                              final ImagePicker _picker = ImagePicker();
                                              final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                                          
                                              if (pickedImage != null) {
                                                setState(() {
                                                  image = File(pickedImage.path);
                                                  _image = pickedImage;

                                                });
                                              }
                                            },
                                          ),
                                          if (video != null) Icon(Icons.check),
                                          SizedBox(width:5),
                                          TextButton(
                                            child: Icon(Icons.camera_alt_rounded),
                                            onPressed: () async {
                                                final ImagePicker _picker = ImagePicker();
                                                final XFile? pickedVideo = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: Duration(seconds:45));

                                                if (pickedVideo != null) {
                                                  setState(() {
                                                    video = File(pickedVideo.path);
                                                    _video = pickedVideo;
                                                  });
                                                }
                                            },
                                            ),
                                            if (video != null) Icon(Icons.check),

                                        ],
                                      ), // Add a comma after the text button widget

                                      
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(onPressed: () {
                                    Navigator.of(context).pop();
                                    image = null;
                                    video = null;
                                  }, child: Text('cancel')),
                                  TextButton(
                                    child: Text('Submit'),
                                    onPressed: () {
                                      if (_additionalInfo != null && _additionalInfo!.length >= 30) {
                                        firestoreService.addReport(
                                          user!,
                                          null,
                                          _location,
                                          _reportType.toString().split('.').last,
                                          _additionalInfo,
                                          null,
                                          null,
                                          null,
                                          _image,
                                          _video,
                                        );
                                        _image = null;
                                        _video = null;
                                        Navigator.of(context).pop();
                                        image = null;
                                        video = null;
                                        // Handle _additionalInfo here
                                      } else {
                                        // Show an error message or perform any desired action
                                      }
                                    },
                                  ),
                                  
                                ],
                              );
                            },
                          );
                        },
                      );
                    } else {
                      // Show an error message or perform any desired action
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }  
}

@override
  void dispose() {
    // _videoController?.dispose(); // Remember to dispose the video player controller
    _searchController.dispose();

 // Cancel the stream subscription
    _positionStreamSubscription?.cancel();
    // _imageController?.dispose(); 
    // _currentCameraPosition = null;
    super.dispose();
  }

}

enum ReportType { suspicious, criminal, vehicleCrash, other }
