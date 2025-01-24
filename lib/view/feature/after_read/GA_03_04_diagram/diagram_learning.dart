/// File: diagram_learning.dart
/// Purpose: 사용자가 단어를 트리 구조의 노드에 드래그 앤 드롭하여 트리 구조를 완성하도록 설계되었습니다.
/// Author: 강희
/// Created: 2024-1-17
/// Last Modified: 2024-1-25 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';

import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_button.dart';
import '../widget/title_section_learning.dart';

// 단어 리스트를 관리하기 위한 StateNotifierProvider 정의
final wordListProvider = StateNotifierProvider<WordListNotifier, List<String>>((ref) {
  return WordListNotifier([
    '읽기 시스템', '문제점', '교육 시스템', '피드백 부족', '해결방안',
    '맞춤형 읽기 도구', '실시간 피드백', '기대효과', '읽기 능력 향상', '자기주도 학습 강화'
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

// 노드 라벨을 관리하기 위한 StateNotifierProvider 정의
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

// 트리 다이어그램 화면
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider); // 사용자 정의 색상 가져오기

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_2depth_8(
        title: '다이어그램', // 화면 제목
      ),
      body: Column(
        children: [
          // 제목 섹션
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
          // 트리 다이어그램
          RootedTree(customColors, ref, context),
          // 단어 리스트 위젯
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
            boundaryMargin: const EdgeInsets.all(4),
            minScale: 0.1,
            maxScale: 3.0,
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
  // 노드 위젯 생성
  Widget nodeWidget(String nodeId, WidgetRef ref) {
    String label = ref.watch(nodeLabelProvider.select((map) => map[nodeId] ?? ""));
    final customColors = ref.watch(customColorsProvider);

    // 노드 색상 설정
    Color nodeColor;
    switch (nodeId) {
      case 'Root':
        nodeColor = Colors.redAccent;
        break;
      case 'Child 1':
      case 'Child 2':
      case 'Child 3':
        nodeColor = Colors.blueAccent;
        break;
      default:
        nodeColor = Colors.greenAccent;
        break;
    }

    return GestureDetector(
      onTap: () {
        if (label.isNotEmpty) {
          ref.read(wordListProvider.notifier).state = [
            ...ref.read(wordListProvider),
            label
          ];
          ref.read(nodeLabelProvider.notifier).updateNodeLabel(nodeId, "");
        }
      },
      child: DragTarget<String>(
        onAccept: (droppedWord) {
          ref.read(nodeLabelProvider.notifier).updateNodeLabel(nodeId, droppedWord);
          ref.read(wordListProvider.notifier).removeWord(droppedWord);
        },
        onWillAccept: (data) {
          return label.isEmpty;
        },
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
              style: body_small_semi(context).copyWith(fontSize: 12, color: customColors.neutral100),
            ),
          );
        },
      ),
    );
  }
}

// 단어 리스트 위젯 정의
class WordListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final wordList = ref.watch(wordListProvider);

    return wordList.isEmpty
        ? Container(
      width: MediaQuery.of(context).size.width,
      child: ButtonPrimary(
        function: () {
          print("제출하기");
          Navigator.popUntil(
            context,
                (route) => route.settings.name == 'LearningActivitiesPage',
          );
        },
        title: '제출하기',
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
