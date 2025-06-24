import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plantae_project/util/locationServices.dart';
import 'package:plantae_project/util/permission_handler.dart';
import 'googleMapPreview.dart';

class LocationInputField extends StatefulWidget {
  final Function(Position) onLocationSelected;
  const LocationInputField({Key? key, required this.onLocationSelected}) : super(key: key);
  
  @override
  State<LocationInputField> createState() => _LocationInputFieldState();
}

class _LocationInputFieldState extends State<LocationInputField> {
  Position? _pickedPosition;

  // You can access this variable from outside this widget by lifting the state up if needed
  Position? get pickedPosition => _pickedPosition;

  void _handleLocationTap() async {
    // Check for location permission first
    bool hasPermission = await PermissionManager.handleLocationPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required to use this feature'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    Position? pos = await LocationService.getCurrentLocation();
    if (pos != null) {
      setState(() {
        _pickedPosition = pos;
      });
      widget.onLocationSelected(pos);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get location. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleLocationTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_pin,
                color: Color.fromARGB(255, 32, 124, 36)),
            const SizedBox(width: 2),
            Expanded(
              child: _pickedPosition == null
                  ? const Text("Tap to get location")
                  : GoogleMapPreviewWidget(position: _pickedPosition!),
            ),
          ],
        ),
      ),
    );
  }
}
