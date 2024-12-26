// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:lottie/lottie.dart';
// import '../theme/font.dart';
//
// class PromoCard extends StatelessWidget {
//   final List<Color> gradientColors;
//   final String title;
//   final String buttonText;
//   final String? imageUrl;
//   final double imageWidth;
//   final double imageHeight;
//   final String? lottieUrl;
//
//   const PromoCard({
//     required this.gradientColors,
//     required this.title,
//     required this.buttonText,
//     this.imageUrl,
//     required this.imageWidth,
//     required this.imageHeight,
//     this.lottieUrl,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container( //큰 프레임
//       width: 354.21.w,
//       height: 152.55.h,
//       clipBehavior: Clip.antiAlias,
//       decoration: ShapeDecoration(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       child: Stack(
//         children: [
//           Container(
//             width: 354.21.w,
//             height: 1.sh,
//             decoration: ShapeDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: gradientColors,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//           Positioned(
//             left: 16,
//             top: 29,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   width: 174.w,
//                   child: Text(
//                       title,
//                       style: pretendardSemiBold(context).copyWith(color: Theme.of(context).colorScheme.surface)
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 // 버튼
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: ShapeDecoration(
//                     color: Theme.of(context).colorScheme.onSurface,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(40),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                           buttonText,
//                           style: pretendardSemiBold(context).copyWith(color: Theme.of(context).colorScheme.surface, fontSize: 12)
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // 이미지
//           Positioned(
//             right: 0,
//             bottom: 0,
//             top: 0,
//             child: Container(
//               width: 156,
//               height: 156,
//               child: imageUrl != null
//                   ? Image(
//                 image: imageUrl!.startsWith('http')
//                     ? NetworkImage(imageUrl!)
//                     : AssetImage(imageUrl!) as ImageProvider,
//                 fit: BoxFit.cover,
//               )
//                   : lottieUrl != null
//                   ? Lottie.network(lottieUrl!)
//                   : Container(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }