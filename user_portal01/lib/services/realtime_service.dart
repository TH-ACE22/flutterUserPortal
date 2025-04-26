// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class RealtimeService {
  late StompClient _client;
  final Function(Map<String, dynamic>) onPostReceived;

  // Optional callbacks for UI state tracking
  final Function()? onConnecting;
  final Function()? onConnected;
  final Function()? onDisconnected;
  final Function(String error)? onError;

  RealtimeService({
    required this.onPostReceived,
    this.onConnecting,
    this.onConnected,
    this.onDisconnected,
    this.onError,
  });

  void connect({
    String baseUrl = 'http://10.0.2.2:8081/ws',
    String channelId = 'all',
  }) {
    _client = StompClient(
      config: StompConfig.SockJS(
        url: baseUrl,
        beforeConnect: () async {
          print('[RealtimeService] Connecting to WebSocket...');
          if (onConnecting != null) onConnecting!();
        },
        onConnect: (StompFrame frame) {
          print('[RealtimeService] Connected!');
          if (onConnected != null) onConnected!();

          _client.subscribe(
            destination: '/topic/posts/$channelId',
            callback: (frame) {
              try {
                final Map<String, dynamic> data = json.decode(frame.body!);
                onPostReceived(data);
              } catch (e) {
                print('[RealtimeService] Failed to parse message: $e');
              }
            },
          );
        },
        onStompError: (frame) {
          final error = frame.body ?? 'Unknown STOMP error';
          print('[RealtimeService] STOMP Error: $error');
          if (onError != null) onError!(error);
        },
        onWebSocketError: (dynamic error) {
          print('[RealtimeService] WebSocket Error: $error');
          if (onError != null) onError!(error.toString());
        },
        onDisconnect: (frame) {
          print('[RealtimeService] Disconnected');
          if (onDisconnected != null) onDisconnected!();
        },
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _client.activate();
  }

  void disconnect() {
    if (_client.connected) {
      _client.deactivate();
    }
  }
}
