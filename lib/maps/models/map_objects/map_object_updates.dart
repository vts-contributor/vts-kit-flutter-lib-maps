import 'package:collection/collection.dart';

import 'map_object.dart';

class MapObjectUpdates {
  final Set<String> removeIds;
  late final Set<String> updateIds;
  late final Set<String> addIds;

  MapObjectUpdates._(this.removeIds, this.updateIds, this.addIds);

  factory MapObjectUpdates.from(Set<MapObject> oldObjects, Set<MapObject> newObjects) {
    Set<String> oldIds = oldObjects.map((e) => e.id).toSet();
    Set<String> newIds = newObjects.map((e) => e.id).toSet();

    // ids which are in oldIds but not in newIds
    Set<String> removeIds = oldIds.where((id) => !newIds.contains(id)).toSet();

    // ids which are not in oldIds but in newIds
    Set<String> addIds = newIds.where((id) => !oldIds.contains(id)).toSet();

    // ids which are in both oldIds and newIds and newObject != oldObject
    Set<String> updateIds = oldObjects.where((object) {
      final newObject = newObjects.firstWhereOrNull((e) => e.id == object.id);
      return object != newObject;
    }).map((e) => e.id).toSet();

    return MapObjectUpdates._(removeIds, updateIds, addIds);
  }
}