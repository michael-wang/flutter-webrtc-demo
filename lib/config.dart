class Config {
  static var peerConnection = {
    // 'iceTransportPolicy': 'all',
    'iceServers': [
      localTurnServer,
      // remoteTurnServer,
      // googleStunServer,
    ],
  };

  static bool getConnectionConfigFromServer = false;

  static const localTurnServer = {
    // I use coturn as turn server: https://github.com/coturn/coturn
    'url': 'turn:192.168.1.102:3478',
    'username': 'mike',
    'credential': 'mikepass'
  };

  static const googleStunServer = {
    'url': 'stun:stun.l.google.com:19302',
  };

  static const remoteTurnServer = {
    'url': 'TODO_remote_turn_server',
    'username': 'TODO_username',
    'credential': 'TODO_credential'
  };
}
