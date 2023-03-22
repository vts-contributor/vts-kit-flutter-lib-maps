import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
                // final line = await controller?.addLine(LineOptions(
                //   geometry: [
                //     LatLng(10.015567019306467, 105.74686134987519),
                //     LatLng(10.19612670788822, 105.97871325750828),
                //     LatLng(10.651704727581484, 106.2319038895347),
                //     LatLng(10.781534156930388, 107.0149202769658),
                //     LatLng(11.447301198223213, 107.27501155457392),
                //   ],
                //   lineWidth: 5,
                //   lineColor: Colors.blueAccent.toHex(),
                //   draggable: true
                // ));
                Point<double> pa = Point(10.015567019306467, 105.74686134987519);
                Point<double> pb = Point(10.19612670788822, 105.97871325750828);

                Point<double> p1 = Point(lerpDouble(pa.x, pb.x, 0.2) ?? 0, lerpDouble(pa.y, pb.y, 0.2) ?? 0);
                Point<double> p2 = Point(lerpDouble(pa.x, pb.x, 0.4) ?? 0, lerpDouble(pa.y, pb.y, 0.4) ?? 0);
                Point<double> p3 = Point(lerpDouble(pa.x, pb.x, 0.6) ?? 0, lerpDouble(pa.y, pb.y, 0.6) ?? 0);
                Point<double> p4 = Point(lerpDouble(pa.x, pb.x, 0.8) ?? 0, lerpDouble(pa.y, pb.y, 0.8) ?? 0);

                controller?.addLine(LineOptions(
                  lineWidth: 10,
                  geometry: [
                    LatLng(pa.x, pa.y),
                    LatLng(p1.x, p1.y),
                  ]
                ));
                controller?.addLine(LineOptions(
                    lineWidth: 10,
                    geometry: [
                      LatLng(p2.x, p2.y),
                      LatLng(p3.x, p3.y),
                    ]
                ));

                controller?.addLine(LineOptions(
                    lineWidth: 10,
                    lineColor: Colors.blueAccent.toHex(),
                    geometry: [
                      LatLng(p4.x, p4.y),
                      LatLng(pb.x, pb.y),
                    ]
                ));

                // controller?.addLine(LineOptions(
                //     lineWidth: 10,
                //     geometry: [
                //       LatLng(p2.x, p2.y),
                //       LatLng(pb.x, pb.y),
                //     ]
                // ));
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
