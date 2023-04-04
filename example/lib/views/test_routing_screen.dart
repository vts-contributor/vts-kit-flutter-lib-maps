import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map_core_example/view_models/routing_view_model.dart';
import 'package:provider/provider.dart';

class TestRoutingScreen extends StatefulWidget {
  static const String routeName = "/test-routing-screen";
  const TestRoutingScreen({Key? key}) : super(key: key);

  @override
  State<TestRoutingScreen> createState() => _TestRoutingScreenState();
}

class _TestRoutingScreenState extends State<TestRoutingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () async {
            final directions = await Provider.of<RoutingViewModel>(context, listen: false).downloadDirections();
            debugPrint(directions.toString());
          }, icon: Icon(Icons.download))
        ],
      ),
    );
  }
}
