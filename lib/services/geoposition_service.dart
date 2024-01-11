import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeopositionService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future saveCurrentGeoPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy:
        LocationAccuracy.bestForNavigation);

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    await _firestore
        .collection('dark_geo_position')
        .doc(_auth.currentUser!.uid)
        .collection("placemark")
        .add(placemarks[0].toJson());
  }
}