import 'package:maps_core/maps.dart';

class CoreMapControllerWrapper implements CoreMapController {
  late CoreMapController _innerController;

  String? selectedMarkerId, previousSelectedMarkerId;

  set innerController(CoreMapController value) {
    _innerController = value;
  }

  @override
  Future<void> animateCamera(CameraUpdate cameraUpdate, {int? duration}) {
    return _innerController.animateCamera(cameraUpdate, duration: duration);
  }

  @override
  CameraPosition getCurrentPosition() {
    return _innerController.getCurrentPosition();

  }

  @override
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) {
    return _innerController.getLatLng(screenCoordinate);
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) {
    return _innerController.getScreenCoordinate(latLng);
  }

  @override
  Future<void> hideInfoWindow(MarkerId markerId) {
    return _innerController.hideInfoWindow(markerId);
  }

  @override
  Future<void> moveCamera(CameraUpdate cameraUpdate) {
    return _innerController.moveCamera(cameraUpdate);
  }

  @override
  void onMarkerTapSetInfoWindow(MarkerId markerId) {
    return _innerController.onMarkerTapSetInfoWindow(markerId);
  }

  @override
  Future<void> showInfoWindow(MarkerId markerId) {
    return _innerController.showInfoWindow(markerId);
  }

  @override
  Future<void> onClickMaker(Marker marker) async {
    if(selectedMarkerId != marker.id.value) {
      previousSelectedMarkerId = selectedMarkerId;
      selectedMarkerId = marker.id.value;
      notifyChange();
    }
  }

  Set<Marker> detectSelectedMarker(Set<Marker> markers){
    if(selectedMarkerId != null || previousSelectedMarkerId != null) {
      Marker? clickedMarker, currentClickedMarker;
      for (Marker marker in markers) {
        if (previousSelectedMarkerId != null &&
            marker.id.value == previousSelectedMarkerId) {
          currentClickedMarker = marker;
        }
        if (selectedMarkerId != null && marker.id.value == selectedMarkerId ) {
          clickedMarker = marker;
        }
        if (clickedMarker != null && currentClickedMarker != null) {
          break;
        }
      }
      if (currentClickedMarker?.id.value != clickedMarker?.id.value) {
        if (currentClickedMarker != null) {
          Marker unselectedMarker = currentClickedMarker.copyWith(isSelectedParam: false);
          markers.remove(currentClickedMarker);
          markers.add(unselectedMarker);
        }
        if (clickedMarker != null) {
          Marker selectedMarker = clickedMarker.copyWith(isSelectedParam: true);
          markers.remove(clickedMarker);
          markers.add(selectedMarker);
        }
      }
    }
    return markers;
  }

  @override
  void notifyChange() {
    _innerController.notifyChange();
  }
}