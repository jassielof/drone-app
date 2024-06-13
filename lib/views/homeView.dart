import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:dronvolador1/services/auth_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  final FlutterTts _flutterTts = FlutterTts();
  String _currentCommand = '';
  double _voiceVolume = 0.0;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _getDevices();
    _initializeTts();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _initializeTts() async {
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setLanguage('es-ES');
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

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;

  void _listenForCommand() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (val) {
            setState(() {
              _currentCommand = val.recognizedWords;
              _voiceVolume = val.confidence;
            });
            print('Heard: ${val.recognizedWords}');
            _processCommand(val.recognizedWords);
            _resetListeningState(); // Reset the listening state after processing the command
          },
          pauseFor: Duration(
              seconds: 5), // Pause for 5 seconds after receiving a result
          onSoundLevelChange: (val) {
            setState(() => _voiceVolume = val);
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  void _resetListeningState() {
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _isListening = false;
      });
    });
  }

  void _processCommand(String command) {
    switch (command.toLowerCase()) {
      case 'power on.' || 'power on' || 'power on!':
        print("Se envió el comando de encender a través de voz");
        _sendData(1);
        _showNotification('Encender motores');
        break;
      case 'power off.' || 'power off' || 'power off!':
        print("Se envió el comando de apagar a través de voz");
        _sendData(2);
        _showNotification('Apagar motores');
        break;
      case 'go up.' || 'go up' || 'go up!':
        print("Se envió el comando de subir a través de voz");
        _sendData(3);
        _showNotification('Subir');
        break;
      case 'go down.' || 'go down' || 'go down!':
        print("Se envió el comando de bajar a través de voz");
        _sendData(4);
        _showNotification('Bajar');
        break;
      default:
        print("Comando no reconocido");
        break;
    }
  }

  Future<void> _showNotification(String command) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'your_channel_name',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Comando aceptado', command, platformChannelSpecifics,
        payload: 'item x');
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
                    ElevatedButton(
                      onPressed: _listenForCommand,
                      child: Column(
                        children: [
                          Text(_isListening
                              ? 'Stop Listening'
                              : 'Listen for Command'),
                          if (_isListening)
                            Column(
                              children: [
                                Text('Current Command: $_currentCommand'),
                                Text(
                                    'Voice Volume: ${(_voiceVolume * 100).toStringAsFixed(1)}%'),
                              ],
                            ),
                        ],
                      ),
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
