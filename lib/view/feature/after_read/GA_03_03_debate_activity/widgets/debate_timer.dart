// import 'package:flutter/material.dart';
//
// class DebateTimer extends StatefulWidget {
//   final Duration duration;
//   final VoidCallback onTimeout;
//   final VoidCallback onPause;
//
//   const DebateTimer({
//     required this.duration,
//     required this.onTimeout,
//     required this.onPause,
//   });
//
//   @override
//   _DebateTimerState createState() => _DebateTimerState();
// }
//
// class _DebateTimerState extends State<DebateTimer> {
//   late Duration remainingTime;
//   bool isRunning = true;
//
//   @override
//   void initState() {
//     super.initState();
//     remainingTime = widget.duration;
//     _startTimer();
//   }
//
//   void _startTimer() async {
//     while (isRunning && remainingTime.inSeconds > 0) {
//       await Future.delayed(Duration(seconds: 1));
//       if (mounted) {
//         setState(() {
//           remainingTime -= Duration(seconds: 1);
//         });
//       }
//     }
//     if (remainingTime.inSeconds == 0) {
//       widget.onTimeout();
//     }
//   }
//
//   void _pauseTimer() {
//     setState(() => isRunning = false);
//     widget.onPause();
//   }
//
//   void _resumeTimer() {
//     setState(() => isRunning = true);
//     _startTimer();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Text(
//           "${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}",
//           style: TextStyle(fontSize: 16),
//         ),
//         IconButton(
//           icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
//           onPressed: isRunning ? _pauseTimer : _resumeTimer,
//         ),
//       ],
//     );
//   }
// }
