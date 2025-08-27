import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../components/custom_button.dart';

class CourseProcessingPage extends ConsumerStatefulWidget {
  @override
  _CourseProcessingPageState createState() => _CourseProcessingPageState();
}

class _CourseProcessingPageState extends ConsumerState<CourseProcessingPage> {
  bool _isProcessing = true; // 로딩 상태
  double _progress = 0.0; // 진행 상태
  int _completedTasks = 0; // 완료된 항목 수

  @override
  void initState() {
    super.initState();
    _simulateProgress(); // 진행 상태 변화 시뮬레이션
  }

  // 진행 상태 시뮬레이션 함수
  void _simulateProgress() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_progress < 1.0) {
        setState(() {
          _progress += 0.01;
          // 진행 상태에 따라 완료된 항목을 더 빨리 나타내도록 3개 항목 중 더 빠르게 완료 상태 반영
          _completedTasks = (_progress * 3).toInt();
          if (_progress > 0.5) {
            _completedTasks++; // 50%가 넘어가면 완료된 항목을 더 빠르게 하나 추가
          }
        });
        _simulateProgress(); // 재귀 호출로 진행
      } else {
        setState(() {
          _isProcessing = false; // 완료 후 처리
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      bottomNavigationBar: !_isProcessing
          ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ButtonPrimary(
                function: () {
                  Navigator.pushNamed(context, '/');
                },
                title: '시작하기',
              ),
              const SizedBox(height: 36), // 하단 간격 추가
            ],
          )
          : null,

      body: SafeArea(
        child: Center(
          child: _isProcessing
              ? _buildProcessingBody(customColors)
              : _buildCompletionBody(customColors),
        ),
      ),
    );
  }


  // 로딩 중일 때의 화면 구성
  Widget _buildProcessingBody(CustomColors customColors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // 동그라미 진행 상태 애니메이션
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              width: 200, // 크기 조정
              height: 200, // 크기 조정
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 20, // 두께 조정
                backgroundColor: customColors.neutral80,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(customColors.primary!),
              ),
            ),
            // 진행 상태를 퍼센트로 표시 애니메이션
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 500),
              style: heading_large(context).copyWith(color: customColors.neutral30),
              child: Text(
                '${(_progress * 100).toStringAsFixed(0)}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        _buildTitleAndDescription(customColors),
        const SizedBox(height: 55),
        _buildInfoRows(customColors),
      ],
    );
  }

  // 완료 후의 화면 구성
  Widget _buildCompletionBody(CustomColors customColors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedOpacity(
          duration: Duration(milliseconds: 500),
          opacity: _isProcessing ? 0.0 : 1.0,
          child: Icon(Icons.check_circle_rounded, size: 50, color: customColors.primary),
        ),
        SizedBox(height: 20),
        AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 500),
          style: heading_large(context),
          child: Text("코스 생성 완료!"),
        ),
        SizedBox(height: 12),
        AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 500),
          style: body_small_semi(context).copyWith(color: customColors.neutral60),
          child: Text(
            '모든 설정이 완료되었어요.\n이제 글 읽기를 시작해볼까요?',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // 제목과 설명을 보여주는 위젯
  Widget _buildTitleAndDescription(CustomColors customColors) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 500),
            style: heading_large(context),
            child: Text(
              '맞춤 코스 만드는 중...',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 500),
            style: body_small_semi(context).copyWith(color: customColors.neutral60),
            child: Text(
              '제로님께 필요한 코스를 찾고 있어요',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // 진행 상태 항목을 표시하는 위젯들
  Widget _buildInfoRows(CustomColors customColors) {
    final infoTexts = ['글 읽기 능력', '내 관심 분야 분석', '개인 인적 사항'];

    return Column(
      children: infoTexts
          .map((text) {
        int index = infoTexts.indexOf(text);
        return Column(
          children: [
            _buildInfoRow(text, customColors, index),
            const SizedBox(height: 20), // 각 항목 간 간격 설정
          ],
        );
      })
          .toList(),
    );
  }

  // 항목에 대한 정보 Row 구성
  Widget _buildInfoRow(String text, CustomColors customColors, int index) {
    bool isCompleted = index < _completedTasks; // 완료된 항목인지 확인

    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Row를 중앙 정렬
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: isCompleted ? 1.0 : 0.3,
            child: Icon(
              Icons.check_circle_rounded,
              color: isCompleted ? customColors.primary : customColors.neutral60,
            ),
          ),
          const SizedBox(width: 15),
          AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: isCompleted ? 1.0 : 0.3,
            child: Text(
              text,
              textAlign: TextAlign.left, // 왼쪽 정렬
              style: body_small(context).copyWith(color: isCompleted ? customColors.primary : customColors.neutral60),
            ),
          ),
        ],
      ),
    );
  }
}
