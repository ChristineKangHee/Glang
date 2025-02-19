// import 'package:flutter/material.dart';
//
// class AutoLoginToggle extends StatefulWidget {
//   @override
//   _AutoLoginToggleState createState() => _AutoLoginToggleState();
// }
//
// class _AutoLoginToggleState extends State<AutoLoginToggle> {
//   bool _isChecked = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: <Widget>[
//         Checkbox(
//           value: _isChecked,
//           onChanged: (bool? value) {
//             setState(() {
//               _isChecked = value!;
//             });
//           },
//           activeColor: Theme.of(context).colorScheme.primary,
//           checkColor: Colors.white,
//           side: BorderSide(
//             color: Theme.of(context).colorScheme.outline,
//           ),
//         ),
//         const Text(
//           '자동 로그인',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
// }
