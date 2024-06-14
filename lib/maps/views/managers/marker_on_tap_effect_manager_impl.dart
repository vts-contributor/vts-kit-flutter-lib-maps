part of core_map;

class _MarkerOnTapEffectManagerImpl extends ChangeNotifier implements MarkerOnTapEffectManager {
  String? selectedMarkerId, previousSelectedMarkerId;

  @override
  Future<void> onClickMaker(Marker marker) async {
    if (selectedMarkerId != marker.id.value) {
      previousSelectedMarkerId = selectedMarkerId;
      selectedMarkerId = marker.id.value;
      notifyListeners();
    }
  }

  @override
  CoreMapShapes modifyShapes(CoreMapShapes? original) {
    if (original != null) {
      Set<Marker> markers = original.markers;
      if (selectedMarkerId != null || previousSelectedMarkerId != null) {
        Marker? clickedMarker, currentClickedMarker;
        for (Marker marker in markers) {
          if (previousSelectedMarkerId != null &&
              marker.id.value == previousSelectedMarkerId) {
            currentClickedMarker = marker;
          }
          if (selectedMarkerId != null && marker.id.value == selectedMarkerId) {
            clickedMarker = marker;
          }
          if (clickedMarker != null && currentClickedMarker != null) {
            break;
          }
        }

        if (currentClickedMarker?.id.value != clickedMarker?.id.value) {
          if (currentClickedMarker != null) {
            Marker unselectedMarker =
            currentClickedMarker.copyWith(
              iconParam: MarkerIcon.scale(currentClickedMarker.icon, Constant.defaultMarkerScale),
            );
            markers.remove(currentClickedMarker);
            markers.add(unselectedMarker);
          }
          if (clickedMarker != null) {
            Marker selectedMarker = clickedMarker.copyWith(
              iconParam: MarkerIcon.scale(clickedMarker.icon, clickedMarker.clickScale),
            );
            markers.remove(clickedMarker);
            markers.add(selectedMarker);
          }
        }
      }
      return original.copyWith(markers: markers.map((e) => e.copyWith(
            onTapParam: () {
              e.onTap?.call();
              onClickMaker(e);
            }
        )).toSet());
    } else {
      return original ?? CoreMapShapes();
    }
  }

}