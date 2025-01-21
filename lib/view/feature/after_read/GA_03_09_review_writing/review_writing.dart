import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/font.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_button.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  @override
  _ReflectionScreenState createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final _controllers = List.generate(3, (_) => TextEditingController());
  bool _isAnyTextFieldFilled = false;

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(_checkTextFields);
    }
  }

  void _checkTextFields() {
    setState(() {
      _isAnyTextFieldFilled =
          _controllers.any((controller) => controller.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    return Scaffold(
      appBar: CustomAppBar_2depth_8(
        title: '자유 소감',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '글을 읽고 느낀 점을 작성해주세요',
                    style: body_small_semi(context).copyWith(
                      color: customColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildQuestionSection(
                    'Q1. 자신의 경험 중 글과 비슷한 경험이 있나요?',
                    _controllers[0],
                  ),
                  const SizedBox(height: 16),
                  _buildQuestionSection(
                    'Q2. 글 내용 중 일상 속에서 적용할 점이 있나요?',
                    _controllers[1],
                  ),
                  const SizedBox(height: 16),
                  _buildQuestionSection(
                    'Q3. 더 궁금한 점이 있나요?',
                    _controllers[2],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(String questionText, TextEditingController controller) {
    final customColors = ref.watch(customColorsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionText,
          style: body_small_semi(context).copyWith(
            color: customColors.neutral30,
          ),
        ),
        const SizedBox(height: 8),
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


  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: _isAnyTextFieldFilled
          ? ButtonPrimary(
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
          : ButtonPrimary20(
        function: () {
          print("제출하기");
          // 상황에 맞는 함수 호출
        },
        title: '제출하기',
      ),
    );
  }
}
