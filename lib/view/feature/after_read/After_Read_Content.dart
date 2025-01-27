import 'package:flutter/material.dart';
import 'package:readventure/view/feature/reading/quiz_data.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../components/custom_app_bar.dart';

class AfterReadContent extends StatefulWidget {
  @override
  _AfterReadContentState createState() => _AfterReadContentState();
}


class _AfterReadContentState extends State<AfterReadContent> {

@override
Widget build(BuildContext context) {
  final customColors = Theme.of(context).extension<CustomColors>()!;

  return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: "읽기 도구의 필요성",
      ),
      body: SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  '현대 사회에서 읽기 능력은 지식 습득과 의사소통의 기본이지만, 학습자가 자신의 수준과 흥미에 맞는 텍스트를 접할 기회는 제한적이다. 기존의 교육 시스템은 주로 일률적인 교재와 평가 방식을 사용하며, 이는 학습 동기를 저하시킬 위험이 있다. 또한, 읽기 과정에서 즉각적인 피드백을 제공하는 시스템이 부족하여 학습자는 자신의 약점이나 강점을 파악하기 어렵다. 맞춤형 읽기 도구와 실시간 피드백 시스템은 학습자가 적합한 자료를 통해 능동적으로 읽기 능력을 향상시키고, 스스로 학습 과정을 조율할 수 있는 환경을 제공할 잠재력이 있다. 또한, 맞춤형 읽기 도구는 학습자의 수준과 흥미를 고려하여 적합한 자료를 제공할 수 있다. 이러한 도구의 개발과 보급은 개인화된 학습의 미래를 열어갈 중요한 과제가 될 것이다.',
  style: reading_textstyle(context).copyWith(color: customColors.neutral0),
  ),
  ],
  ),
  ),
  );
}
}