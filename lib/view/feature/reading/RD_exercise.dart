import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 사용자 정의 폰트 스타일, 색상, 컴포넌트 import
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/my_divider.dart';

// Riverpod 상태 관리를 사용한 CustomSelectableText 위젯 정의
class CustomSelectableText extends ConsumerStatefulWidget {
  const CustomSelectableText({super.key});  // const 생성자는 성능 최적화를 위해 사용

  @override
  _CustomSelectableTextState createState() => _CustomSelectableTextState();
}

// CustomSelectableText 위젯의 상태 클래스 정의
class _CustomSelectableTextState extends ConsumerState<CustomSelectableText> {
  @override
  Widget build(BuildContext context) {
    // customColorsProvider에서 사용자 정의 색상 정보 가져오기
    final customColors = ref.watch(customColorsProvider);

    // MaterialApp과 Scaffold를 사용하여 기본 레이아웃 설정
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Custom Text Selection')), // AppBar에 제목 추가
        body: Center(
          // 텍스트 선택이 가능한 SelectableText 위젯을 중앙에 배치
          child: SelectableText(
            '드래그해서 선택하세요! 드래그 할 수 있는 많고 많은 텍스트들 한번 해봐라\n 으히히',
            selectionControls: RdMain(customColors: customColors), // 커스텀 선택 컨트롤 적용
            style: const TextStyle(fontSize: 20), // 텍스트 스타일 설정 (폰트 크기 20)
            cursorColor: customColors.primary, // 커서 색상을 사용자 정의 색상으로 설정
          ),
        ),
      ),
    );
  }
}

// MaterialTextSelectionControls를 확장하여 커스텀 텍스트 선택 컨트롤 구현
class RdMain extends MaterialTextSelectionControls {
  final customColors; // customColors를 저장할 필드 추가

  // 생성자에서 customColors를 받아와서 저장
  RdMain({required this.customColors});

  @override
  void handleCopy(TextSelectionDelegate delegate) {
    // 텍스트 복사 시 커스텀 메시지와 함께 복사
    final text = delegate.textEditingValue.selection.textInside(delegate.textEditingValue.text);
    Clipboard.setData(ClipboardData(text: '커스텀 복사: $text')); // 복사된 텍스트에 "커스텀 복사" 추가
    delegate.bringIntoView(delegate.textEditingValue.selection.extent); // 선택된 텍스트를 화면에 맞추기
    delegate.hideToolbar(); // 복사 후 툴바 숨기기
  }

  @override
  Widget buildToolbar(
      BuildContext context,
      Rect globalEditableRegion,
      double textLineHeight,
      Offset position,
      List<TextSelectionPoint> endpoints,
      TextSelectionDelegate delegate,
      ValueListenable<ClipboardStatus>? clipboardStatus,
      Offset? lastSecondaryTapDownPosition,
      ) {
    const double toolbarHeight = 50; // 툴바의 높이 설정

    // 커스텀 툴바 위젯 반환
    return Center(
      child: ToolBar(toolbarHeight, context), // 화면 중앙에 툴바 배치
    );
  }

  // 커스텀 툴바 위젯을 만드는 메서드
  Container ToolBar(double toolbarHeight, BuildContext context) {
    return Container(
      child: Material(
        color: Colors.transparent, // 툴바 배경을 투명하게 설정
        child: Container(
          height: toolbarHeight, // 툴바의 높이 설정
          decoration: BoxDecoration(
            color: customColors.neutral90, // 사용자 정의 색상 적용
            borderRadius: BorderRadius.circular(10), // 툴바 모서리를 둥글게 처리
            boxShadow: [
              BoxShadow(
                color: Color(0x3F000000), // 그림자 색상 설정
                blurRadius: 30, // 그림자 블러 효과
                offset: Offset(0, 2), // 그림자 위치 설정
                spreadRadius: 0, // 그림자 확산 정도
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8), // 툴바 내 패딩 설정
          child: Row(
            mainAxisSize: MainAxisSize.min, // 버튼들을 가로로 배치
            children: [
              // 툴바 버튼들 (밑줄, 메모, 해석, 챗봇)
              _buildToolbarButton(context, '밑줄', () {}),
              _buildToolbarButton(context, '메모', () {}),
              _buildToolbarButton(context, '해석', () {}),
              _buildToolbarButton(context, '챗봇', () {}),
            ],
          ),
        ),
      ),
    );
  }

  // 툴바 버튼을 만드는 메서드
  Widget _buildToolbarButton(BuildContext context, String label, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8), // 버튼 내부 패딩
      child: Row(
        mainAxisSize: MainAxisSize.min, // 버튼 내용을 가로로 배치
        children: [
          Text(
            label, // 버튼에 표시될 텍스트
            style: body_small_semi(context).copyWith( // 사용자 정의 색상으로 텍스트 스타일 적용
              color: customColors.neutral0,
            ),
          ),
          Divider(), // 버튼들 사이에 구분선 추가
        ],
      ),
    );
  }
}
