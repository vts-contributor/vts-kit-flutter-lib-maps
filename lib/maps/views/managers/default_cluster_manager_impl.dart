part of core_map;

class _DefaultClusterManager implements ClusterManager {
  @override
  int maxDistanceAtZoom = 25;

  @override
  ClusterData? customCluster(Cluster cluster, Set<Marker> setAllMarker) {
    Widget? custom = Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 241, 241),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4), 
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue, 
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: Text(
              setAllMarker.length.toString(),
              style: const TextStyle(fontSize: 20),
            ),
          ), // inner content
        ),
      ),
    );

    return ClusterData(
      icon: MarkerIcon.fromWidget('${cluster.id}icon', custom),
      expandOnTap: true,
    );
  }

  InfoWindow? customInfoWindowCluster(Set<MarkerCover> setMarker) {
    return InfoWindow(
      widget: Container(
        height: 50,
        width: 50,
        color: Colors.red,
        child: const Text("123"),
      ),
    );
  }
}
