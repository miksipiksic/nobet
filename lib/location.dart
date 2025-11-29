import 'dart:math';
import 'package:geolocator/geolocator.dart';

/// Klasa koja predstavlja geografsku lokaciju
class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});
}

/// Računa udaljenost između dvije lokacije u metrima
double _calculateDistance(Location loc1, Location loc2) {
  return Geolocator.distanceBetween(
    loc1.latitude,
    loc1.longitude,
    loc2.latitude,
    loc2.longitude,
  );
}

/// Vraća najmanju udaljenost od trenutne lokacije do bilo koje betting lokacije
/// 
/// [currentLocation] - trenutna lokacija korisnika
/// [bettingLocations] - lista betting lokacija
/// 
/// Vraća udaljenost u metrima
double getMinimumDistanceToBettingLocation(
  Location currentLocation,
  List<Location> bettingLocations,
) {
  if (bettingLocations.isEmpty) {
    return double.infinity;
  }
  
  double minDistance = double.infinity;
  
  for (Location bettingLocation in bettingLocations) {
    double distance = _calculateDistance(currentLocation, bettingLocation);
    if (distance < minDistance) {
      minDistance = distance;
    }
  }
  
  return minDistance;
}
