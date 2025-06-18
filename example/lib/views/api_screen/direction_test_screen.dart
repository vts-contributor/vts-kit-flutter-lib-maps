import 'package:flutter/material.dart';
import 'package:map_core_example/views/widgets/api_result_display.dart';
import 'package:maps_core/maps/services/maps_api_service_impl.dart';
import 'package:map_core_example/config/api_config.dart';

import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/models/directions.dart';
import 'package:maps_core/maps/models/models.dart';


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

  String provider = MapProviderConst.VIETTEL;
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _resultsViettel = [];
  List<Map<String, dynamic>> _resultsGoogle = [];

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

      final service = MapsAPIServiceImpl(
        viettelKey: ApiConfig.viettelKey,
        googleKey: ApiConfig.googleKey,
        provider: provider,

      );
      service.useProvider(provider);

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
        if (provider == MapProviderConst.GOOGLE) {
          _resultsGoogle = results;
        } else {
          _resultsViettel = results;
        }
        _error = null;
      });
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
    return Row(
      children: [
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
            setState(() {
              provider = MapProviderConst.VIETTEL;
            });
            _fetchDirections();
          },
          child: const Text('Get Viettel Directions'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
            setState(() {
              provider = MapProviderConst.GOOGLE;
            });
            _fetchDirections();
          },
          child: const Text('Get Google Directions'),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return IntrinsicHeight(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 24,
              child: ApiResultDisplay(
                title: 'Viettel Results',
                data: _resultsViettel,
                isLoading: provider == MapProviderConst.VIETTEL && _isLoading,
                errorMessage: provider == MapProviderConst.VIETTEL ? _error : null,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 24,
              child: ApiResultDisplay(
                title: 'Google Results',
                data: _resultsGoogle,
                isLoading: provider == MapProviderConst.GOOGLE && _isLoading,
                errorMessage: provider == MapProviderConst.GOOGLE ? _error : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}