/// File: diagram_learning.dart
/// Purpose: 사용자가 단어를 트리 구조의 노드에 드래그 앤 드롭하여 트리 구조를 완성하도록 설계되었습니다.
/// Author: 강희
/// Created: 2024-1-17
/// Last Modified: 2024-02-11 by 박민준

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';

import '../../../../model/section_data.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_button.dart';
import '../../../home/stage_provider.dart';
import '../choose_activities.dart';
import '../widget/title_section_learning.dart';
import 'diagram_main.dart';

/// ─────────── 정답 정보 및 제출 상태 Provider ───────────
/// 각 노드에 들어가야 하는 정답 (노드 생성 순서에 맞게 매핑)
const Map<String, String> correctAnswers = {
  'Root': '읽기 시스템',
  'Child 1': '문제점',
  'Grandchild 1': '교육 시스템',
  'Grandchild 2': '피드백 부족',
  'Child 2': '해결방안',
  'Grandchild 3': '맞춤형 읽기 도구',
  'Grandchild 4': '실시간 피드백',
  'Child 3': '기대효과',
  'Grandchild 5': '읽기 능력 향상',
  'Grandchild 6': '자기주도 학습 강화',
};

/// 제출 여부 (사용자가 제출 버튼을 누른 상태)
final submissionStatusProvider = StateProvider<bool>((ref) => false);
/// 모든 노드가 정답일 경우 제출 완료 상태
final submissionCompleteProvider = StateProvider<bool>((ref) => false);

/// ─────────── 단어 리스트를 관리하기 위한 StateNotifierProvider ───────────
final wordListProvider = StateNotifierProvider<WordListNotifier, List<String>>((ref) {
  return WordListNotifier([
    '읽기 시스템',
    '문제점',
    '교육 시스템',
    '피드백 부족',
    '해결방안',
    '맞춤형 읽기 도구',
    '실시간 피드백',
    '기대효과',
    '읽기 능력 향상',
    '자기주도 학습 강화'
  ]);
});

// 단어 리스트 관리 클래스
class WordListNotifier extends StateNotifier<List<String>> {
  WordListNotifier(List<String> initialWords) : super(initialWords);

  // 단어를 리스트에서 제거하는 메서드
  void removeWord(String word) {
    state = state.where((w) => w != word).toList();
  }
}

/// ─────────── 노드 라벨을 관리하기 위한 StateNotifierProvider ───────────
final nodeLabelProvider = StateNotifierProvider<NodeLabelNotifier, Map<String, String>>((ref) {
  return NodeLabelNotifier();
});

// 노드 라벨 관리 클래스
class NodeLabelNotifier extends StateNotifier<Map<String, String>> {
  NodeLabelNotifier() : super({});

  // 특정 노드의 라벨 업데이트
  void updateNodeLabel(String nodeId, String label) {
    state = {
      ...state,
      nodeId: label,
    };
  }

  // 특정 노드의 라벨 가져오기
  String getNodeLabel(String nodeId) {
    return state[nodeId] ?? "";
  }

  // 모든 노드 라벨 초기화
  void clearNodeLabels() {
    state = state.map((key, value) => MapEntry(key, ""));
  }
}

/// ─────────── 트리 다이어그램 화면 ───────────
class RootedTreeScreen extends ConsumerWidget {
  final Graph graph = Graph(); // 트리 구조 정의
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration(); // 트리 배치 알고리즘 설정

