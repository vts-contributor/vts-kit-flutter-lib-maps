part of core_map;

class _CoreGoogleMap extends StatefulWidget {

  final CoreMapData data;

  final CoreMapShapes shapes;

  final CoreMapCallbacks? callbacks;

  final MarkerIconDataFactory markerIconDataFactory;

  final InfoWindowManager infoWindowManager;

  const _CoreGoogleMap({Key? key,
    required this.data,
    this.callbacks,
    required this.shapes,
    required this.markerIconDataFactory,
    required this.infoWindowManager,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CoreGoogleMapState();
}

class _CoreGoogleMapState extends State<_CoreGoogleMap> {

  _GoogleMapController? _controller;

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
        final controller = _GoogleMapController(googleMapController,
          data: widget.data,
          callbacks: widget.callbacks,
          markerIconDataProcessor: widget.markerIconDataFactory,
          bitmapCacheFactory: widget.markerIconDataFactory,
          infoWindowManager: widget.infoWindowManager,
        );

        controller.addListener(() => setState(() {}));

        controller.updateMarkers(widget.shapes.markers);

        _controller = controller;
        widget.callbacks?.onMapCreated?.call(controller);
      },
      gestureRecognizers: widget.data.gestureRecognizers,
      cameraTargetBounds: widget.data.cameraTargetBounds.toGoogle(),
      minMaxZoomPreference: widget.data.minMaxZoomPreference.toGoogle(),
      compassEnabled: widget.data.compassEnabled,
      rotateGesturesEnabled: widget.data.rotateGesturesEnabled,
      scrollGesturesEnabled: widget.data.scrollGesturesEnabled,
      zoomGesturesEnabled: widget.data.zoomGesturesEnabled,
      tiltGesturesEnabled: widget.data.tiltGesturesEnabled,
      myLocationEnabled: widget.data.myLocationEnabled,
      myLocationButtonEnabled: false,

      zoomControlsEnabled: false,

      polygons: widget.shapes.polygons.toGoogle(),
      polylines:  widget.shapes.polylines.toGoogle(),
      circles:  widget.shapes.circles.toGoogle(),
      markers:  widget.shapes.markers.toGoogle(widget.markerIconDataFactory),
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


