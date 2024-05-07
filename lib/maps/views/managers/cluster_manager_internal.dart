part of core_map;

abstract class _ClusterMarkerManagerInternal {
  void notifyCameraIdle(double zoom, Set<Marker>? markers, double maxZoomLevel);

  void createClusters(double zoom, Set<Marker>? markers, double maxZoomLevel);
}
