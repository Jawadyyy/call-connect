import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

const String agoraAppId = "47d249d981ca4405a6540139d625d8ab";

class VoiceCallScreen extends StatefulWidget {
  final String channelName;
  const VoiceCallScreen({super.key, required this.channelName});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  late RtcEngine _engine;
  int? _remoteUid;
  bool _muted = false;
  bool _speakerOn = true;
  bool _isConnected = false;
  String _callDuration = '00:00';
  late DateTime _callStartTime;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _callStartTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final duration = DateTime.now().difference(_callStartTime);
      setState(() {
        _callDuration =
            '${duration.inMinutes.toString().padLeft(2, '0')}:'
            '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
      });
    });
  }

  Future<void> _initAgora() async {
    await [Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: agoraAppId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _isConnected = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              setState(() {
                _remoteUid = null;
              });
            },
      ),
    );

    await _engine.enableAudio();
    await _engine.setDefaultAudioRouteToSpeakerphone(_speakerOn);
    await _engine.joinChannel(
      token:
          "007eJxTYPhp+T4nZ9oCporXEfvsVM+LuvE4BFVuWdSRuPTCh4RrTEcUGEzMU4xMLFMsLQyTE01MDEwTzUxNDAyNLVPMjExTLBKTjhnVZjQEMjIILD3GyMgAgSA+C0NyYk4OAwMAQkYfAg==",
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  void _toggleSpeaker() {
    setState(() {
      _speakerOn = !_speakerOn;
    });
    _engine.setEnableSpeakerphone(_speakerOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildUserAvatar(),
                      const SizedBox(height: 32),
                      _buildConnectionStatus(),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    _callDuration,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: _showCallInfo,
                    ),
                  ],
                ),
              ),

              if (_remoteUid != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 56,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.channelName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CallControlButton(
                        icon: _muted ? Icons.mic_off : Icons.mic,
                        label: _muted ? 'Unmute' : 'Mute',
                        color: _muted ? Colors.red : Colors.white,
                        onPressed: () {
                          setState(() {
                            _muted = !_muted;
                          });
                          _engine.muteLocalAudioStream(_muted);
                        },
                      ),
                      CallControlButton(
                        icon: _speakerOn ? Icons.volume_up : Icons.volume_off,
                        label: _speakerOn ? 'Speaker' : 'Earpiece',
                        color: Colors.white,
                        onPressed: _toggleSpeaker,
                      ),
                      CallControlButton(
                        icon: Icons.call_end,
                        label: 'End',
                        color: Colors.red,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.blue.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.blue.withOpacity(0.5), Colors.transparent],
                ),
              ),
            ),
          ),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: Icon(
                _remoteUid != null ? Icons.person : Icons.person_outline,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Column(
      children: [
        Text(
          _remoteUid != null
              ? 'User ${_remoteUid!.toString().substring(0, 4)}...'
              : 'Waiting for participant...',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isConnected ? 'Voice Call' : 'Connecting...',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }

  void _showCallInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Call Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Channel', widget.channelName),
              _buildInfoRow('Duration', _callDuration),
              _buildInfoRow(
                'Status',
                _isConnected ? 'Connected' : 'Connecting',
              ),
              _buildInfoRow(
                'Participant',
                _remoteUid != null ? 'User ${_remoteUid!}' : 'None',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const CallControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, size: 28),
            color: color,
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
