
import 'package:flutter/material.dart';
import 'package:map_core_example/views/test_shapes.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps.dart';

class TestMapScreen extends StatefulWidget {
  
  static String routeName = "/test-map";
  
  const TestMapScreen({Key? key}) : super(key: key);

  @override
  State<TestMapScreen> createState() => _TestMapScreenState();
}

class _TestMapScreenState extends State<TestMapScreen> {

  final CoreMapControllerCompleter _controllerCompleter = CoreMapControllerCompleter();

  final CoreMapShapes _shapes = CoreMapShapes(
    polygons: {polygon1()}
  );

  CoreMapType _type = CoreMapType.viettel;

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.abc),
            onPressed: () async {
              final controller = await _controllerCompleter.controller;
              controller.animateCamera(CameraUpdate.newLatLngBounds(
                  LatLngBounds(northeast: const LatLng(10.844472, 106.673261),
                      southwest: const LatLng(10.83571439676659, 106.67236659058827)), 0));
            },
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () async {
              setState(() {
                _type = _type == CoreMapType.viettel? CoreMapType.google: CoreMapType.viettel;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final controller = await _controllerCompleter.controller;
              showDialog(
                context: context,
                builder: (context) {
                  return TestDialog(
                    controller: controller,
                    shapes: _shapes,
                    setState: () => setState(() {

                    }),
                  );
                }
              );
            },
          ),
        ],
      ),
      body: CoreMap(
        type: _type,
        data: CoreMapData(
          accessToken: "49013166841fe36d7fa7f395fce4a663",
          initialCameraPosition: CameraPosition(
              target: const LatLng(9.85419858085518, 105.49970250115466), zoom: 7),
          compassEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          myLocationButtonAlignment: Alignment.bottomRight,
        ),
        callbacks: CoreMapCallbacks(
          onMapCreated: (controller) {
            _controllerCompleter.complete(controller);
          },
          onCameraMove: (position) {
            Log.d("onCameraMove", position.toString());
          },
          // onCameraIdle: () => Log.d("onCameraIdle", ""),
          // onCameraMoveStarted: () => Log.d("onCameraMovingStarted", ""),
          onTap: (latLng) {
            Log.d("onTap", latLng.toString());
          },
          onLongPress: (latLng) {
            Log.d("onLongPress", latLng.toString());
          },
        ),
        shapes: CoreMapShapes(
          // polygons: {polygon1()},
          circles: {circle()},
          markers: {marker()},
          polylines: {polyline(), polyline2()},
        ),
      ),
    );
  }

  void findRoute() {

  }
}

class TestDialog extends StatefulWidget {
  final CoreMapController controller;
  final VoidCallback setState;
  final CoreMapShapes shapes;

  const TestDialog({super.key,
    required this.controller,
    required this.shapes,
    required this.setState,
  });

  @override
  State<TestDialog> createState() => _TestDialogState();
}

class _TestDialogState extends State<TestDialog> {


  double _zoomBy = 2;

  double _zoomTo = 7;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Test features"),
      alignment: Alignment.center,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      children: [
        Row(
          children: [
            ElevatedButton(onPressed: () {
              widget.shapes.polygons.add(polygon1());
              widget.setState();
            }, child: const Text("add a polygon")),
            const SizedBox(width: 10,),
            IconButton(onPressed: () {
              widget.shapes.polygons.removeWhere((element) => element.id == polygon1().id);
              widget.setState();
            }, icon: const Icon(Icons.delete),)
          ],
        ),
        Row(
          children: [
            ElevatedButton(onPressed: () {
              widget.shapes.polylines.add(polyline());
              widget.setState();
            }, child: const Text("add a polyline")),
            const SizedBox(width: 10,),
            IconButton(onPressed: () {
              widget.shapes.polylines.removeWhere((element) => element.id == polyline().id);
              widget.setState();
            }, icon: const Icon(Icons.delete),)
          ],
        ),
        Row(
          children: [
            ElevatedButton(onPressed: () {
              widget.shapes.circles.add(circle());
              widget.setState();
            }, child: const Text("add a circle")),
            const SizedBox(width: 10,),
            IconButton(onPressed: () {
              widget.shapes.circles.removeWhere((element) => element.id == circle().id);
              widget.setState();
            }, icon: const Icon(Icons.delete),)
          ],
        ),
        Row(
          children: [
            ElevatedButton(onPressed: () {
              widget.shapes.markers.add(marker());
              widget.setState();
            }, child: const Text("add a marker")),
            const SizedBox(width: 10,),
            IconButton(onPressed: () {
              widget.shapes.markers.removeWhere((element) => element.id == marker().id);
              widget.setState();
            }, icon: const Icon(Icons.delete),)
          ],
        ),
        Row(
          children: [
            ElevatedButton(onPressed: () async {
              Log.d("getScreenCoordinate",
                  (await widget.controller.getScreenCoordinate(
                      const LatLng(9.75419858085518, 105.59970250115466))
                  ).toString());
            }, child: const Text("Log screen coordinate")),
            const SizedBox(width: 10,),
          ],
        ),
        Row(
          children: [
            ElevatedButton(onPressed: () async {
              Log.d("getCurrentPosition",
                  (widget.controller.getCurrentPosition()).toString());
            }, child: const Text("Log camera position")),
            const SizedBox(width: 10,),
          ],
        ),
        Row(
          children: [
            const Text("zoom in/out"),
            const SizedBox(width: 10,),
            IconButton(
              onPressed: () {
                widget.controller.animateCamera(CameraUpdate.zoomIn());
              },
              icon: const Icon(Icons.zoom_in),
            ),
            const SizedBox(width: 10,),
            IconButton(
              onPressed: () {
                widget.controller.animateCamera(CameraUpdate.zoomOut());
              },
              icon: const Icon(Icons.zoom_out),
            )
          ],
        ),
        Row(
          children: [
            const Text("zoom by"),
            const SizedBox(width: 10,),
            SizedBox(
              height: 40,
              width: 40,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _zoomBy = double.parse(value);
                },
              ),
            ),
            const SizedBox(width: 10,),
            IconButton(
              icon: const Icon(Icons.skip_next_outlined),
              onPressed: () {
                widget.controller.animateCamera(CameraUpdate.zoomBy(_zoomBy));
              },
            )
          ],
        ),
        Row(
          children: [
            const Text("zoom to"),
            const SizedBox(width: 10,),
            SizedBox(
              height: 40,
              width: 40,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _zoomTo = double.parse(value);
                },
              ),
            ),
            const SizedBox(width: 10,),
            IconButton(
              icon: const Icon(Icons.skip_next_outlined),
              onPressed: () {
                widget.controller.animateCamera(CameraUpdate.zoomTo(_zoomTo));
              },
            )
          ],
        )
      ],
    );
  }
}
