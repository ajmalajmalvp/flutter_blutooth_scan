import 'dart:async';
import 'dart:convert';

import 'package:bluetooth_scanf_flutter/Pages/qr_code_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class HomeScreen extends StatefulWidget {
  @override
  _BluetoothScannerState createState() => _BluetoothScannerState();
}

class _BluetoothScannerState extends State<HomeScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  late StreamSubscription<ScanResult> scanSubscription;
  bool _isConnected = false;
  BluetoothCharacteristic? _characteristic;
  @override
  void initState() {
    super.initState();
    scanDevices();
  }

  void scanDevices() {
    scanSubscription = flutterBlue.scan().listen((scanResult) {
      if (!devicesList.contains(scanResult.device)) {
        setState(() {
          devicesList.add(scanResult.device);
        });
      }
    }, onError: (error) {
      print('Error while scanning for Bluetooth devices: $error');
    });
  }

  @override
  void dispose() {
    super.dispose();
    scanSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return BluetoothScanners();
                }));
              },
              child: Icon(Icons.qr_code)),
        ],
        title: const Text('Bluetooth Scanner'),
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(devicesList[index].name),
            subtitle: Text(devicesList[index].id.toString()),
            trailing: ElevatedButton(
              child: const Text('Connect'),
              onPressed: () {
                // Connect to the device when the Connect
                //button is pressed
                connectToDevice(devicesList[index]);
                // print()
              },
            ),
          );
        },
      ),
    );
  }

  void connectToDevice(BluetoothDevice device) async {
    // Connect to the device and navigate to another screen to display device information
    await device.connect();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DeviceInformationScreen(device: device)),
    );
  }

  // Send JSON data to the connected device
  void sendData(Map<String, dynamic> data) {
    if (!_isConnected) {
      throw Exception('Not connected to a device');
    }

    // Encode the data as JSON
    final jsonData = json.encode(data);

    // Send the data to the device
    final bytes = utf8.encode(jsonData);
    _characteristic!.write(bytes);
    print('Sent data: $jsonData');
  }
}

class DeviceInformationScreen extends StatelessWidget {
  final BluetoothDevice device;

  const DeviceInformationScreen({Key? key, required this.device})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Device ID: ${device.id}'),
            const SizedBox(height: 16.0),
            ElevatedButton(
              child:const Text('Disconnect'),
              onPressed: () {
                // Disconnect from the device when the Disconnect button is pressed
                device.disconnect();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
