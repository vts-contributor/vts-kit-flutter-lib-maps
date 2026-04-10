import 'package:flutter/material.dart';
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:map_core_example/views/widgets/api_result_display.dart';
import 'package:map_core_example/config/api_config.dart';

class GeocodeTestScreen extends StatefulWidget {
  static String routeName = "geocode-test-screen";
  const GeocodeTestScreen({Key? key}) : super(key: key);

  @override
  State<GeocodeTestScreen> createState() => _GeocodeTestScreenState();
}

class _GeocodeTestScreenState extends State<GeocodeTestScreen> {
  final _latController = TextEditingController(text: '10.762622');
  final _lngController = TextEditingController(text: '106.660172');
  final _addressController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _results = [];

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _geocodeByCoordinates() async {
    _setLoading(true);

    try {
      final double lat = double.parse(_latController.text);
      final double lng = double.parse(_lngController.text);

      // Validate API keys
      ApiConfig.validateKeys();

      final service = MapsAPIServiceImpl(
        googleKey: ApiConfig.googleKey,
        provider: MapProviderConst.GOOGLE,
      );

      final result = (await service.geocode(
        lat: lat,
        lng: lng,
        paramsKeyMapper: {},
      )).map((e) => e.toJson()).toList();

      setState(() {
        _results = result;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
      });
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _geocodeByAddress() async {
    if (_addressController.text.isEmpty) {
      setState(() {
        _error = 'Please enter an address';
      });
      return;
    }

    // Validate API keys
    ApiConfig.validateKeys();

    _setLoading(true);

    try {
      final service = MapsAPIServiceImpl(
        googleKey: ApiConfig.googleKey,
        provider: MapProviderConst.GOOGLE,
      );

      final result = (await service.geocode(
        address: _addressController.text,
        paramsKeyMapper: {},
      )).map((e) => e.toJson()).toList();

      setState(() {
        _results = result;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
      });
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geocoding API Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCoordinatesCard(),
          const SizedBox(height: 16),
          _buildAddressCard(),
          const SizedBox(height: 16),
          ApiResultDisplay(
            title: 'Results',
            data: _results,
            isLoading: _isLoading,
            errorMessage: _error,
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Geocode by Coordinates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _latController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lngController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _geocodeByCoordinates,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 65, 95, 145),
                foregroundColor: Colors.white,
              ),
              child: const Text('Fetch Coordinates'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Geocode by Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _geocodeByAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 65, 95, 145),
                foregroundColor: Colors.white,
              ),
              child: const Text('Fetch Address'),
            ),
          ],
        ),
      ),
    );
  }
}
