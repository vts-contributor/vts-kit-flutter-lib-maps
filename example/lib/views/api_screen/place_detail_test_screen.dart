import 'package:flutter/material.dart';
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/constants.dart';
import '../widgets/api_result_display.dart';
import 'package:maps_core/maps/services/maps_api_service_impl.dart';
import 'package:map_core_example/config/api_config.dart';

class PlaceDetailTestScreen extends StatefulWidget {
  static String routeName = "place-detail-test-screen";
  const PlaceDetailTestScreen({Key? key}) : super(key: key);

  @override
  State<PlaceDetailTestScreen> createState() => _PlaceDetailTestScreenState();
}

class _PlaceDetailTestScreenState extends State<PlaceDetailTestScreen> {
  final _placeIdGoogleController = TextEditingController(text: 'ChIJMfaNaSovdTER7H7koMW6Ql8');
  final _placeIdViettelController = TextEditingController(text: '65794a7762326c66615751694f6a457a4e4451774d6a4573496e4276615639306558426c496a6f7a4d58303d');
  String provider = MapProviderConst.VIETTEL;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _resultsViettel = {};
  Map<String, dynamic> _resultsGoogle = {};

  @override
  void dispose() {
    _placeIdViettelController.dispose();
    _placeIdGoogleController.dispose();
    super.dispose();
  }

  Future<void> _getPlaceDetails({String provider = MapProviderConst.VIETTEL}) async {
    if (_placeIdViettelController.text.isEmpty && provider == MapProviderConst.VIETTEL) {
      setState(() {
        _error = 'Please enter a Place ID';
      });
      return;
    }
    if (_placeIdGoogleController.text.isEmpty && provider == MapProviderConst.GOOGLE) {
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
        provider: provider,
      );

      Map<String, dynamic> result;
      if (provider == MapProviderConst.VIETTEL) {
        service.useProvider(MapProviderConst.VIETTEL);
        result = (await service.placeDetail(
          placeId: _placeIdViettelController.text,
          fields: ['name', 'formatted_address', 'geometry', 'rating', 'types', 'photos'],
          paramsKeyMapper: {},
        )).toJson();
        _resultsViettel = result;
      } else {
        service.useProvider(MapProviderConst.GOOGLE);
        result = (await service.placeDetail(
          placeId: _placeIdGoogleController.text,
          fields: ["*"],
          paramsKeyMapper: {},
        )).toJson();
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
        title: const Text('Place Detail API Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPlaceIdCard(),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 24, // Half the screen width minus padding
                    child: ApiResultDisplay(
                      title: 'Results Viettel',
                      data: _resultsViettel,
                      isLoading: _isLoading,
                      errorMessage: _error,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 24, // Half the screen width minus padding
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
              controller: _placeIdViettelController,
              decoration: const InputDecoration(
                labelText: 'Place ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _placeIdGoogleController,
              decoration: const InputDecoration(
                labelText: 'Place ID',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _getPlaceDetails(provider: MapProviderConst.VIETTEL),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 65, 95, 145),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Get Details Viettel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _getPlaceDetails(provider: MapProviderConst.GOOGLE),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: const Color.fromARGB(255, 65, 95, 145),
                  ),
                  child: const Text('Get Details Google'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}