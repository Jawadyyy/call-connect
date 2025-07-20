import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

const String agoraAppId = "47d249d981ca4405a6540139d625d8ab";

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  const VideoCallScreen({super.key, required this.channelName});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late RtcEngine _engine;
  int? _remoteUid;
  bool _muted = false;
  bool _speakerOn = true;
  bool _isEngineReady = false;
  bool _isCameraOn = true;
  bool _isFrontCamera = true;
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
    await [Permission.camera, Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: agoraAppId));

    await _engine.enableVideo();
    await _engine.setDefaultAudioRouteToSpeakerphone(_speakerOn);

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('Local user joined: ${connection.localUid}');
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

    await _engine.startPreview();
    await _engine.joinChannel(
      token:
          "007eJxTYPhp+T4nZ9oCporXEfvsVM+LuvE4BFVuWdSRuPTCh4RrTEcUGEzMU4xMLFMsLQyTE01MDEwTzUxNDAyNLVPMjExTLBKTjhnVZjQEMjIILD3GyMgAgSA+C0NyYk4OAwMAQkYfAg==",
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    setState(() {
      _isEngineReady = true;
    });
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

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
    _engine.enableLocalVideo(_isCameraOn);
  }

  void _switchCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    _engine.switchCamera();
  }

  Widget _renderLocalPreview() {
    if (!_isEngineReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isCameraOn
            ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            : Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.videocam_off,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != null && _isEngineReady) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_search, size: 80, color: Colors.white54),
              const SizedBox(height: 16),
              Text(
                'Waiting for participant...',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (!_isEngineReady) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [Colors.deepPurple.shade900, Colors.indigo.shade900]
                  : [Colors.deepPurple.shade50, Colors.blue.shade50],
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Colors.deepPurple.shade900, Colors.indigo.shade900]
                : [Colors.deepPurple.shade50, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: _renderRemoteVideo()),

              Positioned(
                top: 24,
                right: 24,
                width: 120,
                height: 160,
                child: _renderLocalPreview(),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    _callDuration,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.info_outline),
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
                        icon: Icons.switch_camera,
                        label: 'Flip',
                        color: Colors.white,
                        onPressed: _switchCamera,
                      ),
                      CallControlButton(
                        icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                        label: _isCameraOn ? 'Camera Off' : 'Camera On',
                        color: _isCameraOn ? Colors.white : Colors.red,
                        onPressed: _toggleCamera,
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

  void _showCallInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Call Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Channel', widget.channelName),
              _buildInfoRow('Duration', _callDuration),
              _buildInfoRow('Status', 'Connected'),
              _buildInfoRow(
                'Participant',
                _remoteUid != null ? 'User ${_remoteUid!}' : 'None',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
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
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
