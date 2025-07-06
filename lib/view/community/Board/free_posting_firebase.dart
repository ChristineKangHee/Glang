/// File: free_posting_firebase.dart
/// Purpose: 자유글 작성 페이지 클래스
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/alarm_dialog.dart';
import '../../components/custom_app_bar.dart';
import 'Component/taginput_component.dart';
import 'Component/writingform_component.dart';
import 'community_service.dart';
import 'package:easy_localization/easy_localization.dart';

// 자유글 작성 페이지 클래스
class FreeWritingPage extends ConsumerStatefulWidget {
  @override
  _FreeWritingPageState createState() => _FreeWritingPageState();
}

class _FreeWritingPageState extends ConsumerState<FreeWritingPage> {
  final CommunityService _communityService = CommunityService();
  String selectedCategory = ''; // 선택된 카테고리
  TextEditingController titleController = TextEditingController(); // 제목 입력 컨트롤러
  TextEditingController contentController = TextEditingController(); // 내용 입력 컨트롤러
  TextEditingController tagController = TextEditingController(); // 태그 입력 컨트롤러
  List<String> tags = []; // 태그 목록
  Timer? _debounce; // 디바운스 타이머

  FocusNode titleFocusNode = FocusNode(); // 제목 포커스 노드
  FocusNode contentFocusNode = FocusNode(); // 내용 포커스 노드

  @override
  void initState() {
    super.initState();
    // 제목, 내용, 태그 컨트롤러에 리스너 추가
    titleController.addListener(() => setState(() {}));
    contentController.addListener(() => setState(() {}));
    tagController.addListener(() => setState(() {}));
  }

  // 제목과 내용이 비어있지 않은지 확인하는 함수
  bool isContentValid() {
    return titleController.text.isNotEmpty && contentController.text.isNotEmpty;
  }

  // 저장되지 않은 변경사항이 있는지 확인하는 함수
  bool hasUnsavedChanges() {
    return titleController.text.isNotEmpty || contentController.text.isNotEmpty;
  }

  // 태그 추가 함수
  void addTag() {
    if (tagController.text.isNotEmpty && tags.length < 3) {
      setState(() {
        tags.add(tagController.text); // 태그 추가
        tagController.clear(); // 태그 입력창 비우기
      });
    }
  }

  // 태그 삭제 함수
  void removeTag(String tag) {
    setState(() {
      tags.remove(tag); // 태그 삭제
    });
  }

  // 게시글 제출 함수
  Future<void> submitPost() async {
    if (!isContentValid()) return; // 내용이 유효하지 않으면 종료
    try {
      await _communityService.createPost(
        title: titleController.text,
        content: contentController.text,
        category: "자유글", // 자동으로 "자유글" 카테고리 설정
        tags: tags,
      );
      discardDraft(); // 작성한 초안 초기화
      Navigator.of(context).pop(); // 이전 페이지로 돌아가기
    } catch (e) {
      // 게시글 작성 실패 시 알림 창 표시
      showResultSaveDialog(
        context,
        ref.watch(customColorsProvider),
        // 실패 메시지
        "community.write_fail".tr(),
        "common.cancel".tr(),
        "common.exit".tr(),
            (ctx) => Navigator.of(ctx).pop(),
      );
    }
  }

  // 초안 삭제 함수
  void discardDraft() {
    setState(() {
      titleController.clear(); // 제목 입력창 비우기
      contentController.clear(); // 내용 입력창 비우기
      tagController.clear(); // 태그 입력창 비우기
      tags.clear(); // 태그 목록 초기화
    });
  }

  // 페이지를 닫을 때의 동작
  void _handleClose() async {
    if (hasUnsavedChanges()) {
      // 저장되지 않은 변경사항이 있으면 확인 창 표시
      showResultSaveDialog(
        context,
        ref.watch(customColorsProvider),
          // 나가기 확인 다이얼로그
          "community.exit_confirm".tr(),
          "common.cancel".tr(),
          "common.exit".tr(),
            (ctx) {
          discardDraft(); // 초안 삭제
          Navigator.of(ctx).pop(); // 이전 페이지로 돌아가기
        },
        continuationMessage: "community.unsaved_warning".tr(),
      );
    } else {
      Navigator.of(context).pop(); // 변경사항이 없으면 바로 이전 페이지로 돌아가기
    }
  }

  // 뒤로 가기 버튼을 눌렀을 때의 동작
  Future<bool> _onWillPop() async {
    if (hasUnsavedChanges()) {
      // 저장되지 않은 변경사항이 있으면 확인 창 표시
      showResultSaveDialog(
        context,
        ref.watch(customColorsProvider),
        "community.exit_confirm".tr(),
        "common.cancel".tr(),
        "common.exit".tr(),
            (ctx) {
          discardDraft(); // 초안 삭제
          Navigator.of(ctx).pop(); // 이전 페이지로 돌아가기
        },
        continuationMessage:"community.unsaved_warning".tr(),
      );
      return false; // 페이지가 닫히지 않도록 방지
    }
    return true; // 변경사항이 없으면 페이지를 닫도록 허용
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider); // 커스텀 색상 값 가져오기
    return WillPopScope(
      onWillPop: _onWillPop, // 뒤로 가기 동작 처리
      child: Scaffold(
        appBar: CustomAppBar_2depth_9(
          // 앱바 타이틀
          title: "community.free".tr(),
          onIconPressed: _handleClose, // 뒤로 가기 버튼 동작
          actions: [
            TextButton(
              onPressed: isContentValid() ? submitPost : null, // 등록 버튼, 내용이 유효할 때만 활성화
              // 등록 버튼
              child: Text(
                "common.submit".tr(),
                style: body_xsmall_semi(context).copyWith(
                  color: isContentValid() ? customColors.primary : customColors.neutral80,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // 페이지 여백
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 작성 폼 컴포넌트
              WritingFormComponent(
                titleController: titleController,
                contentController: contentController,
                titleFocusNode: titleFocusNode,
                contentFocusNode: contentFocusNode,
                customColors: customColors,
              ),
              const SizedBox(height: 34), // 간격
              // 태그 입력 컴포넌트
              TagInputComponent(
                tagController: tagController,
                tags: tags,
                onAddTag: addTag, // 태그 추가 함수
                onRemoveTag: removeTag, // 태그 삭제 함수
                customColors: customColors,
              ),
              const SizedBox(height: 20), // 간격
            ],
          ),
        ),
      ),
    );
  }
}
