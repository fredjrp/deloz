import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // String? _platformVersion;
  String _instruction = "";
  final _origin = WayPoint(
      name: "Way Point 1",
      latitude: 38.9111117447887,
      longitude: -77.04012393951416);
  final _stop1 = WayPoint(
      name: "Way Point 2",
      latitude: 38.9111117447887,
      longitude: -77.04012393951416);
  final _stop2 = WayPoint(
      name: "Way Point 3",
      latitude: 38.910662123296635,
      longitude: -77.03855156898499);
  final _stop3 = WayPoint(
      name: "Way Point 4",
      latitude: 38.909650771013034,
      longitude: -77.03510105609894);
  final _stop4 = WayPoint(
      name: "Way Point 5",
      latitude: 38.90894943542985,
      longitude: -77.0365172624588);

  // MapBoxNavigationViewController? _controller;
  late MapBoxOptions _navigationOption;

  double? _distanceRemaining, _durationRemaining;
  // bool _routeBuilt = false;
  // bool _isNavigating = false;
  // bool _arrived = false;
  late MapBoxNavigation _directions;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initialize() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _directions = MapBoxNavigation.instance;

    _navigationOption = MapBoxNavigation.instance.getDefaultOptions()
        .copyWith(
            initialLatitude: 36.1175275,
            initialLongitude: -115.1839524,
            zoom: 13.0,
            tilt: 0.0,
            bearing: 0.0,
            enableRefresh: false,
            alternatives: true,
            voiceInstructionsEnabled: true,
            bannerInstructionsEnabled: true,
            allowsUTurnAtWayPoints: true,
            mode: MapBoxNavigationMode.drivingWithTraffic,
            units: VoiceUnits.imperial,
            simulateRoute: true,
            language: "en");

    _directions.registerRouteEventListener(_onRouteEvent);

    setState(() {
      // _platformVersion = 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mapbox Navigation MVP'),
        ),
        body: Center(
          child: Column(children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text("Instruction: $_instruction"),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                        "Distance Remaining: ${_distanceRemaining?.toStringAsFixed(2)}"),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                        "Duration Remaining: ${_durationRemaining?.toStringAsFixed(2)}"),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      child: const Text("Start Navigation"),
                      onPressed: () async {
                        var wayPoints = <WayPoint>[];
                        wayPoints.add(_origin);
                        wayPoints.add(_stop1);
                        wayPoints.add(_stop2);
                        wayPoints.add(_stop3);
                        wayPoints.add(_stop4);
                        wayPoints.add(_origin);

                        await MapBoxNavigation.instance
                            .startNavigation(wayPoints: wayPoints);
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.grey,
                      width: double.infinity,
                      height: 300,
                      child: MapBoxNavigationView(
                          options: _navigationOption,
                          onRouteEvent: _onRouteEvent,
                          onCreated:
                              (MapBoxNavigationViewController controller) async {
                            // _controller = controller;
                          }),
                    )
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _onRouteEvent(e) async {
    _distanceRemaining = await MapBoxNavigation.instance.getDistanceRemaining();
    _durationRemaining = await MapBoxNavigation.instance.getDurationRemaining();

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        // _arrived = progressEvent.arrived!;
        if (progressEvent.currentStepInstruction != null) {
          _instruction = progressEvent.currentStepInstruction!;
        }
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        // _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        // _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        // _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        // _arrived = true;
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        // _routeBuilt = false;
        // _isNavigating = false;
        break;
      default:
        break;
    }
    setState(() {});
  }
}
