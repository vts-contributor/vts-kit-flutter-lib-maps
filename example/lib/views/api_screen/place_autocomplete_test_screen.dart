import 'package:flutter/material.dart';
import 'package:map_core_example/views/widgets/api_result_display.dart';
import 'package:maps_core/maps/models/place_autocomplete.dart';
import 'package:maps_core/maps/models/place_list.dart';
import 'package:maps_core/maps/services/maps_api_service_impl.dart';
import 'package:map_core_example/config/api_config.dart';

import 'package:maps_core/maps/constants.dart';

class PlaceAutocompleteTestScreen extends StatefulWidget {
  static String routeName = "place-autocomplete-test-screen";
  const PlaceAutocompleteTestScreen({Key? key}) : super(key: key);

  @override
  State<PlaceAutocompleteTestScreen> createState() =>
      _PlaceAutocompleteTestScreenState();
}

class _PlaceAutocompleteTestScreenState
    extends State<PlaceAutocompleteTestScreen> {
  final _queryController = TextEditingController(text: "Viettel Tower");
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _results = [];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _fetchAutocompleteResults() async {
    if (_queryController.text.isEmpty) {
      setState(() {
        _error = 'Please enter a query';
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

      PlaceList<AutocompletePlace> placeList = await service.autocomplete(
        input: _queryController.text,
        radius: "500",
        location: "10.7833088, 106.6826767"
      );

      final results = placeList.values.map((e) => e.toJson()).toList();

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
        title: const Text('Place Autocomplete Test'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    labelText: 'Query',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _fetchAutocompleteResults,
                  child: const Text('Fetch Autocomplete Results'),
                ),
                const SizedBox(height: 16),
                ApiResultDisplay(
                  title: 'Results',
                  data: _results,
                  isLoading: _isLoading,
                  errorMessage: _error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}