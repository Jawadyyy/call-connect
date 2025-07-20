import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'voice_call_screen.dart';
import 'video_call_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _channelController = TextEditingController();
  bool _isButtonHovered = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'app-logo',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          // ignore: deprecated_member_use
                          Colors.deepPurple.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.1, 0.9],
                      ),
                      border: Border.all(
                        // ignore: deprecated_member_use
                        color: Colors.deepPurple.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.video_call_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'CONNECT INSTANTLY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        // ignore: deprecated_member_use
                        color: Colors.deepPurple.withOpacity(0.8),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Join voice or video calls with ultra-low latency',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 48),

                TextField(
                  controller: _channelController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Enter Channel Name',
                    // ignore: deprecated_member_use
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.link_rounded,
                      color: Colors.deepPurple[300],
                    ),
                    suffixIcon: _channelController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.6),
                            ),
                            onPressed: () {
                              _channelController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        // ignore: deprecated_member_use
                        color: Colors.deepPurple.withOpacity(0.8),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                MouseRegion(
                  onEnter: (_) => setState(() => _isButtonHovered = true),
                  onExit: (_) => setState(() => _isButtonHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple[800]!, Colors.indigo[900]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: _isButtonHovered
                          ? [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.deepPurple.withOpacity(0.6),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: ElevatedButton(
                      onPressed: _channelController.text.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VoiceCallScreen(
                                    channelName: _channelController.text,
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mic_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'VOICE CALL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.red[900]!, Colors.purple[900]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: _isButtonHovered
                        ? [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.red.withOpacity(0.6),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: ElevatedButton(
                    onPressed: _channelController.text.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoCallScreen(
                                  channelName: _channelController.text,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'VIDEO CALL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  'By joining, you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
