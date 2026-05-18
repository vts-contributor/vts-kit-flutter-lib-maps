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
  String provider = MapProviderConst.VIETTEL;
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _resultsViettel = [];
  List<Map<String, dynamic>> _resultsGoogle = [];

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
        viettelKey: ApiConfig.viettelKey,
        googleKey: ApiConfig.googleKey,
        provider: provider,
      );
      service.useProvider(provider);

      PlaceList<AutocompletePlace> placeList = await service.autocomplete(
        input: _queryController.text,
        radius: "500",
        location: "10.7833088, 106.6826767"
      );

      final results = placeList.values.map((e) => e.toJson()).toList();

      if (provider == MapProviderConst.GOOGLE) {
        _resultsGoogle = results;
      } else {
        _resultsViettel = results;
      }
      setState(() {
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }

    _setLoading(false);
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
            child: Expanded(
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
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                          setState(() {
                            provider = MapProviderConst.VIETTEL;
                          });
                          _fetchAutocompleteResults();
                        },
                        child: const Text('Search Viettel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                          setState(() {
                            provider = MapProviderConst.GOOGLE;
                          });
                          _fetchAutocompleteResults();
                        },
                        child: const Text('Search Google'),
                      ),
                    ],
                  ),
                  IntrinsicHeight(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 24, // Half the screen width minus padding
                            child: ApiResultDisplay(
                              title: 'Viettel Results',
                              data: _resultsViettel,
                              isLoading: provider == MapProviderConst.VIETTEL && _isLoading,
                              errorMessage: provider == MapProviderConst.VIETTEL ? _error : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 24, // Half the screen width minus padding
                            child:ApiResultDisplay(
                              title: 'Google Results',
                              data: _resultsGoogle,
                              isLoading: provider == MapProviderConst.GOOGLE && _isLoading,
                              errorMessage: provider == MapProviderConst.GOOGLE ? _error : null,
                            ),
                          ),
                        ],
                      ),
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
}