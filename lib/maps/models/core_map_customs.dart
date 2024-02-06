import 'package:maps_core/maps.dart';

class CoreMapCustoms {
  CoreMapCustoms({this.clusterManager});

  ///Custom cluster
  final ClusterManager? clusterManager;

  CoreMapCustoms copyWith({final ClusterManager? clusterManagerParam}) {
    return CoreMapCustoms(
      clusterManager: clusterManagerParam ?? clusterManager,
    );
  }
}