  // 생성자에서 트리 구조와 설정 초기화
  RootedTreeScreen({Key? key}) : super(key: key) {
    final List<Map<String, dynamic>> data = [
      {
        'id': 'Root',
        'children': [
          {
            'id': 'Child 1',
            'children': [
              {'id': 'Grandchild 1'},
              {'id': 'Grandchild 2'},
            ]
          },
          {
            'id': 'Child 2',
            'children': [
              {'id': 'Grandchild 3'},
              {'id': 'Grandchild 4'},
            ]
          },
          {
            'id': 'Child 3',
            'children': [
              {'id': 'Grandchild 5'},
              {'id': 'Grandchild 6'},
            ]
          }
        ]
      }
    ];

    buildTree(graph, data.first, null);

    builder
      ..siblingSeparation = 30 // 형제 노드 간 거리
      ..levelSeparation = 70 // 계층 간 거리
      ..subtreeSeparation = 50 // 서브트리 간 거리
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM; // 트리 방향 설정
  }

  // 재귀적으로 트리 노드 및 간선 추가
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

  final dialogShownProvider = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final dialogShown = ref.watch(dialogShownProvider);

    if (!dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const DiagramMainDialog();
          },
        );
        ref.read(dialogShownProvider.notifier).state = true; // 다이얼로그가 표시되었음을 기록
      });
    }

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_2depth_8(
        title: '다이어그램',
      ),
      body: Column(
        children: [
          Container(
            decoration: ShapeDecoration(
              color: customColors.neutral100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TitleSection_withIcon(
                customColors: Theme.of(context).extension<CustomColors>()!,
                title: "트리 구조에 알맞는 단어를 넣어주세요!",
                subtitle: "<읽기의 중요성>",
                author: " ",
              ),
            ),
          ),
          RootedTree(customColors, ref, context),
          WordListWidget(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 트리 다이어그램 위젯
  Widget RootedTree(CustomColors customColors, WidgetRef ref, BuildContext context) {
    final nodeCount = graph.nodeCount();
    final size = MediaQuery.of(context).size;

    builder
      ..siblingSeparation = (size.width / (nodeCount * 1.5)).clamp(20, 100).toInt()
      ..levelSeparation = (size.height / (nodeCount * 2.5)).clamp(50, 200).toInt();

    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // 양옆 마진 추가
        child: Center(
          child: InteractiveViewer(
            constrained: false,
            child: GraphView(
              graph: graph,
              algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
              paint: Paint()
                ..color = customColors.neutral80!
                ..strokeWidth = 1.5
                ..style = PaintingStyle.stroke,
              builder: (Node node) {
                String nodeId = node.key!.value as String;
                return nodeWidget(nodeId, ref);
              },
            ),
          ),
        ),
      ),
    );
  }

  // 노드 위젯 생성 – 제출 여부에 따라 색상이 변경됨
  Widget nodeWidget(String nodeId, WidgetRef ref) {
    String label = ref.watch(nodeLabelProvider.select((map) => map[nodeId] ?? ""));
    final customColors = ref.watch(customColorsProvider);
    final submitted = ref.watch(submissionStatusProvider);

    Color? nodeColor;
    if (submitted) {
      // 제출 후: 정답이면 success40, 오답이면 error40
      String correctAnswer = correctAnswers[nodeId] ?? "";
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
          // 노드에 배치된 단어를 다시 워드리스트로 돌려보내고 라벨 초기화
          ref.read(wordListProvider.notifier).state = [
            ...ref.read(wordListProvider),
            label
          ];
          ref.read(nodeLabelProvider.notifier).updateNodeLabel(nodeId, "");
          // 수정 시 제출 상태 초기화 (노드 색상이 기본으로 돌아감)
          ref.read(submissionStatusProvider.notifier).state = false;
          ref.read(submissionCompleteProvider.notifier).state = false;
        }
      },
      child: DragTarget<String>(
        onAccept: (droppedWord) {
          ref.read(nodeLabelProvider.notifier).updateNodeLabel(nodeId, droppedWord);
          ref.read(wordListProvider.notifier).removeWord(droppedWord);
        },
        onWillAccept: (data) => label.isEmpty,
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

/// ─────────── 단어 리스트 위젯 정의 ───────────
class WordListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final wordList = ref.watch(wordListProvider);
    final submitted = ref.watch(submissionStatusProvider);
    final complete = ref.watch(submissionCompleteProvider);

    // 버튼 텍스트: 제출 전 → '제출하기', 제출 후 오답이 있으면 → '수정하기',
    // 이미 정답이면 → '제출 완료'
    final buttonTitle = submitted
        ? (complete ? '제출 완료' : '수정하기')
        : '제출하기';

    // 모든 단어가 노드에 배치되었을 때 버튼 표시
    return wordList.isEmpty
        ? Container(
      width: MediaQuery.of(context).size.width,
      child: ButtonPrimary(
        function: () async {
          final isSubmitted = ref.read(submissionStatusProvider);
          final isComplete = ref.read(submissionCompleteProvider);

          // 이미 제출 상태이며 모든 노드가 정답인 경우 → 제출 완료 상태이므로 페이지 이동
          if (isSubmitted && isComplete) {
            final freshStages = await ref.refresh(stagesProvider.future);
            // 선택한 스테이지 ID를 읽음
            final selectedId = ref.read(selectedStageIdProvider);
            StageData? freshStage;
            if (selectedId != null) {
              // 최신 스테이지 목록에서 선택한 스테이지를 찾음
              freshStage = freshStages.firstWhereOrNull((stage) => stage.stageId == selectedId);
            }
            if (freshStage != null) {
              // feature3(토론 활동에 해당하는 feature 번호 3)를 완료 처리
              await updateFeatureCompletion(freshStage, 4, true);
              // stagesProvider를 무효화하여 최신 상태로 갱신
              ref.invalidate(stagesProvider);
              // ref.invalidate(selectedStageIdProvider); // 혹시 모를 캐싱 문제 방지
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LearningActivitiesPage()),
            );
          }
          // 제출 전인 경우 → 제출 시 오답 체크 (제출 시도)
          else if (!isSubmitted) {
            ref.read(submissionStatusProvider.notifier).state = true;
            final nodeLabels = ref.read(nodeLabelProvider);
            bool allCorrect = true;
            for (var nodeId in correctAnswers.keys) {
              if (nodeLabels[nodeId] != correctAnswers[nodeId]) {
                allCorrect = false;
                break;
              }
            }
            if (allCorrect) {
              // 모든 노드 정답 → UI에 success40로 표시하고 버튼 텍스트는 '제출 완료'로 변경
              ref.read(submissionCompleteProvider.notifier).state = true;
            } else {
              // 오답이 있을 경우 → 버튼 텍스트를 '수정하기'로 변경
              ref.read(submissionCompleteProvider.notifier).state = false;
            }
          }
          // 제출 후 오답이 있는 상태에서 '수정하기'를 누른 경우
          else {
            final nodeLabels = ref.read(nodeLabelProvider);
            final wrongNodes = <String>[];
            correctAnswers.forEach((nodeId, correctAnswer) {
              final currentLabel = nodeLabels[nodeId] ?? "";
              if (currentLabel != correctAnswer) {
                if (currentLabel.isNotEmpty) {
                  wrongNodes.add(currentLabel);
                }
                // 오답인 노드의 라벨 초기화
                ref.read(nodeLabelProvider.notifier).updateNodeLabel(nodeId, "");
              }
            });
            // 오답 단어들을 워드리스트에 추가
            final currentWordList = ref.read(wordListProvider);
            ref.read(wordListProvider.notifier).state = [
              ...currentWordList,
              ...wrongNodes
            ];
            // 수정 후 제출 상태를 초기화하여 재제출할 수 있도록 함
            ref.read(submissionStatusProvider.notifier).state = false;
            ref.read(submissionCompleteProvider.notifier).state = false;
          }
        },
        title: buttonTitle,
      ),
    )
        : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        width: double.infinity,
        decoration: ShapeDecoration(
          color: customColors.neutral100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: wordList
              .map((word) => Padding(
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
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildDraggableFeedback(String word, customColors, BuildContext context) {
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
