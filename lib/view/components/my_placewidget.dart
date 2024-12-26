// // my_placewidget.dart
//
// import 'package:flutter/material.dart';
// import 'package:haedal/theme/font.dart';
// import 'package:test_project/model/restaurant.dart';
// import '../storedetail/store_detail.dart';
//
// class PlaceWidget extends StatelessWidget {
//   final Restaurant restaurant;
//   final VoidCallback onFavoriteToggle;
//
//   PlaceWidget({required this.restaurant, required this.onFavoriteToggle});
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       // Material widget for InkWell behavior
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           // Navigate to StoreDetailPage on tap
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => StoreDetailPage(name: restaurant.name), // Pass necessary parameters
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 8.0),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12.0),
//                   child: Image.asset(
//                     restaurant.image,
//                     fit: BoxFit.cover,
//                     width: 84,
//                     height: 84,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(restaurant.name, style: pretendardBold(context)),
//                     Row(
//                       children: [
//                         Icon(Icons.star_rounded, color: Colors.yellow[700], size: 16),
//                         Text(restaurant.rating, style: pretendardBold(context).copyWith(fontSize: 12)),
//                         Text(' (${restaurant.reviews})', style: pretendardSemiBoldSecond(context).copyWith(fontSize: 12)),
//                       ],
//                     ),
//                     Text('${restaurant.foodtype} • ${restaurant.specificlocation} • ${restaurant.distance}', style: pretendardSemiBoldSecond(context).copyWith(fontSize: 12)),
//                   ],
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(
//                   restaurant.isFavorited ? Icons.favorite : Icons.favorite_border,
//                   color: restaurant.isFavorited ? Theme.of(context).colorScheme.primary : Colors.grey,
//                 ),
//                 onPressed: onFavoriteToggle,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
