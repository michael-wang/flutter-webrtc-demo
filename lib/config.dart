class Config {
  /// flutter-webrtc-server has built-in turn server. See: [Signaling.connect]
  static bool useCustomIceServer = false;

  static const Map<String, Map<String, String>> IceServers = {
    'Local Coturn Server': {
      'url': 'turn:your_url',
      'username': 'your_name',
      'credential': 'your_password',
    },
    'Remote Coturn Server': {
      'url': 'turn:your_url',
      'username': 'your_name',
      'credential': 'your_password',
    },
    'Google Stun Server': {
      'url': 'stun:stun.l.google.com:19302',
    }
  };
  static var userSelectedIceServer = IceServers.keys.first;
  static iceServer() {
    return IceServers[userSelectedIceServer];
  }
}
