part of core_map;

abstract class ClusterManager {
  // Clustering based on maximum distance when zoom
  int maxDistanceAtZoom = 25; // essentially 25 dp.

    ///try to break cluster at max zoom level
  bool isTryBreakCluster = false;

  ClusterData? customCluster({required Cluster cluster, required Set<Marker> setAllMarkerOfCluster});
}
