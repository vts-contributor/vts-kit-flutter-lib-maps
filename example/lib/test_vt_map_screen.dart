import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maps_core/maps/models/geometry.dart';
import 'package:vtmap_gl/vtmap_gl.dart';

class TestVTMapScreen extends StatefulWidget {

  static String routeName = "/test-vt-map";

  const TestVTMapScreen({Key? key}) : super(key: key);

  @override
  State<TestVTMapScreen> createState() => _TestVTMapScreenState();
}

class _TestVTMapScreenState extends State<TestVTMapScreen> {
  MapboxMapController? controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                controller?.addFill(
                  FillOptions(geometry: [
                    [
                      LatLng(9.85419858085518, 105.49970250115466),
                      LatLng(10.111173278744552, 105.79221346758048),
                      LatLng(9.739171049977948, 106.4115676734868),
                      LatLng(9.408755662724216, 106.01194001513039),
                      LatLng(9.148388064993938, 105.04703715806114),
                    ],
                    [
                      LatLng(10.85419858085518, 105.49970250115466),
                      LatLng(11.111173278744552, 105.79221346758048),
                      LatLng(10.739171049977948, 106.4115676734868),
                      LatLng(10.408755662724216, 106.01194001513039),
                      LatLng(10.148388064993938, 105.04703715806114),
                    ],
                    // [
                    //   LatLng(9.749998867791605, 105.59033970201901),
                    //   LatLng(9.605997144751647, 105.67252492760872),
                    //   LatLng(9.575401419508188, 105.58270292414889)
                    // ],
                    // [
                    //   LatLng(9.861925859419564, 105.93872468331696),
                    //   LatLng(9.776638107960828, 106.03507919611933),
                    //   LatLng(9.683279273763315, 105.85380206186403)
                    // ],
                  ],
                    fillColor: "#FF0000",
                    fillOutlineColor: "#FF0000",
                    fillOpacity: 0.5,
                  ),
                );
                controller?.addFill(
                  FillOptions(geometry: [
                    // [
                    //   LatLng(9.85419858085518, 105.49970250115466),
                    //   LatLng(10.111173278744552, 105.79221346758048),
                    //   LatLng(9.739171049977948, 106.4115676734868),
                    //   LatLng(9.408755662724216, 106.01194001513039),
                    //   LatLng(9.148388064993938, 105.04703715806114),
                    // ],
                    [
                      LatLng(9.749998867791605, 105.59033970201901),
                      LatLng(9.605997144751647, 105.67252492760872),
                      LatLng(9.575401419508188, 105.58270292414889)
                    ],
                    [
                      LatLng(9.861925859419564, 105.93872468331696),
                      LatLng(9.776638107960828, 106.03507919611933),
                      LatLng(9.683279273763315, 105.85380206186403)
                    ],
                  ],
                    fillColor: "#FF0000",
                    fillOutlineColor: "#FF0000",
                    fillOpacity: 1,
                  ),
                );
              }
          )
        ],
      ),
      body: VTMap(
        accessToken: "49013166841fe36d7fa7f395fce4a663",
        initialCameraPosition:
        const CameraPosition(target: LatLng(9.823077422713277, 105.81830599510204),zoom: 6),
        onMapCreated: (controller) {
          this.controller = controller;
        },
      ),
    );
  }
}
