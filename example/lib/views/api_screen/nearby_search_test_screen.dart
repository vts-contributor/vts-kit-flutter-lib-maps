import 'package:flutter/material.dart';
import 'package:map_core_example/views/widgets/api_result_display.dart';
import 'package:maps_core/maps/services/maps_api_service_impl.dart';
import 'package:map_core_example/config/api_config.dart';

import 'package:maps_core/maps/constants.dart';

class NearbyPlaceTestScreen extends StatefulWidget {
  static String routeName = "nearby-place-test-screen";
  const NearbyPlaceTestScreen({Key? key}) : super(key: key);

  @override
  State<NearbyPlaceTestScreen> createState() => _NearbyPlaceTestScreenState();
}

class _NearbyPlaceTestScreenState extends State<NearbyPlaceTestScreen> {
  final _latController = TextEditingController(text: "10.7833088");
  final _lngController = TextEditingController(text: "106.6826767");
  final _radiusController = TextEditingController(text: "1000");
  final _keywordController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _results = {};


  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _fetchNearbyPlaces() async {
    if (_latController.text.isEmpty ||
        _lngController.text.isEmpty ||
        _radiusController.text.isEmpty) {
      setState(() {
        _error = 'Please enter all required fields';
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
        provider: MapProviderConst.GOOGLE,
      );

      final nearbyPlaces = await service.nearbySearch(
        lat: double.parse(_latController.text),
        lng: double.parse(_lngController.text),
        radius: int.parse(_radiusController.text),
        keyword: _keywordController.text.isNotEmpty ? _keywordController.text : null,
      );

      final results = nearbyPlaces.toJson();

      setState(() {
        _results = results;
        _error = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
        title: const Text('Nearby Places API Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInputFields(),
          const SizedBox(height: 16),
          _buildButtons(),
          const SizedBox(height: 16),
          _buildResults(),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _latController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _lngController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _radiusController,
          decoration: const InputDecoration(
            labelText: 'Radius (meters)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _keywordController,
          decoration: const InputDecoration(
            labelText: 'Keyword (optional)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _fetchNearbyPlaces,
      child: const Text('Fetch Nearby Places'),
    );
  }

  Widget _buildResults() {
    return ApiResultDisplay(
      title: 'Results',
      data: _results,
      isLoading: _isLoading,
      errorMessage: _error,
    );
  }
}
