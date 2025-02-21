/// File: notedialog.dart
/// Purpose: 사용자가 선택한 문장을 기반으로 메모를 작성할 수 있는 다이얼로그 위젯
/// Author: 강희
/// Created: 2024-1-19
/// Last Modified: 2024-1-30 by 강희

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:readventure/model/reading_data.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import 'package:readventure/view/feature/reading/GA_02/sentence_interpretation.dart';
import 'package:readventure/view/feature/reading/GA_02/word_interpretation.dart';
import '../../../../viewmodel/memo_notifier.dart';
import '../../after_read/widget/answer_section.dart';
import 'reading_chatbot.dart';

/// 사용자가 선택한 문장을 기반으로 메모를 작성할 수 있는 다이얼로그 위젯
class NoteDialog extends StatefulWidget {
  final String selectedText; // 사용자가 선택한 문장
  final TextEditingController noteController; // 메모 입력을 위한 컨트롤러
  final dynamic customColors; // 사용자 지정 색상 테마
  final String stageId; // 해당 코스 레벨(stage)의 ID
  final String subdetailTitle; // 세부 타이틀 정보

  const NoteDialog({
    Key? key,
    required this.selectedText,
    required this.noteController,
    required this.customColors,
    required this.stageId,
    required this.subdetailTitle,
  }) : super(key: key);

  @override
  NoteDialogState createState() => NoteDialogState();
}

class NoteDialogState extends State<NoteDialog> {
  late Color saveButtonColor; // 저장 버튼 색상 (입력 여부에 따라 변경)
  bool isQuestionIncluded = false; // 질문 포함 여부 (미사용 변수)

  @override
  void initState() {
    super.initState();
    saveButtonColor = widget.customColors.primary20; // 초기 저장 버튼 색상 설정

    // 메모 입력 감지하여 저장 버튼 색상 변경
    widget.noteController.addListener(() {
      setState(() {
        saveButtonColor = widget.noteController.text.isNotEmpty
            ? widget.customColors.primary
            : widget.customColors.primary20;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16), // 다이얼로그 여백 설정
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: widget.customColors.neutral100, // 배경색
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // 모서리 둥글게 설정
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목 텍스트
              Text(
                '메모',
                textAlign: TextAlign.center,
                style: body_small_semi(context).copyWith(
                  color: widget.customColors.neutral30,
                ),
              ),
              const SizedBox(height: 24),

              // 선택된 문장 제목
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '선택된 문장',
                  style: body_xsmall_semi(context),
                ),
              ),
              const SizedBox(height: 12),

              // 선택된 문장 표시 박스
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: widget.customColors.neutral90),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.selectedText,
                    style: body_xsmall(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis, // 길면 말줄임표 처리
                  ),
                ),
              ),

              // 메모 입력 영역 (커스텀 위젯 적용)
              Answer_Section_No_Title(
                controller: widget.noteController,
                customColors: widget.customColors,
              ),
              const SizedBox(height: 20),

              // 취소 및 저장 버튼 영역
              Row(
                children: [
                  // 취소 버튼
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: ShapeDecoration(
                        color: widget.customColors.neutral90,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context), // 다이얼로그 닫기
                        child: Text(
                          '취소',
                          style: body_small_semi(context)
                              .copyWith(color: widget.customColors.neutral60),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 저장 버튼
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: ShapeDecoration(
                        color: saveButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: TextButton(
                        onPressed: saveButtonColor == widget.customColors.primary20
                            ? null
                            : () async {
                          final note = widget.noteController.text.trim();
                          if (note.isNotEmpty) {
                            // memoProvider를 통해 Firestore의 subcollection에 메모 저장
                            await ProviderScope.containerOf(context)
                                .read(memoProvider.notifier)
                                .addMemo(
                              stageId: widget.stageId,
                              subdetailTitle: widget.subdetailTitle,
                              selectedText: widget.selectedText,
                              note: note,
                            );
                            debugPrint('메모 저장: $note');
                          }

                          // 저장 완료 스낵바 표시
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Container(
                                padding: const EdgeInsets.all(16),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: widget.customColors.neutral60.withOpacity(0.8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '메모가 저장되었어요.',
                                      style: body_small_semi(context)
                                          .copyWith(color: widget.customColors.neutral100),
                                    ),
                                  ],
                                ),
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            ),
                          );

                          // 다이얼로그 닫기
                          Navigator.pop(context);
                        },
                        child: Text(
                          '저장',
                          style: body_small_semi(context)
                              .copyWith(color: widget.customColors.neutral100),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
