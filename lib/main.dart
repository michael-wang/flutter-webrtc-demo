import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc_demo/config.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/call_sample/call_sample.dart';
import 'src/call_sample/data_channel_sample.dart';
import 'src/route_item.dart';

final log = Logger();

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

enum DialogDemoAction {
  cancel,
  connect,
}

class _MyAppState extends State<MyApp> {
  List<RouteItem> items = [];
  String _server = '';
  late SharedPreferences _prefs;

  bool _datachannel = false;
  @override
  initState() {
    super.initState();
    _initData();
    _initItems();
  }

  _buildRow(context, item) {
    return ListBody(children: <Widget>[
      ListTile(
        title: Text(item.title),
        onTap: () => item.push(context),
        trailing: Icon(Icons.arrow_right),
      ),
      Divider()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter-WebRTC example'),
        ),
        body: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(0.0),
            itemCount: items.length,
            itemBuilder: (context, i) {
              return _buildRow(context, items[i]);
            }),
        bottomSheet: StatefulBuilder(builder: (context, setState) {
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(0.0),
            itemCount: 2,
            itemBuilder: (context, i) {
              if (i == 0) {
                return SwitchListTile(
                  value: Config.useCustomIceServer,
                  onChanged: (bool value) {
                    _prefs.setBool('useCustomIceServer', value);
                    setState(() {
                      Config.useCustomIceServer = value;
                    });
                  },
                  title: Text('使用客製的 ICE Server'),
                );
              } else {
                return ListTile(
                  leading: Text('Server 列表'),
                  title: DropdownButton<String>(
                    value: Config.userSelectedIceServer,
                    items: Config.IceServers.keys
                        .map((serverName) => DropdownMenuItem(
                              value: serverName,
                              child: Column(
                                children: [
                                  Text(serverName),
                                  Text(Config.IceServers[serverName]?['url'] ??
                                      '???'),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: Config.useCustomIceServer
                        ? (value) {
                            if (value == null) {
                              return;
                            }
                            _prefs.setString('userSelectedIceServer', value);
                            setState(() {
                              Config.userSelectedIceServer = value;
                            });
                          }
                        : null,
                  ),
                );
              }
            },
          );
        }),
      ),
    );
  }

  _initData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _server = _prefs.getString('server') ?? 'demo.cloudwebrtc.com';
      Config.useCustomIceServer = _prefs.getBool('useCustomIceServer') ?? true;
      Config.userSelectedIceServer =
          _prefs.getString('userSelectedIceServer') ??
              Config.userSelectedIceServer;
    });
  }

  void showDemoDialog<T>(
      {required BuildContext context, required Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T? value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        if (value == DialogDemoAction.connect) {
          _prefs.setString('server', _server);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => _datachannel
                      ? DataChannelSample(host: _server)
                      : CallSample(host: _server)));
        }
      }
    });
  }

  _showAddressDialog(context) {
    showDemoDialog<DialogDemoAction>(
        context: context,
        child: AlertDialog(
            title: const Text('Enter server address:'),
            content: TextField(
              onChanged: (String text) {
                setState(() {
                  _server = text;
                });
              },
              decoration: InputDecoration(
                hintText: _server,
              ),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context, DialogDemoAction.cancel);
                  }),
              TextButton(
                  child: const Text('CONNECT'),
                  onPressed: () {
                    Navigator.pop(context, DialogDemoAction.connect);
                  })
            ]));
  }

  _initItems() {
    items = <RouteItem>[
      RouteItem(
          title: 'P2P Call Sample',
          subtitle: 'P2P Call Sample.',
          push: (BuildContext context) {
            _datachannel = false;
            _showAddressDialog(context);
          }),
      RouteItem(
          title: 'Data Channel Sample',
          subtitle: 'P2P Data Channel.',
          push: (BuildContext context) {
            _datachannel = true;
            _showAddressDialog(context);
          }),
    ];
  }
}
