/// 파일: section.dart
/// 목적: 사용자에게 초급, 중급, 고급 코스를 보여줌
/// 작성자: 박민준
/// 생성일: 2024-12-28
/// 마지막 수정: 2025-01-06 by 강희

// 필요한 Flutter 및 커스텀 패키지들을 가져옵니다.
import 'package:flutter/material.dart';
import '../../util/box_shadow_styles.dart';
import 'course_subdetail.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';

// 섹션의 데이터와 관련 정보를 저장하는 데이터 모델 클래스
class SectionData {
  final Color color; // 섹션의 주 색상
  final Color colorOscuro; // 섹션의 어두운 색상
  final int etapa; // 섹션의 단계 식별자
  final int section; // 섹션 번호
  final String title; // 섹션 제목
  final String sectionDetail; // 섹션에 대한 상세 설명
  final List<String> subdetailTitle; // 하위 섹션의 제목 목록
  final List<String> totalTime; // 하위 섹션 별 총 소요 시간
  final List<String> achievement; // 하위 섹션 별 달성률
  final List<String> difficultyLevel; // 하위 섹션의 난이도
  final List<String> textContents; // 하위 섹션의 텍스트 콘텐츠
  final List<String> imageUrls; // 하위 섹션의 이미지 URL 목록
  final List<List<String>> missions; // 하위 섹션의 미션 목록
  final List<List<String>> effects; // 하위 섹션의 효과 목록
  final List<String> status; // 하위 섹션의 버튼 상태

  // 모든 필드를 초기화하는 생성자
  SectionData({
    required this.color,
    required this.colorOscuro,
    required this.etapa,
    required this.section,
    required this.title,
    required this.totalTime,
    required this.achievement,
    required this.difficultyLevel,
    required this.sectionDetail,
    required this.subdetailTitle,
    required this.textContents,
    required this.imageUrls,
    required this.missions,
    required this.effects,
    required this.status,
  });
}

// 섹션 및 하위 섹션을 나타내는 위젯 클래스
class Section extends StatelessWidget {
  final SectionData data; // 섹션 데이터

  const Section({super.key, required this.data});

  // 하위 섹션 버튼의 여백을 계산하는 메서드
  double _getMargin(int index, {bool isLeft = true}) {
    const margin = 72.0;
    int pos = index % 9;
    if (isLeft) {
      return (pos == 1 || pos == 3) ? margin : (pos == 2 ? margin * 2 : 0.0);
    } else {
      return (pos == 5 || pos == 7) ? margin : (pos == 6 ? margin * 2 : 0.0);
    }
  }

  // 하위 섹션의 상세 정보를 보여주는 팝업을 표시하는 메서드
  void _showPopup(BuildContext context, int index, CustomColors customColors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 70.0),
        child: Container(
          decoration: BoxDecoration(
            color: customColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: BoxShadowStyles.shadow1(context),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 팝업 상단에 섹션 제목과 하위 섹션 제목을 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: body_xsmall_semi(context).copyWith(
                              color: customColors.neutral100),
                        ),
                        Text(
                          data.subdetailTitle[index],
                          style: body_large_semi(context).copyWith(
                              color: customColors.neutral100),
                        ),
                      ],
                    ),
                    // "시작하기" 버튼
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailPage(
                              title: data.subdetailTitle[index],
                              time: data.totalTime[index].toString(),
                              level: data.difficultyLevel[index],
                              description: data.textContents[index],
                              imageUrl: data.imageUrls[index],
                              mission: data.missions[index],
                              effect: data.effects[index],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customColors.neutral100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                      ),
                      child: Text(
                        '시작하기',
                        style: body_xsmall_semi(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // 하위 섹션의 달성률, 시간, 난이도를 표시하는 행
                Row(
                  children: [
                    _buildIconWithText(context, Icons.check_circle,
                        data.achievement[index] + '%', customColors),
                    const SizedBox(width: 8),
                    _buildIconWithText(context, Icons.timer,
                        data.totalTime[index] + '분', customColors),
                    const SizedBox(width: 8),
                    _buildIconWithText(context, Icons.star,
                        data.difficultyLevel[index], customColors),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 아이콘과 텍스트를 함께 표시하는 위젯 생성 메서드
  Widget _buildIconWithText(
      BuildContext context, IconData icon, String text, CustomColors customColors) {
    return Row(
      children: [
        Icon(icon, color: customColors.neutral90, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: body_xsmall_semi(context).copyWith(
              color: customColors.neutral90),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 섹션 제목과 설명을 포함한 헤더
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: data.color),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data.title, style: body_large_semi(context)),
                Text(data.sectionDetail, style: body_small(context)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        // 하위 섹션 버튼들 생성
        ...List.generate(
          data.subdetailTitle.length,
              (i) => Container(
            margin: EdgeInsets.only(
              bottom: i != data.subdetailTitle.length - 1 ? 24.0 : 0,
              left: _getMargin(i),
              right: _getMargin(i, isLeft: false),
            ),
            child: ElevatedButton(
              onPressed: () => _showPopup(context, i, customColors),
              style: ElevatedButton.styleFrom(
                overlayColor: _getButtonState(i, customColors).backgroundColor,
                backgroundColor: _getButtonState(i, customColors).backgroundColor,
                fixedSize: const Size(80, 80),
                elevation: 0,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size.zero,
              ),
              child: _getButtonState(i, customColors).icon,
            ),
          ),
        ),
      ],
    );
  }

  // 상태에 따라 버튼의 상태와 모양을 결정하는 메서드
  _ButtonState _getButtonState(int index, CustomColors customColors) {
    String status = data.status[index];
    IconData icon;
    Color? backgroundColor;

    switch (status) {
      case 'completed':
        icon = Icons.check;
        backgroundColor = customColors.primary40;
        break;
      case 'before_completion':
        icon = Icons.lock;
        backgroundColor = customColors.neutral80;
        break;
      default:
        icon = Icons.play_arrow_rounded;
        backgroundColor = customColors.primary;
    }

    double iconSize = (icon == Icons.play_arrow_rounded) ? 50.0 : 30.0;

    return _ButtonState(
      icon: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: (status == 'before_completion')
              ? customColors.neutral30
              : customColors.neutral100,
          size: iconSize,
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}

// 버튼의 외형을 관리하는 클래스
class _ButtonState {
  final Widget icon; // 버튼 아이콘 위젯
  final Color? backgroundColor; // 버튼 배경색

  _ButtonState({required this.icon, required this.backgroundColor});
}
