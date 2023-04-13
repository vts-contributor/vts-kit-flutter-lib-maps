part of 'core_map.dart';

class _CoreGoogleMap extends StatefulWidget {

  final CoreMapData data;

  final CoreMapShapes shapes;

  final CoreMapCallbacks? callbacks;

  const _CoreGoogleMap({Key? key,
    required this.data,
    this.callbacks,
    required this.shapes,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CoreGoogleMapState();
}

class _CoreGoogleMapState extends State<_CoreGoogleMap> {

  GoogleMapController? _controller;

  final MarkerIconDataFactory _markerIconDataFactory = MarkerIconDataFactory();

  @override
  void didUpdateWidget(covariant _CoreGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateCallbacks();
    _updateMarkers();
  }

  void _updateCallbacks() {
    _controller?.callbacks = widget.callbacks;
  }

  ///update marker icon data
  void _updateMarkers() {
    _controller?.updateMarkers(widget.shapes.markers);
  }

  @override
  Widget build(BuildContext context) {
    return gg.GoogleMap(
      initialCameraPosition: widget.data.initialCameraPosition.toGoogle(),
      onMapCreated: (gg.GoogleMapController googleMapController) {
        //reminder: check leak here, may happen because of passing method?
        final controller = GoogleMapController(googleMapController,
          data: widget.data,
          callbacks: widget.callbacks,
          markerIconDataProcessor: _markerIconDataFactory,
        );

        controller.addListener(() => setState(() {}));

        controller.updateMarkers(widget.shapes.markers);

        _controller = controller;
        widget.callbacks?.onMapCreated?.call(controller);
      },
      cameraTargetBounds: widget.data.cameraTargetBounds.toGoogle(),
      minMaxZoomPreference: widget.data.minMaxZoomPreference.toGoogle(),
      compassEnabled: widget.data.compassEnabled,
      rotateGesturesEnabled: widget.data.rotateGesturesEnabled,
      scrollGesturesEnabled: widget.data.scrollGesturesEnabled,
      zoomGesturesEnabled: widget.data.zoomGesturesEnabled,
      tiltGesturesEnabled: widget.data.tiltGesturesEnabled,
      myLocationEnabled: widget.data.myLocationEnabled,

      zoomControlsEnabled: false,

      polygons: widget.shapes.polygons.toGoogle(),
      polylines:  widget.shapes.polylines.toGoogle(),
      circles:  widget.shapes.circles.toGoogle(),
      markers:  widget.shapes.markers.toGoogle(_markerIconDataFactory),
      onCameraMove: (position) {
        _controller?.onCameraMove(position);
      },
      onCameraIdle: () {
        widget.callbacks?.onCameraIdle?.call();
      },
      onCameraMoveStarted: () {
        widget.callbacks?.onCameraMoveStarted?.call();
      },
      onTap: (latLng) {
        widget.callbacks?.onTap?.call(latLng.toCore());
      },
      onLongPress: (latLng) {
        widget.callbacks?.onLongPress?.call(latLng.toCore());
      },
    );
  }

}


