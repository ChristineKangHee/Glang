import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';

import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../../viewmodel/custom_colors_provider.dart'; // Import custom colors
import '../../../components/custom_app_bar.dart'; // Adjust import as needed

// StateNotifier to manage the word list
final wordListProvider = StateNotifierProvider<WordListNotifier, List<String>>((ref) {
  return WordListNotifier(['apple', 'banana', 'cherry', 'date', 'elderberry']);
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
    return state[nodeId] ?? ""; // 초기 label을 빈 문자열로 설정
  }

  void clearNodeLabels() {
// 모든 노드의 label을 빈 문자열로 초기화
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

    // Add nodes to graph and connect them
    graph.addEdge(rootNode, child1);
    graph.addEdge(rootNode, child2);
    graph.addEdge(rootNode, child3);
    graph.addEdge(child1, grandChild1);
    graph.addEdge(child1, grandChild2);

    // Configure layout
    builder
      ..siblingSeparation = 50
      ..levelSeparation = 100
      ..subtreeSeparation = 75
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_2depth_6(
        title: '다이어그램',
      ),
      body: Padding( // Apply padding to the body
        padding: const EdgeInsets.symmetric(horizontal: 16), // Horizontal padding of 16
        child: Column(
          children: [
            // Rooted tree view
            Expanded(
              flex: 1,
              child: Center(
                child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(8),
                  minScale: 0.01,
                  maxScale: 5.0,
                  child: GraphView(
                    graph: graph,
                    algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                    paint: Paint()
                      ..color = customColors.neutral80!
                      ..strokeWidth = 1.5
                      ..style = PaintingStyle.stroke,
                    builder: (Node node) {
                      String nodeId = node.key!.value as String;
                      return nodeWidget(nodeId, ref); // Pass ref to the widget
                    },
                  ),
                ),
              ),
            ),
            // Word list widget directly below the tree
            WordListWidget(), // No Expanded here
          ],
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
          // Return the word to the word list if the node has a label
          ref.read(wordListProvider.notifier).state = [
            ...ref.read(wordListProvider),
            label
          ];

          // Clear the node label
          ref.read(nodeLabelProvider.notifier).updateNodeLabel(nodeId, "");
        }
      },
      child: DragTarget<String>(
        onAccept: (droppedWord) {
          // Update the node label and remove the word from the list
          ref.read(nodeLabelProvider.notifier).updateNodeLabel(nodeId, droppedWord);
          ref.read(wordListProvider.notifier).removeWord(droppedWord);
        },
        onWillAccept: (data) {
          // Prevent accepting the word if the node already has a label
          return label.isEmpty; // Allow if the node is empty
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            width: 100, // Fixed width
            height: 50, // Fixed height
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: candidateData.isNotEmpty ? Colors.green.shade100 : customColors.primary60,
            ),
            child: Text(label.isEmpty ? " " : label), // Display the label or empty space
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      width: double.infinity,
      decoration: ShapeDecoration(
        color: customColors.neutral100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Wrap(
        spacing: 8.0, // Horizontal space between items
        runSpacing: 8.0, // Vertical space between rows
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
