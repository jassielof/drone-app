import 'dart:typed_data';
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
    bool isEnabled = await _bluetooth.isEnabled ?? false;
    if (!isEnabled) {
      await _bluetooth.requestEnable();
    }
    var res = await _bluetooth.getBondedDevices();
    setState(() => _devices = res);
  }

  void _sendData(int data) async {
    if (_connection != null && _connection!.isConnected) {
      Uint8List command = Uint8List(1);
      command[0] = data; // Enviamos directamente el byte correspondiente
      _connection!.output.add(command);
      await _connection!.output.allSent;
    } else {
      print('Cannot send data, no device connected.');
    }
  }

  void _disconnect() async {
    if (_connection != null) {
      await _connection?.close();
      setState(() {
        _deviceConnected = null;
        _connection = null;
      });
      print('Device disconnected');
    } else {
      print('No connection to disconnect');
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
              : Column(
                  children: [
                    Text('Conectado a: ${_deviceConnected!.name}'),
                    ElevatedButton(
                      onPressed: _disconnect,
                      child: Text('Desconectar'),
                    ),
                  ],
                ),
          _isConnecting
              ? CircularProgressIndicator()
              : Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _sendData(1),
                      child: Text('Prender Motores'),
                    ),
                    ElevatedButton(
                      onPressed: () => _sendData(2),
                      child: Text('Apagar Motores'),
                    ),
                    ElevatedButton(
                      onPressed: () => _sendData(3),
                      child: Text('Subir'),
                    ),
                    ElevatedButton(
                      onPressed: () => _sendData(4),
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
                      try {
                        _connection =
                            await BluetoothConnection.toAddress(device.address);
                        setState(() {
                          _deviceConnected = device;
                          _isConnecting = false;
                        });
                        print('Connected to the device');
                      } catch (e) {
                        setState(() => _isConnecting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al conectar: $e')),
                        );
                      }
                    },
                  ))
              .toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    _connection?.dispose();
    super.dispose();
  }
}
