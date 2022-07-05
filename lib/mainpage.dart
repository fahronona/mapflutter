import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import "package:latlong2/latlong.dart" as latLng;
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

bool loading = false;

class _MainPageState extends State<MainPage> {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading == true
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<Position>(
                      stream: Geolocator.getPositionStream(),
                      builder: (context, snapshot) {
                        print(snapshot);
                        return FlutterMap(
                          options: MapOptions(
                            center: latLng.LatLng(snapshot.data!.latitude,
                                snapshot.data!.longitude),
                            zoom: 12.0,
                          ),
                          layers: [
                            TileLayerOptions(
                              urlTemplate:
                                  "http://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}",
                              subdomains: ['a', 'b', 'c'],
                            ),
                            MarkerLayerOptions(
                              rotate: true,
                              markers: [
                                Marker(
                                  rotate: true,
                                  width: 80.0,
                                  height: 80.0,
                                  point: latLng.LatLng(snapshot.data!.latitude,
                                      snapshot.data!.longitude),
                                  builder: (ctx) => Transform.rotate(
                                    angle:
                                        snapshot.data!.heading * math.pi / 180,
                                    child: Icon(
                                      Icons.navigation,
                                      size: 50,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                ),
                Container(
                  height: 200,
                  child: StreamBuilder<Position>(
                      stream: Geolocator.getPositionStream(),
                      builder: (context, snapshot) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Latitud:"),
                                  Text(snapshot.data!.latitude.toString())
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Longitud:"),
                                  Text(snapshot.data!.longitude.toString())
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Speed:"),
                                  Text(snapshot.data!.speed.toString())
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Heading:"),
                                  Text(snapshot.data!.heading.toString())
                                ],
                              )
                            ],
                          ),
                        );
                      }),
                )
              ],
            ),
    );
  }
}
