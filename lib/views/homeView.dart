import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:dronvolador1/services/auth_service.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AuthService _authService = AuthService();
  final _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  bool _isConnecting = false;
  BluetoothDevice? _deviceConnected;
  List<BluetoothDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _getDevices();
  }

  void _getDevices() async {
    var res = await _bluetooth.getBondedDevices();
    setState(() => _devices = res);

    // Start discovering devices
    _bluetooth.startDiscovery().listen((r) {
      setState(() {
        // Add the discovered device to the list if it's not already present
        if (!_devices.contains(r.device)) {
          _devices.add(r.device);
        }
      });
    });
  }

  void _sendData(String data) {
    if (_connection?.isConnected ?? false) {
      _connection?.output.add(ascii.encode(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _deviceConnected == null
              ? ElevatedButton(
                  onPressed: _selectDevice,
                  child: Text('Seleccionar dispositivo'),
                )
              : Text('Conectado a: ${_deviceConnected!.name}'),
          _isConnecting
              ? CircularProgressIndicator()
              : Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _sendData('1'),
                      child: Text('Prender Motores'),
                    ),
                    ElevatedButton(
                      onPressed: () => _sendData('2'),
                      child: Text('Apagar Motores'),
                    ),
                    ElevatedButton(
                      onPressed: () => _sendData('3'),
                      child: Text('Subir'),
                    ),
                    ElevatedButton(
                      onPressed: () => _sendData('4'),
                      child: Text('Bajar'),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  void _selectDevice() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: _devices
              .map((device) => ListTile(
                    title: Text(device.name ?? device.address),
                    onTap: () async {
                      Navigator.pop(context);
                      setState(() => _isConnecting = true);

                      _connection =
                          await BluetoothConnection.toAddress(device.address);
                      setState(() {
                        _deviceConnected = device;
                        _isConnecting = false;
                      });
                    },
                  ))
              .toList(),
        );
      },
    );
  }
}
