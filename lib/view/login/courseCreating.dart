import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import '../../viewmodel/custom_colors_provider.dart';

class CourseProcessingPage extends ConsumerStatefulWidget {
  @override
  _CourseProcessingPageState createState() => _CourseProcessingPageState();
}

class _CourseProcessingPageState extends ConsumerState<CourseProcessingPage> {
  bool _isProcessing = true; // 로딩 상태
  double _progress = 0.0; // 진행 상태

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
      appBar: AppBar(
        title: Text("맞춤 코스 만들기"),
      ),
      body: Center(
        child: _isProcessing
            ? _buildProcessingBody(customColors) // 로딩 중일 때
            : _buildCompletionBody(customColors), // 완료 후
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isProcessing = !_isProcessing; // 로딩 상태 토글
          });
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  // 로딩 중일 때의 화면 구성
  Widget _buildProcessingBody(CustomColors customColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // 동그라미 진행 상태
            SizedBox(
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
            // 진행 상태를 퍼센트로 표시
            Text(
              '${(_progress * 100).toStringAsFixed(0)}%',
              style: heading_large(context).copyWith(color: customColors.neutral30)
            ),
          ],
        ),
        const SizedBox(height: 20),
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
        Icon(Icons.check_circle_rounded, size: 50, color: customColors.primary),
        SizedBox(height: 20),
        Text(
          "코스 생성 완료!",
          style: heading_large(context),
        ),
        SizedBox(height: 12),
        Text(
          '모든 설정이 완료되었어요.\n이제 글 읽기를 시작해볼까요?',
          textAlign: TextAlign.center,
          style: body_small_semi(context).copyWith(color: customColors.neutral60),
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
          Text(
            '맞춤 코스 만드는 중...',
            textAlign: TextAlign.center,
            style: heading_large(context),
          ),
          const SizedBox(height: 6),
          Text(
            '제로님께 필요한 코스를 찾고 있어요',
            textAlign: TextAlign.center,
            style: body_small_semi(context).copyWith(color: customColors.neutral60),
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
          .map((text) => _buildInfoRow(text, customColors))
          .toList(),
    );
  }

  // 항목에 대한 정보 Row 구성
  Widget _buildInfoRow(String text, CustomColors customColors) {
    return Container(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: customColors.neutral80),
          const SizedBox(width: 15),
          Text(
            text,
            style: body_small(context).copyWith(color: customColors.neutral60),
          ),
        ],
      ),
    );
  }
}
