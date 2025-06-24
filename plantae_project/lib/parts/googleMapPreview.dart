import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapPreviewWidget extends StatelessWidget {
  final Position position;

  const GoogleMapPreviewWidget({Key? key, required this.position})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LatLng latLng = LatLng(position.latitude, position.longitude);

    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: latLng,
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: MarkerId("user_location"),
              position: latLng,
              infoWindow: InfoWindow(title: "You are here"),
            ),
          },
          zoomControlsEnabled: false,
          liteModeEnabled: true, // Makes it lightweight
          myLocationEnabled: true,
        ),
      ),
    );
  }
}
