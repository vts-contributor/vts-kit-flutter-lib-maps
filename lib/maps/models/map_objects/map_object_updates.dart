import 'package:collection/collection.dart';

import 'map_object.dart';

class MapObjectUpdates {
  final Set<MapObject> removeObjects;

  ///will replace old objects
  late final Set<MapObject> updateObjects;

  ///ordered by zIndex ASC
  late final Set<MapObject> addObjects;

  MapObjectUpdates._(this.removeObjects, this.updateObjects, this.addObjects);

  ///zIndex order is expected be respected
  ///so when you use addObjects, you have to add in zIndex from low to high
  factory MapObjectUpdates.from(
      Set<MapObject> oldObjects, Set<MapObject> newObjects) {
    //to minimize some == operations on map objects.
    Set<String> oldIds = oldObjects.map((e) => e.id).toSet();
    Set<String> newIds = newObjects.map((e) => e.id).toSet();

    // ids which are in oldIds but not in newIds
    Set<String> removeIds = oldIds.where((id) => !newIds.contains(id)).toSet();
    Set<MapObject> removeObjects =
        oldObjects.where((element) => removeIds.contains(element.id)).toSet();

    // ids which are not in oldIds but in newIds
    Set<String> addIds = newIds.where((id) => !oldIds.contains(id)).toSet();
    Set<MapObject> addObjects =
        newObjects.where((element) => addIds.contains(element.id)).toSet();

    // ids which are in both oldIds and newIds and newObject != oldObject
    Set<MapObject> updateObjects = newObjects.where((object) {
      final oldObject = oldObjects.firstWhereOrNull((e) => _sameIdTypeMapObject(e, object));
      if (oldObject != null) {
        return object != oldObject;
      } else {
        return false;
      }
    }).toSet();

    //----This section is for checking zIndex to ensure order of objects--------

    Set<MapObject> changedZIndexUpdateObjects = updateObjects.where((object) {
      final oldObject = oldObjects.firstWhereOrNull((e) =>
          _sameIdTypeMapObject(e, object));
      if (oldObject != null) {
        return oldObject.zIndex != object.zIndex;
      } else {
        return false;
      }
    }).toSet();

    //we have newObjects = addObjects + changedZIndexUpdateObjects
    //                      + (unChangedZIndexUpdateObjects + remainObjects)
    //For simplicity, all changedZIndexUpdateObjects will be redraw, so now we have:
    // addObjects += changedZIndexUpdateObjects
    //And we are just considering zIndex
    //    => so: unchangedZIndexObjects = unchangedZIndexUpdateObjects + remainObjects
    // => redrawing objects in unchangedZIndexUpdateObjects
    //        = those whose zIndex is larger than lower bound zIndex of addObjects

    //adding redrawn changedZIndexObjects
    removeObjects.addAll(changedZIndexUpdateObjects);
    addObjects.addAll(changedZIndexUpdateObjects);

    int? lowerBoundZIndex =
        minBy(addObjects, (object) => object.zIndex)?.zIndex;

    if (lowerBoundZIndex != null) {
      //objects that will stay the same after changes
      Set<MapObject> remainObjects = newObjects.where((object) {
        final oldObject = oldObjects.firstWhereOrNull((e) =>
            _sameIdTypeMapObject(e, object));
        return object == oldObject;
      }).toSet();

      //add unchanged zIndex updateObjects to remain objects
      Set<MapObject> unChangedZIndexUpdateObjects = updateObjects.where((object) {
        final oldObject = oldObjects.firstWhereOrNull((e) =>
            _sameIdTypeMapObject(e, object));
        return oldObject == object;
      }).toSet();

      //add all unchanged zIndex objects
      final unchangedZIndexObjects = unChangedZIndexUpdateObjects..addAll(remainObjects);

      Set<MapObject> redrawingObjects = unchangedZIndexObjects
          .where((object) => object.zIndex > lowerBoundZIndex)
          .toSet();

      removeObjects.addAll(redrawingObjects);
      addObjects.addAll(redrawingObjects);

      updateObjects.removeAll(redrawingObjects);
    }

    //remove redrawing objects HERE to make sure check zIndex code run correctly
    updateObjects.removeAll(changedZIndexUpdateObjects);

    return MapObjectUpdates._(removeObjects, updateObjects, addObjects);
  }

  static bool _sameIdTypeMapObject(MapObject o1, MapObject o2) {
    return o1.id == o2.id && o1.runtimeType == o2.runtimeType;
  }
}
