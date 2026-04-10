import 'package:flutter/material.dart';
import 'package:map_core_example/views/widgets/api_result_display.dart';
import 'package:maps_core/maps/models/models.dart';
import 'package:maps_core/maps/services/maps_api_service_impl.dart';
import 'package:map_core_example/config/api_config.dart';

import 'package:maps_core/maps/constants.dart';


class DistanceMatrixTestScreen extends StatefulWidget {
  static String routeName = "distance-matrix-test-screen";
  const DistanceMatrixTestScreen({Key? key}) : super(key: key);

  @override
  State<DistanceMatrixTestScreen> createState() => _DistanceMatrixTestScreenState();
}
class _DistanceMatrixTestScreenState extends State<DistanceMatrixTestScreen> {
  final _originLatController = TextEditingController(text: "40.6655101");
  final _originLngController = TextEditingController(text: "-73.8918897");

  // this is lat and lng 1 to 4
  // 40.659569%2C-73.933783%7C40.729029%2C-73.851524%7C40.6860072%2C-73.6334271%7C40.598566%2C-73.7527626

  final _dest1LatController = TextEditingController(text: "40.659569");
  final _dest1LngController = TextEditingController(text: "-73.933783");
  final _dest2LatController = TextEditingController(text: "40.729029");
  final _dest2LngController = TextEditingController(text: "-73.851524");
  final _dest3LatController = TextEditingController(text: "40.6860072");
  final _dest3LngController = TextEditingController(text: "-73.6334271");
  final _dest4LatController = TextEditingController(text: "40.598566");
  final _dest4LngController = TextEditingController(text: "-73.7527626");



  String provider = MapProviderConst.VIETTEL;
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _resultsViettel = [];
  List<Map<String, dynamic>> _resultsGoogle = [];
  RouteTravelMode _travelMode = RouteTravelMode.bycycling;


  @override
  void dispose() {
    _originLatController.dispose();
    _originLngController.dispose();
    _dest1LatController.dispose();
    _dest1LngController.dispose();
    _dest2LatController.dispose();
    _dest2LngController.dispose();
    _dest3LatController.dispose();
    _dest3LngController.dispose();
    _dest4LatController.dispose();
    _dest4LngController.dispose();
    super.dispose();
  }

  Future<void> _fetchDistanceMatrix() async {
    if (_originLatController.text.isEmpty ||
        _originLngController.text.isEmpty ||
        _dest1LatController.text.isEmpty ||
        _dest1LngController.text.isEmpty ||
        _dest2LatController.text.isEmpty ||
        _dest2LngController.text.isEmpty ||
        _dest3LatController.text.isEmpty ||
        _dest3LngController.text.isEmpty ||
        _dest4LatController.text.isEmpty ||
        _dest4LngController.text.isEmpty) {
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
        provider: provider,
      );

      final distanceMatrix = await service.getDistanceMatrix(
        origins: [
          LatLng(
            double.parse(_originLatController.text),
            double.parse(_originLngController.text),
          ),
        ],
        destinations: [
          LatLng(
            double.parse(_dest1LatController.text),
            double.parse(_dest1LngController.text),
          ),
          LatLng(
            double.parse(_dest2LatController.text),
            double.parse(_dest2LngController.text),
          ),
          LatLng(
            double.parse(_dest3LatController.text),
            double.parse(_dest3LngController.text),
          ),
          LatLng(
            double.parse(_dest4LatController.text),
            double.parse(_dest4LngController.text),
          ),
        ],
        travelMode: _travelMode,
      );

      final results = distanceMatrix.toJson();
      setState(() {
        if (provider == MapProviderConst.GOOGLE) {
          _resultsGoogle = [results];
        } else {
          _resultsViettel = [results];
        }
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }

    _setLoading(false);
  }

  Widget _buildCoordinateFields() {
    return Column(
      children: [
        Text('Origin', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildCoordinatePair(_originLatController, _originLngController, 'Origin'),
        const SizedBox(height: 16),
        Text('Destinations', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildCoordinatePair(_dest1LatController, _dest1LngController, 'Destination 1'),
        const SizedBox(height: 8),
        _buildCoordinatePair(_dest2LatController, _dest2LngController, 'Destination 2'),
        const SizedBox(height: 8),
        _buildCoordinatePair(_dest3LatController, _dest3LngController, 'Destination 3'),
        const SizedBox(height: 8),
        _buildCoordinatePair(_dest4LatController, _dest4LngController, 'Destination 4'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distance Matrix API Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCoordinateFields(),
          const SizedBox(height: 16),
          _buildTravelModeDropdown(),
          const SizedBox(height: 16),
          _buildButtons(),
          const SizedBox(height: 16),
          _buildResults(),
        ],
      ),
    );
  }

  Widget _buildCoordinatePair(TextEditingController latController, TextEditingController lngController, String label) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: latController,
            decoration: InputDecoration(
              labelText: '$label Latitude',
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: lngController,
            decoration: InputDecoration(
              labelText: '$label Longitude',
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTravelModeDropdown() {
    return DropdownButtonFormField<RouteTravelMode>(
      initialValue: _travelMode,
      decoration: const InputDecoration(
        labelText: 'Travel Mode',
        border: OutlineInputBorder(),
      ),
      items: RouteTravelMode.values.map((mode) {
        return DropdownMenuItem(
          value: mode,
          child: Text(mode.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _travelMode = value ?? RouteTravelMode.bycycling;
        });
      },
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
            _fetchDistanceMatrix();
          },
          child: const Text('Get Viettel Matrix'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
            setState(() {
              provider = MapProviderConst.GOOGLE;
            });
            _fetchDistanceMatrix();
          },
          child: const Text('Get Google Matrix'),
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

  void _setLoading(bool bool) {
    setState(() {
      _isLoading = bool;
    });
  }
}