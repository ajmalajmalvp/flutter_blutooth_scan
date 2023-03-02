import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class BluetoothScanners extends StatefulWidget {
  @override
  _BluetoothScannerState createState() => _BluetoothScannerState();
}

class _BluetoothScannerState extends State<BluetoothScanners> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? bluetoothAddress;
  bool isConnecting = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildQrView(context),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: isConnecting ? null : _connectToDevice,
                child: isConnecting
                    ? CircularProgressIndicator()
                    : Text('Connect to Device'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).accentColor,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 300,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        bluetoothAddress = scanData.code;
      });
    });
  }

  void _connectToDevice() async {
    setState(() {
      isConnecting = true;
    });

    try {
      final scanResult = await FlutterBlue.instance
          .scan(timeout: Duration(seconds: 4))
          .firstWhere((scanResult) =>
              scanResult.device.id.toString() == bluetoothAddress);
      final device = scanResult.device;
      await device.connect();
      setState(() {
        isConnecting = true;
      });
    } catch (e) {
      setState(() {
        isConnecting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error connecting to device: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
