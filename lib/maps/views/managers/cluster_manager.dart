part of core_map;

abstract class ClusterManager {
  int maxDistanceAtZoom = 25; // essentially 25 dp.

  ClusterData? customCluster(Cluster cluster, Set<Marker> setAllMarkerOfCluster);
}
