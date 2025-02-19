/// File: diagram_learning.dart
/// Purpose: 사용자가 단어를 트리 구조의 노드에 드래그 앤 드롭하여 트리 구조를 완성하도록 설계되었습니다.
/// Author: 강희
/// Created: 2024-1-17
/// Last Modified: 2024-02-11 by 박민준

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';
import 'package:readventure/view/feature/after_read/GA_03_04_diagram/submission_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../model/section_data.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../../viewmodel/user_service.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_button.dart';
import '../../../home/stage_provider.dart';
import '../choose_activities.dart';
import '../widget/title_section_learning.dart';
import 'diagram_main.dart';

/// ─────────── 정답 정보 및 제출 상태 Provider ───────────
/// ─────────── 제출 상태/완료 상태 Provider ───────────
final submissionStatusProvider = StateProvider<bool>((ref) => false);
final submissionCompleteProvider = StateProvider<bool>((ref) => false);

/// ─────────── 단어 리스트를 관리하기 위한 StateNotifierProvider ───────────
/// 1) Firestore에서 가져온 wordList를 초기값으로 설정
final wordListProvider = StateNotifierProvider<WordListNotifier, List<String>>((ref) {
  final stage = ref.watch(currentStageProvider);
  // diagramData 안의 wordList를 가져온다
  final diagramData = stage?.arData?.featureData?['feature4Diagram'] as Map<String, dynamic>?;
  final words = (diagramData?['wordList'] as List<dynamic>?)?.cast<String>() ?? [];
  return WordListNotifier(words);
});

// 단어 리스트 관리 클래스
class WordListNotifier extends StateNotifier<List<String>> {
  WordListNotifier(List<String> initialWords) : super(initialWords);

  void removeWord(String word) {
    state = state.where((w) => w != word).toList();
  }

  void resetWords() {
    state = []; // wordList를 비움
  }
}

/// ─────────── 노드 라벨을 관리하기 위한 StateNotifierProvider ───────────
final nodeLabelProvider = StateNotifierProvider<NodeLabelNotifier, Map<String, String>>((ref) {
  return NodeLabelNotifier();
});

class NodeLabelNotifier extends StateNotifier<Map<String, String>> {
  NodeLabelNotifier() : super({});

  void updateNodeLabel(String nodeId, String label) {
    state = {...state, nodeId: label};
  }

  String getNodeLabel(String nodeId) {
    return state[nodeId] ?? "";
  }

  void clearNodeLabels() {
    state = state.map((key, value) => MapEntry(key, ""));
  }
}

/// ─────────── 트리 다이어그램 화면 ───────────
class RootedTreeScreen extends ConsumerWidget {
  RootedTreeScreen({Key? key}) : super(key: key);

  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  final dialogShownProvider = StateProvider<bool>((ref) => false);

  /// 트리를 재귀적으로 그리는 헬퍼
  void buildTree(Graph graph, Map<String, dynamic> data, Node? parentNode) {
    final Node currentNode = Node.Id(data['id']);
    if (parentNode != null) {
      graph.addEdge(parentNode, currentNode);
    }
    if (data['children'] != null) {
      for (var child in data['children']) {
        buildTree(graph, child, currentNode);
      }
    }
  }

