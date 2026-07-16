import 'package:cheguei/models/sptrans_stop_model.dart';
import 'package:cheguei/services/sptrans/sptrans_service.dart';
import 'package:cheguei/services/location/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cheguei/models/sptrans_line_model.dart';

class SpTransRepository {
  SpTransRepository._();

  static Future<List<SpTransStopModel>> searchStops(String term) async {
    return await SpTransService.searchStops(term);
  }

  static Future<List<SpTransStopModel>> getNearbyStops(
    Position position,
  ) async {
    final stops = await searchStops('');

    stops.sort((a, b) {
      final distanceA = LocationService.calculateDistance(
        startLatitude: position.latitude,
        startLongitude: position.longitude,
        endLatitude: a.latitude,
        endLongitude: a.longitude,
      );

      final distanceB = LocationService.calculateDistance(
        startLatitude: position.latitude,
        startLongitude: position.longitude,
        endLatitude: b.latitude,
        endLongitude: b.longitude,
      );

      return distanceA.compareTo(distanceB);
    });

    return stops.take(5).toList();
  }

  static Future<List<SpTransLineModel>> getLinesByStop(int stopId) async {
    return await SpTransService.getLinesByStop(stopId);
  }
}
