/// File: review_writing.dart
/// Purpose: 사용자가 소감을 작성할 수 있는 화면
/// Author: 강희
/// Created: 2024-1-23
/// Last Modified: 2024-1-25 by 강희


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/font.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_button.dart';

// ReflectionScreen: 사용자가 소감을 작성할 수 있는 화면을 나타내는 StatefulWidget
class ReflectionScreen extends ConsumerStatefulWidget {
  @override
  _ReflectionScreenState createState() => _ReflectionScreenState();
}

// ReflectionScreen의 상태 관리 클래스
class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  // 3개의 텍스트 필드를 위한 TextEditingController 배열 생성
  final _controllers = List.generate(3, (_) => TextEditingController());
  // 텍스트 필드에 하나라도 값이 입력되었는지 확인하는 변수
  bool _isAnyTextFieldFilled = false;

  @override
  void initState() {
    super.initState();
    // 각 컨트롤러에 리스너를 추가하여 텍스트 입력 상태를 확인
    for (var controller in _controllers) {
      controller.addListener(_checkTextFields);
    }
  }

  // 텍스트 필드 중 하나라도 값이 입력되었는지 확인
  void _checkTextFields() {
    setState(() {
      _isAnyTextFieldFilled =
          _controllers.any((controller) => controller.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    // 리소스 해제를 위해 모든 컨트롤러를 dispose
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider); // 사용자 정의 색상 가져오기
    return Scaffold(
      appBar: CustomAppBar_2depth_8(
        title: '자유 소감', // 앱바 제목
      ),
      body: Column(
        children: [
          // 메인 콘텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 안내 텍스트
                  Text(
                    '글을 읽고 느낀 점을 작성해주세요',
                    style: body_small_semi(context).copyWith(
                      color: customColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 질문 섹션 1
                  _buildQuestionSection(
                    'Q1. 자신의 경험 중 글과 비슷한 경험이 있나요?',
                    _controllers[0],
                  ),
                  const SizedBox(height: 16),
                  // 질문 섹션 2
                  _buildQuestionSection(
                    'Q2. 글 내용 중 일상 속에서 적용할 점이 있나요?',
                    _controllers[1],
                  ),
                  const SizedBox(height: 16),
                  // 질문 섹션 3
                  _buildQuestionSection(
                    'Q3. 더 궁금한 점이 있나요?',
                    _controllers[2],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 제출 버튼
          _buildSubmitButton(),
        ],
      ),
    );
  }

  // 질문 섹션을 구성하는 위젯
  Widget _buildQuestionSection(String questionText, TextEditingController controller) {
    final customColors = ref.watch(customColorsProvider); // 사용자 정의 색상 가져오기
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 질문 텍스트
        Text(
          questionText,
          style: body_small_semi(context).copyWith(
            color: customColors.neutral30,
          ),
        ),
        const SizedBox(height: 8),
        // 텍스트 입력 필드
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 100,
            maxHeight: 170,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: customColors.neutral90,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 텍스트 필드
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    cursorColor: customColors.primary,
                    style: body_medium(context),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '글을 작성해주세요.',
                      hintStyle: body_medium(context).copyWith(
                        color: customColors.neutral60,
                      ),
                    ),
                  ),
                ),
                // 글자 수 표시
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '${controller.text.length}/50',
                    style: body_small(context).copyWith(
                      color: customColors.neutral60,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 제출 버튼을 구성하는 위젯
  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: _isAnyTextFieldFilled
          ? ButtonPrimary_noPadding(
        function: () {
          print("제출하기");
          // 상황에 맞는 함수 호출
          Navigator.popUntil(
            context,
                (route) => route.settings.name == 'LearningActivitiesPage',
          );
        },
        title: '제출하기',
      )
          : ButtonPrimary20_noPadding(
        function: () {
          print("제출하기");
          // 상황에 맞는 함수 호출
        },
        title: '제출하기',
      ),
    );
  }
}
