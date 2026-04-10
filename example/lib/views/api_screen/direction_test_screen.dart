import 'package:flutter/material.dart';
import 'package:map_core_example/views/widgets/api_result_display.dart';
import 'package:maps_core/maps/services/maps_api_service_impl.dart';
import 'package:map_core_example/config/api_config.dart';

import 'package:maps_core/maps/constants.dart';

class DirectionsTestScreen extends StatefulWidget {
  static String routeName = "directions-test-screen";
  const DirectionsTestScreen({Key? key}) : super(key: key);

  @override
  State<DirectionsTestScreen> createState() => _DirectionsTestScreenState();
}

class _DirectionsTestScreenState extends State<DirectionsTestScreen> {
  final _originLatController = TextEditingController(text: "10.7833088");
  final _originLngController = TextEditingController(text: "106.6826767");
  final _destLatController = TextEditingController(text: "10.7766347");
  final _destLngController = TextEditingController(text: "106.7007673");

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _results = [];

  @override
  void dispose() {
    _originLatController.dispose();
    _originLngController.dispose();
    _destLatController.dispose();
    _destLngController.dispose();
    super.dispose();
  }

  Future<void> _fetchDirections() async {
    if (_originLatController.text.isEmpty ||
        _originLngController.text.isEmpty ||
        _destLatController.text.isEmpty ||
        _destLngController.text.isEmpty) {
      setState(() {
        _error = 'Please enter all coordinates';
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

      final directions = await service.direction(
        originLat: double.parse(_originLatController.text),
        originLng: double.parse(_originLngController.text),
        destLat: double.parse(_destLatController.text),
        destLng: double.parse(_destLngController.text),
        alternatives: true,
      );

      final results = [
        {
          'routes': directions.routes?.map((r) => r.toJson()).toList(),
          'waypoints': directions.geocodedWaypoints?.map((w) => w.toJson()).toList(),
        }
      ];

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
        title: const Text('Directions API Test'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCoordinateFields(),
                const SizedBox(height: 16),
                _buildButtons(),
                const SizedBox(height: 16),
                _buildResults(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _originLatController,
                decoration: const InputDecoration(
                  labelText: 'Origin Latitude',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _originLngController,
                decoration: const InputDecoration(
                  labelText: 'Origin Longitude',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _destLatController,
                decoration: const InputDecoration(
                  labelText: 'Destination Latitude',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _destLngController,
                decoration: const InputDecoration(
                  labelText: 'Destination Longitude',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _fetchDirections,
      child: const Text('Fetch Directions'),
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
