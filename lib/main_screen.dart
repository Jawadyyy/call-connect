import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

const String appId = '47d249d981ca4405a6540139d625d8ab';
const String token =
    '007eJxTYPhp+T4nZ9oCporXEfvsVM+LuvE4BFVuWdSRuPTCh4RrTEcUGEzMU4xMLFMsLQyTE01MDEwTzUxNDAyNLVPMjExTLBKTjhnVZjQEMjIILD3GyMgAgSA+C0NyYk4OAwMAQkYfAg==';
const String channelName = 'call';

class SimpleVideoCall extends StatefulWidget {
  const SimpleVideoCall({super.key});
  @override
  State<SimpleVideoCall> createState() => _SimpleVideoCallState();
}

class _SimpleVideoCallState extends State<SimpleVideoCall> {
  late final RtcEngine _engine;
  int? _remoteUid;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.camera, Permission.microphone].request();
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: appId));
    await _engine.enableVideo();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('✅ Local user joined: ${connection.localUid}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print('📥 Remote user joined: $remoteUid');
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              print('❌ Remote user left: $remoteUid');
              setState(() => _remoteUid = null);
            },
      ),
    );

    await _engine.startPreview();
    await _engine.joinChannel(
      token: token,
      channelId: channelName,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agora Call Test')),
      body: Stack(
        children: [
          _remoteUid != null
              ? AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine,
                    canvas: VideoCanvas(uid: _remoteUid),
                    connection: const RtcConnection(channelId: channelName),
                  ),
                )
              : const Center(child: Text('Waiting for remote user...')),
          Positioned(
            top: 20,
            right: 20,
            width: 120,
            height: 160,
            child: AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
