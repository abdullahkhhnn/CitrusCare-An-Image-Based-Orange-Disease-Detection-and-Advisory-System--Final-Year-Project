import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  // Nominatim API - FREE, no API key required
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  /// Search for nearby agricultural/farming supply shops
  /// using OpenStreetMap Nominatim API (completely FREE)
  ///
  /// [latitude] - Current latitude
  /// [longitude] - Current longitude
  /// [radius] - Search radius (used to calculate viewbox)
  ///
  /// Returns a list of shops with name, address, location, etc.
  static Future<List<Map<String, dynamic>>> getNearbyShops({
    required double latitude,
    required double longitude,
    int radius = 10000,
  }) async {
    try {
      print('🔍 Searching for nearby shops with Nominatim (FREE)...');
      print('📍 Location: $latitude, $longitude');
      print('📏 Search radius: ${radius}m');

      // Calculate viewbox (bounding box around user's location)
      // Roughly: 0.1 degree ≈ 11km
      double offset = 0.1;
      String viewbox = '${longitude - offset},${latitude + offset},'
          '${longitude + offset},${latitude - offset}';

      // Multiple search queries to find different types of shops
      // that could be relevant to farmers
      final List<String> searchQueries = [
        'shop',
        'pharmacy',
        'agriculture',
        'pesticide',
        'fertilizer',
        'hardware',
        'marketplace',
      ];

      List<Map<String, dynamic>> allResults = [];
      Set<String> seenIds = {};

      for (String query in searchQueries) {
        try {
          final results = await _searchNominatim(
            query: query,
            viewbox: viewbox,
          );

          // Add only unique results
          for (var result in results) {
            String id = result['id'].toString();
            if (!seenIds.contains(id)) {
              seenIds.add(id);
              allResults.add(result);
            }
          }

          // Stop if we have enough results
          if (allResults.length >= 15) break;

          // Nominatim requires max 1 request per second
          // Wait 1.1 seconds between requests
          await Future.delayed(const Duration(milliseconds: 1100));
        } catch (e) {
          print('⚠️ Search error for "$query": $e');
        }
      }

      print('✅ Found ${allResults.length} unique shops');

      // Sort by distance from user's location
      allResults.sort((a, b) {
        double distA = _calculateDistance(
          latitude,
          longitude,
          a['latitude'],
          a['longitude'],
        );
        double distB = _calculateDistance(
          latitude,
          longitude,
          b['latitude'],
          b['longitude'],
        );
        return distA.compareTo(distB);
      });

      // Take top 10 closest shops
      return allResults.take(10).toList();
    } catch (e) {
      print('❌ Exception: $e');
      return [];
    }
  }

  /// Search Nominatim with a specific query
  static Future<List<Map<String, dynamic>>> _searchNominatim({
    required String query,
    required String viewbox,
  }) async {
    final url = Uri.parse(
      '$_baseUrl?q=${Uri.encodeComponent(query)}'
      '&format=json'
      '&limit=10'
      '&countrycodes=pk'
      '&viewbox=$viewbox'
      '&bounded=1'
      '&addressdetails=1',
    );

    print('🌐 Searching: $query');

    final response = await http.get( // makes the actual API call
      url,
      headers: {
        // Nominatim requires User-Agent header
        'User-Agent': 'CitrusCare/1.0 (citruscare.app@example.com)',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('  ✓ Found ${data.length} results for "$query"');

      return data.map<Map<String, dynamic>>((place) {
        // Extract address details
        final address = place['address'] as Map<String, dynamic>? ?? {};

        // Build readable address
        final addressParts = <String>[];
        if (address['road'] != null) addressParts.add(address['road']);
        if (address['suburb'] != null) addressParts.add(address['suburb']);
        if (address['neighbourhood'] != null) {
          addressParts.add(address['neighbourhood']);
        }
        if (address['city'] != null) {
          addressParts.add(address['city']);
        } else if (address['town'] != null) {
          addressParts.add(address['town']);
        } else if (address['village'] != null) {
          addressParts.add(address['village']);
        }

        final addressString = addressParts.isNotEmpty
            ? addressParts.join(', ')
            : 'Peshawar, Pakistan';

        // Get readable name
        String name = place['name'] ?? '';
        if (name.isEmpty) {
          name = place['display_name'].toString().split(',').first;
        }
        if (name.isEmpty || name == 'yes') {
          name = _getNameFromType(place['type'] ?? '');
        }

        return {
          'id': place['place_id'].toString(),
          'name': name,
          'address': addressString,
          'description': _getDescription(place),
          'latitude': double.parse(place['lat'].toString()),
          'longitude': double.parse(place['lon'].toString()),
          'rating': 0.0,
          'userRatingsTotal': 0,
        };
      }).toList();
    } else {
      print('  ✗ HTTP error: ${response.statusCode}');
      return [];
    }
  }

  /// Get readable description based on place type
  static String _getDescription(Map<String, dynamic> place) {
    final type = place['type']?.toString() ?? '';
    final shopClass = place['class']?.toString() ?? '';

    if (type.contains('pharmacy')) return 'Pharmacy / Medical Store';
    if (type.contains('agriculture')) return 'Agricultural Supply';
    if (type.contains('pesticide')) return 'Pesticide Store';
    if (type.contains('fertilizer')) return 'Fertilizer Shop';
    if (type.contains('hardware')) return 'Hardware Store';
    if (type.contains('marketplace')) return 'Local Marketplace';
    if (type.contains('farmland')) return 'Agricultural Area';
    if (type.contains('university')) return 'Agriculture University';
    if (shopClass == 'shop') return 'General Store';

    return 'Agricultural Supply Store';
  }

  /// Get readable name from type when name is missing
  static String _getNameFromType(String type) {
    if (type.contains('pharmacy')) return 'Pharmacy';
    if (type.contains('agriculture')) return 'Agriculture Store';
    if (type.contains('pesticide')) return 'Pesticide Shop';
    if (type.contains('fertilizer')) return 'Fertilizer Store';
    if (type.contains('hardware')) return 'Hardware Store';
    if (type.contains('marketplace')) return 'Marketplace';
    return 'Local Shop';
  }

  /// Calculate distance between two coordinates (in km)
  /// Using Haversine formula
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = (dLat / 2).abs() * (dLat / 2).abs() +
        (dLon / 2).abs() * (dLon / 2).abs();

    return earthRadius * 2 * a;
  }

  static double _toRadians(double degrees) {
    return degrees * 3.141592653589793 / 180;
  }
}