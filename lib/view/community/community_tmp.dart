import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';

class CommunityTmp extends StatelessWidget {
  const CommunityTmp({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return SingleChildScrollView(
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.4,),
              Text("추후 업데이트 예정입니다.", style: body_large_semi(context),)
            ],
          ),
        ),
      ),
    );
  }
}
