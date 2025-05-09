import 'package:flutter/material.dart';
import 'package:map_core_example/views/api_screen/direction_test_screen.dart';
import 'package:map_core_example/views/api_screen/distance_matrix_test_screen.dart';
import 'package:map_core_example/views/api_screen/geocode_test_screen.dart';
import 'package:map_core_example/views/api_screen/nearby_search_test_screen.dart';
import 'package:map_core_example/views/api_screen/place_autocomplete_test_screen.dart';
import 'package:map_core_example/views/api_screen/place_detail_test_screen.dart';
import 'package:map_core_example/views/widgets/api_test_card.dart';

// import 'autocomplete_test_screen.dart';
// import 'nearby_search_test_screen.dart';
// import 'directions_test_screen.dart';
// import 'distance_matrix_test_screen.dart';

class ApiTestScreen extends StatelessWidget {
  static String routeName = "api-test-screen";
  const ApiTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps API Tests'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ApiTestCard(
              title: 'Geocoding API',
              description: 'Convert coordinates to addresses and vice versa',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GeocodeTestScreen()),
              ),
            ),
            ApiTestCard(
              title: 'Place Detail API',
              description: 'Get detailed information about a place',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PlaceDetailTestScreen()),
              ),
            ),
            ApiTestCard(
              title: 'Autocomplete API',
              description: 'Get place predictions as you type',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlaceAutocompleteTestScreen()),
              ),
            ),
            ApiTestCard(
              title: 'Nearby Search API',
              description: 'Find places near a location',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NearbyPlaceTestScreen()),
              ),
            ),
            ApiTestCard(
              title: 'Directions API',
              description: 'Get directions between locations',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DirectionsTestScreen()),
              ),
            ),
            ApiTestCard(
              title: 'Distance Matrix API',
              description: 'Get travel distances and times',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DistanceMatrixTestScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
