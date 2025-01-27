import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/feature/after_read/GA_03_01_change_ending/CE_main.dart';
import 'package:readventure/view/feature/after_read/GA_03_03_debate_activity/DA_main.dart';
import 'package:readventure/view/feature/after_read/GA_03_04_diagram/diagram_learning.dart';
import '../Result_Report.dart';
import '../reading/practice.dart';
import '../reading/quiz_data.dart';
import 'After_Read_Content.dart';
import 'GA_03_02_content_summary/CS_main.dart';
import 'GA_03_05_writing_form/writing_form_learning.dart';
import 'GA_03_06_writing_essay/WE_main.dart';
import 'GA_03_07_format_conversion/FC_main.dart';
import 'GA_03_08_paragraph_analysis/paragraph_analysis.dart';
import 'GA_03_09_review_writing/review_writing.dart';
import 'choose_activities.dart';

class ArMain extends StatelessWidget {
  const ArMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar_2depth_7(title: "읽기 후"),
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => ChangeEndingMain(),
            )), child: Text("결말바꾸기")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => RootedTreeScreen(),
            )), child: Text("다이어그램")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => SentencePractice(),
            )), child: Text("문장형식연습")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => ContentSummaryMain(),
            )), child: Text("내용요약게임")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => WritingEssayMain(),
            )), child: Text("에세이작성")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => FormatConversionMain(),
            )), child: Text("형식변환연습")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => QuizScreen(),
            )), child: Text("문단주제추출")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => ReflectionScreen(),
            )), child: Text("자유 소감")),
            SizedBox(height: 30,),
            // ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
            //   builder: (context) => LearningActivitiesPage(),
            // )), child: Text("학습 선택")),
            ElevatedButton(onPressed: ()=>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: 'LearningActivitiesPage'),
                    builder: (context) => LearningActivitiesPage(),
                  ),
            ), child: Text("학습 선택")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => DebateActivityMain(),
            )), child: Text("토론 활동")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => TextHighlight(),
            )), child: Text("밑줄")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => ResultReportPage(),
            )), child: Text("리포트")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(
              builder: (context) => AfterReadContent(),
            )), child: Text("읽기 후 글")),
            SizedBox(height: 30,),
          ],
        ),
      )),
    );
  }
}
