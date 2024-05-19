import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(SpaceXApp());
}

class SpaceXApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceX Lanzamientos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LatestLaunchScreen(),
    );
  }
}

class Launch {
  final String nombreMision;
  final DateTime fecha;
  final bool despegueExito;

  Launch({
    required this.nombreMision,
    required this.fecha,
    required this.despegueExito,
  });

  factory Launch.fromJson(Map<String, dynamic> json) {
    return Launch(
      nombreMision: json['name'],
      fecha: DateTime.parse(json['date_utc']),
      despegueExito: json['success'] ?? false,
    );
  }
}

class ApiService {
  static const String _baseUrl = 'https://api.spacexdata.com/v5/launches';

  Future<List<Launch>> fetchAllLaunches() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((launch) => Launch.fromJson(launch)).toList();
    } else {
      throw Exception('Error');
    }
  }
}

class LatestLaunchScreen extends StatefulWidget {
  @override
  _LatestLaunchScreenState createState() => _LatestLaunchScreenState();
}

class _LatestLaunchScreenState extends State<LatestLaunchScreen> {
  late Future<List<Launch>> futureLaunches = ApiService().fetchAllLaunches();

  @override
  void initState() {
    super.initState();
    futureLaunches = ApiService().fetchAllLaunches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SpaceX Lanzamientos'),
      ),
      body: FutureBuilder<List<Launch>>(
        future: futureLaunches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Error'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return LaunchCard(launch: snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }
}

class LaunchCard extends StatelessWidget {
  final Launch launch;
  LaunchCard({required this.launch});
  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        title: Text(launch.nombreMision),
        subtitle: Text(formatDate(launch.fecha)),
        trailing: Text(
          launch.despegueExito ? 'Exito' : 'Fallido',
          style: TextStyle(
            color: launch.despegueExito ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
