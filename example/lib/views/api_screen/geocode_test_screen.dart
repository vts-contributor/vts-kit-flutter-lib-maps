import 'package:flutter/material.dart';
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/constants.dart';
import '../widgets/api_result_display.dart';
import 'package:maps_core/maps/services/maps_api_service_impl.dart';
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
  String provider = MapProviderConst.VIETTEL;

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _resultsViettel = [];
  List<Map<String, dynamic>> _resultsGoogle = [];

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _geocodeByCoordinates({String provider = MapProviderConst.VIETTEL}) async {
    _setLoading(true);

    try {
      final double lat = double.parse(_latController.text);
      final double lng = double.parse(_lngController.text);

      // Validate API keys
      ApiConfig.validateKeys();

      final service = MapsAPIServiceImpl(
        viettelKey: ApiConfig.viettelKey,
        googleKey: ApiConfig.googleKey,
        provider: provider,
      );

      List<Map<String, dynamic>> result;
      if (provider == MapProviderConst.VIETTEL) {
        service.useProvider(MapProviderConst.VIETTEL);
        result = (await service.geocode(
          lat: lat,
          lng: lng,
          paramsKeyMapper: {},
        )).map((e) => e.toJson()).toList();
        _resultsViettel = result;
      } else {
        service.useProvider(MapProviderConst.GOOGLE);
        result = (await service.geocode(
          lat: lat,
          lng: lng,
          paramsKeyMapper: {},
        )).map((e) => e.toJson()).toList();
        _resultsGoogle = result;
      }

      setState(() {
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

  Future<void> _geocodeByAddress({String provider = MapProviderConst.VIETTEL}) async {
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
        viettelKey: ApiConfig.viettelKey,
        googleKey: ApiConfig.googleKey,
        provider: provider,
      );

      List<Map<String, dynamic>> result;
      if (provider == MapProviderConst.VIETTEL) {
        service.useProvider(MapProviderConst.VIETTEL);
        result = (await service.geocode(
          address: _addressController.text,
          paramsKeyMapper: {},
        )).map((e) => e.toJson()).toList();
        _resultsViettel = result;
      } else {
        service.useProvider(MapProviderConst.GOOGLE);
        result = (await service.geocode(
          address: _addressController.text,
          paramsKeyMapper: {},
        )).map((e) => e.toJson()).toList();
        _resultsGoogle = result;
      }

      setState(() {
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
          IntrinsicHeight(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    child: ApiResultDisplay(
                      title: 'Results Viettel',
                      data: _resultsViettel,
                      isLoading: _isLoading,
                      errorMessage: _error,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    child: ApiResultDisplay(
                      title: 'Results Google',
                      data: _resultsGoogle,
                      isLoading: _isLoading,
                      errorMessage: _error,
                    ),
                  ),
                ],
              ),
            ),
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
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _geocodeByCoordinates(provider: MapProviderConst.VIETTEL),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 65, 95, 145),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Geocode Coordinates Viettel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _geocodeByCoordinates(provider: MapProviderConst.GOOGLE),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: const Color.fromARGB(255, 65, 95, 145),
                  ),
                  child: const Text('Geocode Coordinates Google'),
                ),
              ],
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
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _geocodeByAddress(provider: MapProviderConst.VIETTEL),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 65, 95, 145),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Geocode Address Viettel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _geocodeByAddress(provider: MapProviderConst.GOOGLE),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: const Color.fromARGB(255, 65, 95, 145),
                  ),
                  child: const Text('Geocode Address Google'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}