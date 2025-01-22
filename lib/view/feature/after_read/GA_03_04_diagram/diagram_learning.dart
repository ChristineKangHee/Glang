import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';

import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_button.dart';
import '../widget/title_section_learning.dart';

// StateNotifier to manage the word list
final wordListProvider = StateNotifierProvider<WordListNotifier, List<String>>((ref) {
  return WordListNotifier(['읽기 시스템', '문제점', '교육 시스템', '피드백 부족', '해결방안', '맞춤형 읽기 도구', '실시간 피드백', '기대효과', '읽기 능력 향상', '자기주도 학습 강화']);
});

class WordListNotifier extends StateNotifier<List<String>> {
  WordListNotifier(List<String> initialWords) : super(initialWords);

  void removeWord(String word) {
    state = state.where((w) => w != word).toList();
  }
}

final nodeLabelProvider = StateNotifierProvider<NodeLabelNotifier, Map<String, String>>((ref) {
  return NodeLabelNotifier();
});

class NodeLabelNotifier extends StateNotifier<Map<String, String>> {
  NodeLabelNotifier() : super({});

  void updateNodeLabel(String nodeId, String label) {
    state = {
      ...state,
      nodeId: label,
    };
  }

  String getNodeLabel(String nodeId) {
    return state[nodeId] ?? "";
  }

  void clearNodeLabels() {
    state = state.map((key, value) => MapEntry(key, ""));
  }
}

class RootedTreeScreen extends ConsumerWidget {
  final Graph graph = Graph();
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  RootedTreeScreen({Key? key}) : super(key: key) {
    // Create nodes
    final Node rootNode = Node.Id('Root');
    final Node child1 = Node.Id('Child 1');
    final Node child2 = Node.Id('Child 2');
    final Node child3 = Node.Id('Child 3');
    final Node grandChild1 = Node.Id('Grandchild 1');
    final Node grandChild2 = Node.Id('Grandchild 2');
    final Node grandChild3 = Node.Id('Grandchild 3');
    final Node grandChild4 = Node.Id('Grandchild 4');
    final Node grandChild5 = Node.Id('Grandchild 5');
    final Node grandChild6 = Node.Id('Grandchild 6');

    // Add nodes to graph and connect them
    graph.addEdge(rootNode, child1);
    graph.addEdge(rootNode, child2);
    graph.addEdge(rootNode, child3);
    graph.addEdge(child1, grandChild1);
    graph.addEdge(child1, grandChild2);
    graph.addEdge(child2, grandChild3);
    graph.addEdge(child2, grandChild4);
    graph.addEdge(child3, grandChild5);
    graph.addEdge(child3, grandChild6);

    // Configure layout with optimized spacing
    builder
      ..siblingSeparation = 30
      ..levelSeparation = 70
      ..subtreeSeparation = 50
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

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

  Widget RootedTree(CustomColors customColors, WidgetRef ref, BuildContext context) {
    final nodeCount = graph.nodeCount();
    final size = MediaQuery.of(context).size;

    builder
      ..siblingSeparation = (size.width / (nodeCount * 1.5)).clamp(20, 100).toInt()
      ..levelSeparation = (size.height / (nodeCount * 2.5)).clamp(50, 200).toInt();

    return Expanded(
      flex: 1,
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
    );
  }

  Widget nodeWidget(String nodeId, WidgetRef ref) {
    String label = ref.watch(nodeLabelProvider.select((map) => map[nodeId] ?? ""));
    final customColors = ref.watch(customColorsProvider);

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
              color: candidateData.isNotEmpty ? customColors.success40 : customColors.primary60,
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
