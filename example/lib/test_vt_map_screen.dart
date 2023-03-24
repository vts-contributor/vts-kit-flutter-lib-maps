import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/extensions/extensions.dart';
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
                final ByteData bytes = await rootBundle.load(Constant.markerDefaultAssetPath);
                final Uint8List list = bytes.buffer.asUint8List();
                await controller?.addImage(Constant.markerDefaultName, list);
                controller?.addSymbol(SymbolOptions(
                  iconImage: Constant.markerDefaultName,
                  geometry: LatLng(9.823077422713277, 105.81830599510204),
                  iconSize: 0.1,
                  textField: "ssssssssssssssssssssssssadada",
                  textSize: 100
                ));
              }
          )
        ],
      ),
      body: VTMap(
        accessToken: "49013166841fe36d7fa7f395fce4a663",
        initialCameraPosition:
        const CameraPosition(target: LatLng(9.823077422713277, 105.81830599510204),zoom: 10),
        onMapCreated: (controller) {
          this.controller = controller;
        },
      ),
    );
  }
}
