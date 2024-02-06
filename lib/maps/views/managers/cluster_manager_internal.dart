part of core_map;

abstract class _ClusterMarkerManagerInternal {
  void notifyCameraIdle(double zoom, Set<Marker>? markers);

  void createClusters(double zoom, Set<Marker>? markers);

  ClusterData? getCustomClusterData(
      Cluster cluster, Set<MarkerCover> setMarker);
}
