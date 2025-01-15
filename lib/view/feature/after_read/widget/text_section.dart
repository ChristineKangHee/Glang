import 'package:flutter/material.dart';

import '../../../../../theme/font.dart';

class Text_Section extends StatelessWidget {
  const Text_Section({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "결국 주인공은 친구들과 힘을 합쳐 어려움을 극복했습니다. "
          "용기와 지혜를 발휘한 덕분에 모두가 함께 웃으며 행복한 결말을 맞이했습니다. "
          "그날 이후로 마을에는 평화와 기쁨이 가득했고, 주인공은 소중한 가르침을 "
          "마음에 새기며 새로운 모험을 준비했습니다.",
      style: reading_exercise(context),
    );
  }
}