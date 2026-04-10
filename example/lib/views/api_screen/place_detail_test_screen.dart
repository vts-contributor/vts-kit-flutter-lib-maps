import 'package:flutter/material.dart';
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:map_core_example/views/widgets/api_result_display.dart';
import 'package:map_core_example/config/api_config.dart';

class PlaceDetailTestScreen extends StatefulWidget {
  static String routeName = "place-detail-test-screen";
  const PlaceDetailTestScreen({Key? key}) : super(key: key);

  @override
  State<PlaceDetailTestScreen> createState() => _PlaceDetailTestScreenState();
}

class _PlaceDetailTestScreenState extends State<PlaceDetailTestScreen> {
  final _placeIdController = TextEditingController(text: 'ChIJMfaNaSovdTER7H7koMW6Ql8');

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _results = {};

  @override
  void dispose() {
    _placeIdController.dispose();
    super.dispose();
  }

  Future<void> _getPlaceDetails() async {
    if (_placeIdController.text.isEmpty) {
      setState(() {
        _error = 'Please enter a Place ID';
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

      final result = (await service.placeDetail(
        placeId: _placeIdController.text,
        fields: ["name", "formattedAddress", "location", "rating", "types", "photos"],
        paramsKeyMapper: {},
      )).toJson();

      setState(() {
        _results = result;
        _error = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
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
        title: const Text('Place Detail API Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPlaceIdCard(),
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

  Widget _buildPlaceIdCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get Place Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _placeIdController,
              decoration: const InputDecoration(
                labelText: 'Place ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _getPlaceDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 65, 95, 145),
                foregroundColor: Colors.white,
              ),
              child: const Text('Fetch Details'),
            ),
          ],
        ),
      ),
    );
  }
}