  final GlobalKey<CustomAppBar_2depth_8State> _appBarKey = GlobalKey<CustomAppBar_2depth_8State>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1) 현재 스테이지 데이터 구독
    final stage = ref.watch(currentStageProvider);
    // 2) 만약 로딩 중이거나 stage가 없으면 처리
    if (stage == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 3) stage.arData?.featureData['feature4Diagram']에서 다이어그램 정보 추출
    final diagramData = stage.arData?.featureData?['feature4Diagram'] as Map<String, dynamic>?;
    if (diagramData == null) {
      // 다이어그램 데이터가 없을 경우
      return const Scaffold(
        body: Center(child: Text("다이어그램 데이터가 없습니다.")),
      );
    }

    // 4) Firestore에서 불러온 treeStructure, correctAnswers 등
    final treeStructure = (diagramData['treeStructure'] as List<dynamic>?) ?? [];
    final correctAnswers = (diagramData['correctAnswers'] as Map<String, dynamic>?) ?? {};
    final diagramTitle = diagramData['title'] as String? ?? "다이어그램";
    final diagramSubtitle = diagramData['subtitle'] as String? ?? "";
    // 아래처럼 Map<String,String> 형태로 변환
    final correctAnswersMap = correctAnswers.map((key, value) => MapEntry(key, value.toString()));

    // 그래프 초기화
    final graph = Graph();
    if (treeStructure.isNotEmpty) {
      buildTree(graph, treeStructure.first, null);
    }
    // 트리 레이아웃 설정
    builder
      ..siblingSeparation = 30
      ..levelSeparation = 70
      ..subtreeSeparation = 50
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

    // 5) 앱에 필요한 나머지 Provider/상태 구독
    final customColors = ref.watch(customColorsProvider);
    final dialogShown = ref.watch(dialogShownProvider);

    // 처음 로드 시, 다이얼로그 띄우기 (diagramMainDialog)
    if (!dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const DiagramMainDialog();
          },
        );
        ref.read(dialogShownProvider.notifier).state = true;
      });
    }
    // SubmissionNotifier의 상태를 listen 합니다.
    ref.listen<SubmissionStatus>(submissionNotifierProvider, (prev, next) async {
      if (next == SubmissionStatus.success) {
        // 제출 성공 시 안전하게 네비게이션 실행
        final elapsedSeconds = _appBarKey.currentState?.elapsedSeconds ?? 0;

        // 사용자 학습시간 업데이트
        final userId = ref.watch(userIdProvider);
        if (userId != null) {
          await ref.read(userServiceProvider).updateLearningTime(elapsedSeconds);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LearningActivitiesPage()),
        );
      }
      // 실패한 경우 에러 다이얼로그 등 추가 처리할 수 있습니다.
    });
    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_2depth_8(title: '다이어그램', key: _appBarKey,),
      body: Column(
        children: [
          // 상단 안내영역
          Container(
            decoration: ShapeDecoration(
              color: customColors.neutral100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TitleSection_withIcon(
                customColors: Theme.of(context).extension<CustomColors>()!,
                title: diagramTitle,
                subtitle: diagramSubtitle,
                author: " ",
              ),
            ),
          ),
          // 트리 다이어그램 영역
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 화면 크기에 따라 간격 동적으로 조정
                    final nodeCount = graph.nodeCount();
                    builder
                      ..siblingSeparation = (constraints.maxWidth / (nodeCount * 1.5))
                          .clamp(20, 100)
                          .toInt()
                      ..levelSeparation = (constraints.maxHeight / (nodeCount * 2.5))
                          .clamp(50, 200)
                          .toInt();

                    return InteractiveViewer(
                      constrained: false,
                      child: GraphView(
                        graph: graph,
                        algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                        paint: Paint()
                          ..color = customColors.neutral80!
                          ..strokeWidth = 1.5
                          ..style = PaintingStyle.stroke,
                        builder: (Node node) {
                          final nodeId = node.key!.value as String;
                          return nodeWidget(nodeId, ref, correctAnswersMap);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // 단어 리스트 + 제출 버튼
          WordListWidget(correctAnswersMap: correctAnswersMap),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 노드 위젯: nodeId에 매핑된 라벨 표시 + 드래그 타겟
  Widget nodeWidget(String nodeId, WidgetRef ref, Map<String, String> correctAnswersMap) {
    final label = ref.watch(nodeLabelProvider.select((map) => map[nodeId] ?? ""));
    final customColors = ref.watch(customColorsProvider);
    final submitted = ref.watch(submissionStatusProvider);

    // 제출 후 정답/오답 색상 처리
    Color? nodeColor;
    if (submitted) {
      String correctAnswer = correctAnswersMap[nodeId] ?? "";
      nodeColor = (label == correctAnswer)
          ? customColors.success40
          : customColors.error40;
    } else {
      // 제출 전 기본 색상
      switch (nodeId) {
        case 'Root':
          nodeColor = customColors.secondary;
          break;
        case 'Child 1':
        case 'Child 2':
        case 'Child 3':
          nodeColor = customColors.primary60;
          break;
        default:
          nodeColor = customColors.primary40;
          break;
      }
    }

    return GestureDetector(
      onTap: () {
        if (label.isNotEmpty) {
          // 노드에 배치된 단어를 다시 워드리스트로 이동
          ref.read(wordListProvider.notifier).state = [
            ...ref.read(wordListProvider),
            label
          ];
          // 노드 라벨 초기화
          ref.read(nodeLabelProvider.notifier).updateNodeLabel(nodeId, "");
          // 제출 상태도 초기화
          ref.read(submissionStatusProvider.notifier).state = false;
          ref.read(submissionCompleteProvider.notifier).state = false;
        }
      },
      child: DragTarget<String>(
        onAccept: (droppedWord) {
          ref.read(nodeLabelProvider.notifier).updateNodeLabel(nodeId, droppedWord);
          ref.read(wordListProvider.notifier).removeWord(droppedWord);
        },
        onWillAccept: (data) => label.isEmpty, // 이미 단어가 있으면 드롭 불가
        builder: (context, candidateData, rejectedData) {
          return Container(
            width: 80,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: candidateData.isNotEmpty ? customColors.success40 : nodeColor,
            ),
            child: Text(
              label.isEmpty ? " " : label,
              style: body_small_semi(context)
                  .copyWith(fontSize: 12, color: customColors.neutral100),
            ),
          );
        },
      ),
    );
  }
}

/// ─────────── 단어 리스트 + 제출 로직 ───────────
class WordListWidget extends ConsumerStatefulWidget {
  final Map<String, String> correctAnswersMap;
  const WordListWidget({Key? key, required this.correctAnswersMap}) : super(key: key);

  @override
  _WordListWidgetState createState() => _WordListWidgetState();
}

class _WordListWidgetState extends ConsumerState<WordListWidget> {
  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    final wordList = ref.watch(wordListProvider);
    final submitted = ref.watch(submissionStatusProvider);
    final complete = ref.watch(submissionCompleteProvider);

    // 버튼 텍스트 처리
    final buttonTitle = submitted
        ? (complete ? '제출 완료' : '수정하기')
        : '제출하기';

    // 모든 단어가 노드에 배치되면 → 제출/수정 버튼 표시
    if (wordList.isEmpty) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ButtonPrimary(
          function: () async {
            // 단순히 SubmissionNotifier의 submitFeature()를 호출합니다.
            await ref
                .read(submissionNotifierProvider.notifier)
                .submitFeature(widget.correctAnswersMap);
          },
          title: buttonTitle,
        ),
      );
    }

    // 아직 배치 안된 단어들이 있다면 → Draggable 리스트 표시
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        width: double.infinity,
        decoration: ShapeDecoration(
          color: customColors.neutral100,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: wordList.map((word) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: ShapeDecoration(
                  color: customColors.neutral90,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Draggable<String>(
                  data: word,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _buildDraggableFeedback(word, customColors, context),
                  ),
                  childWhenDragging: const SizedBox(),
                  child: Text(word, style: body_small(context)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDraggableFeedback(String word, CustomColors customColors, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: customColors.neutral90,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(word, style: body_small(context)),
    );
  }
}
