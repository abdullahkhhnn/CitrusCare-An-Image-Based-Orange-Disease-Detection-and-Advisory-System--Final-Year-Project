import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';

class MapScreen extends StatefulWidget {
  final String disease;

  const MapScreen({super.key, required this.disease});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoading = true;
  bool _isFetchingShops = false;
  String _errorMessage = '';
  String _statusMessage = '';
  List<Map<String, dynamic>> _shops = [];
  bool _useRealData = false;

  // Default location (Peshawar, Pakistan)
  static const LatLng _defaultLocation = LatLng(34.0151, 71.5249);
  LatLng _centerLocation = _defaultLocation;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Get location with timeout
      Position? position = await LocationService.getCurrentLocation()
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              print('⏰ Timeout - using default location');
              return null;
            },
          );

      if (position != null) {
        setState(() {
          _currentPosition = position;
          _centerLocation = LatLng(
            position.latitude,
            position.longitude,
          );
        });
        print('✅ Location: ${position.latitude}, ${position.longitude}');
      } else {
        setState(() {
          _errorMessage = 'Using default location (Peshawar)';
        });
      }

      setState(() {
        _isLoading = false;
      });

      // Now fetch real shops in the background
      _fetchRealShops();
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _errorMessage = 'Error getting location';
        _shops = _getMockShops(_defaultLocation);
        _isLoading = false;
      });
    }
  }

  /// Fetch real shops from Nominatim API
  Future<void> _fetchRealShops() async {
    setState(() {
      _isFetchingShops = true;
      _statusMessage = 'Searching for nearby shops...';
    });

    try {
      print('🔍 Starting real shop search...');

      final realShops = await PlacesService.getNearbyShops(
        latitude: _centerLocation.latitude,
        longitude: _centerLocation.longitude,
      );

      if (realShops.isNotEmpty) {
        print('✅ Got ${realShops.length} real shops');
        setState(() {
          _shops = realShops;
          _useRealData = true;
          _isFetchingShops = false;
          _statusMessage = '';
        });
      } else {
        // Fallback to mock data if no real shops found
        print('⚠️ No real shops found - using mock data');
        setState(() {
          _shops = _getMockShops(_centerLocation);
          _useRealData = false;
          _isFetchingShops = false;
          _statusMessage = '';
        });
      }
    } catch (e) {
      print('❌ Error fetching shops: $e');
      setState(() {
        _shops = _getMockShops(_centerLocation);
        _useRealData = false;
        _isFetchingShops = false;
        _statusMessage = '';
      });
    }
  }

  /// Refresh shops (manual refresh)
  Future<void> _refreshShops() async {
    await _fetchRealShops();
  }

  /// Mock shops as fallback (when API fails)
  List<Map<String, dynamic>> _getMockShops(LatLng center) {
    return [
      {
        'id': 'shop_1',
        'name': 'Al-Rehman Agricultural Store',
        'address': 'Saddar Road, Peshawar',
        'description': 'Pesticides, Fertilizers, Seeds',
        'latitude': center.latitude + 0.01,
        'longitude': center.longitude + 0.01,
        'rating': 4.5,
        'userRatingsTotal': 128,
      },
      {
        'id': 'shop_2',
        'name': 'Khan Agro Services',
        'address': 'GT Road, Peshawar',
        'description': 'Insecticides, Fungicides, Seeds',
        'latitude': center.latitude - 0.015,
        'longitude': center.longitude + 0.008,
        'rating': 4.3,
        'userRatingsTotal': 95,
      },
      {
        'id': 'shop_3',
        'name': 'Punjab Agricultural Center',
        'address': 'Ring Road, Peshawar',
        'description': 'Fertilizers, Crop Protection',
        'latitude': center.latitude + 0.008,
        'longitude': center.longitude - 0.012,
        'rating': 4.1,
        'userRatingsTotal': 67,
      },
      {
        'id': 'shop_4',
        'name': 'Frontier Pesticides & Fertilizers',
        'address': 'Hayatabad, Peshawar',
        'description': 'Quality Agricultural Supplies',
        'latitude': center.latitude - 0.01,
        'longitude': center.longitude - 0.01,
        'rating': 4.6,
        'userRatingsTotal': 203,
      },
      {
        'id': 'shop_5',
        'name': 'Green Valley Farm Store',
        'address': 'University Road, Peshawar',
        'description': 'Complete Farming Solutions',
        'latitude': center.latitude + 0.012,
        'longitude': center.longitude - 0.005,
        'rating': 4.4,
        'userRatingsTotal': 156,
      },
    ];
  }

  void _goToCurrentLocation() {
    _mapController.move(_centerLocation, 14);
  }

  void _centerOnShop(Map<String, dynamic> shop) {
    final shopLocation = LatLng(shop['latitude'], shop['longitude']);
    _mapController.move(shopLocation, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Medicine Shops'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isFetchingShops ? null : _refreshShops,
            tooltip: 'Refresh shops',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading map...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Error message if any
                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.orange.shade50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Status banner (real data vs mock)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  color: _useRealData
                      ? Colors.green.shade50
                      : Colors.blue.shade50,
                  child: Row(
                    children: [
                      Icon(
                        _useRealData
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color: _useRealData
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _isFetchingShops
                              ? _statusMessage
                              : _useRealData
                                  ? 'Showing real shops near your location'
                                  : 'Showing nearby agricultural shops',
                          style: TextStyle(
                            fontSize: 11,
                            color: _useRealData
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                      if (_isFetchingShops)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),

                // OpenStreetMap (60% of screen)
                Expanded(
                  flex: 3,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _centerLocation,
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png', //api call for map tiles
                        userAgentPackageName: 'com.example.citruscare_app',
                      ),
                      MarkerLayer(
                        markers: [
                          // User location marker (blue)
                          Marker(
                            point: _centerLocation,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.blue,
                              size: 40,
                            ),
                          ),
                          // Shop markers (green)
                          ..._shops.map(
                            (shop) => Marker(
                              point: LatLng(
                                shop['latitude'],
                                shop['longitude'],
                              ),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) =>
                                        _buildShopBottomSheet(shop),
                                  );
                                },
                                child: const Icon(
                                  Icons.store,
                                  color: Colors.green,
                                  size: 36,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Shop list (40% of screen)
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        color: Colors.green,
                        child: Text(
                          '${_shops.length} Nearby Agricultural Shops',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Shop list
                      Expanded(
                        child: _shops.isEmpty
                            ? const Center(
                                child: Text(
                                  'No shops found nearby',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _shops.length,
                                padding: const EdgeInsets.all(8),
                                itemBuilder: (context, index) {
                                  return _buildShopCard(_shops[index]);
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                // Bottom buttons
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _goToCurrentLocation,
                          icon: const Icon(Icons.my_location, size: 18),
                          label: const Text(
                            'My Location',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text(
                            'Back',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop) {
    final rating = (shop['rating'] ?? 0.0) as double;
    final reviewCount = shop['userRatingsTotal'] ?? 0;
    final hasRating = rating > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 1,
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.store,
            color: Colors.green,
            size: 22,
          ),
        ),
        title: Text(
          shop['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shop['address'],
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (hasRating)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    '$rating ($reviewCount)',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              )
            else
              Text(
                shop['description'] ?? '',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: Colors.grey,
        ),
        onTap: () => _centerOnShop(shop),
      ),
    );
  }

  // Bottom sheet shown when shop marker is tapped
  Widget _buildShopBottomSheet(Map<String, dynamic> shop) {
    final rating = (shop['rating'] ?? 0.0) as double;
    final reviewCount = shop['userRatingsTotal'] ?? 0;
    final hasRating = rating > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.green,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      shop['address'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            shop['description'],
            style: const TextStyle(fontSize: 14),
          ),
          if (hasRating) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$rating ($reviewCount reviews)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}