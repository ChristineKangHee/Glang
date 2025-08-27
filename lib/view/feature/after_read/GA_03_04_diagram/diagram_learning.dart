/// File: lib/view/feature/after_read/GA_03_04_diagram/diagram_learning.dart
/// Purpose: 사용자가 단어를 트리 구조의 노드에 드래그 앤 드롭하여 트리 구조를 완성하도록 설계되었습니다.
/// Author: 강희
/// Created: 2024-01-17
/// Last Modified: 2025-08-XX by ChatGPT (post-frame init + locale-safe + no-build-mutation)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../model/section_data.dart';
import '../../../../model/stage_data.dart';
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
import 'submission_notifier.dart';
import 'package:readventure/util/locale_text.dart';

/// ───────────────────────────── Helpers: locale-safe pickers ─────────────────────────────
String _pickLocaleString(BuildContext context, dynamic v, {String fallback = ''}) {
  if (v == null) return fallback;
  if (v is String) return v;
  if (v is Map) {
    final lang = context.locale.languageCode; // 'ko'/'en'...
    final val = v[lang] ?? v['ko'] ?? v['en'] ?? v.values.first;
    return val?.toString() ?? fallback;
  }
  try {
    final json = (v as dynamic).toJson();
    if (json is Map) return _pickLocaleString(context, json, fallback: fallback);
  } catch (_) {}
  return fallback;
}

List<String> _pickLocaleList(BuildContext context, dynamic v, {List<String> fallback = const []}) {
  if (v == null) return fallback;
  if (v is List) return v.map((e) => e.toString()).toList(growable: false);
  if (v is Map) {
    final lang = context.locale.languageCode;
    final sel = v[lang] ?? v['ko'] ?? v['en'] ?? v.values.first;
    if (sel is List) return sel.map((e) => e.toString()).toList(growable: false);
  }
  try {
    final json = (v as dynamic).toJson();
    return _pickLocaleList(context, json, fallback: fallback);
  } catch (_) {}
  return fallback;
}

Map<String, String> _pickLocaleStringMap(BuildContext context, Map raw) {
  final out = <String, String>{};
  raw.forEach((k, v) => out['$k'] = _pickLocaleString(context, v, fallback: ''));
  return out;
}

/// 트리 데이터에서 id(로컬라이즈드/복합 가능)를 문자열로 **정규화**해줌
Map<String, dynamic> _normalizeTree(BuildContext context, Map raw) {
  final idStr = _pickLocaleString(context, raw['id'], fallback: '');
  final children = (raw['children'] as List?)
      ?.whereType<Map>()
      .map((m) => _normalizeTree(context, m))
      .toList() ??
      const <Map<String, dynamic>>[];
  return {'id': idStr, 'children': children};
}

/// ───────────────────────────── Providers ─────────────────────────────
/// 제출 상태/완료 상태
final submissionStatusProvider = StateProvider<bool>((ref) => false);
final submissionCompleteProvider = StateProvider<bool>((ref) => false);

/// 안내 다이얼로그 1회 표시 여부
// final dialogShownProvider = StateProvider.autoDispose<bool>((ref) => false);

/// 단어 리스트(워드뱅크)
final wordListProvider =
StateNotifierProvider<WordListNotifier, List<String>>((ref) => WordListNotifier(const []));

class WordListNotifier extends StateNotifier<List<String>> {
  WordListNotifier(List<String> initial) : super(initial);
  void removeWord(String word) => state = state.where((w) => w != word).toList(growable: false);
  void resetWords() => state = const [];
  void setIfEmpty(List<String> words) {
    if (state.isEmpty) state = List.unmodifiable(words);
  }
}

/// 노드 라벨 맵
final nodeLabelProvider =
StateNotifierProvider<NodeLabelNotifier, Map<String, String>>((ref) => NodeLabelNotifier());

class NodeLabelNotifier extends StateNotifier<Map<String, String>> {
  NodeLabelNotifier() : super(const {});
  void updateNodeLabel(String nodeId, String label) => state = {...state, nodeId: label};
  String getNodeLabel(String nodeId) => state[nodeId] ?? "";
  void clearNodeLabels() => state = state.map((k, v) => MapEntry(k, ""));
}

/// ───────────────────────────── Screen ─────────────────────────────
class RootedTreeScreen extends ConsumerStatefulWidget {
  const RootedTreeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RootedTreeScreen> createState() => _RootedTreeScreenState();
}

class _RootedTreeScreenState extends ConsumerState<RootedTreeScreen> {
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  final _appBarKey = GlobalKey<CustomAppBar_2depth_8State>();

  late final ProviderSubscription<StageData?> _stageSub;
  late final ProviderSubscription<SubmissionStatus> _submitSub;
  bool _didSeedOnce = false;

  bool _dialogShownOnce = false; // ⬅️ 추가 (팝업 1회 표시 플래그)

  @override
  void initState() {
    super.initState();

    // currentStageProvider 변화 감지 (initState에서 listenManual 사용, fireImmediately 제거)
    _stageSub = ref.listenManual<StageData?>(
      currentStageProvider,
          (prev, next) {
        if (next != null) _seedFromStage(next); // 내부에서 post-frame으로 시드
      },
      // fireImmediately: true  ← 사용하지 않음 (컨텍스트 의존 접근을 피하기 위해)
    );

    // 제출 상태 변화 감지
    _submitSub = ref.listenManual<SubmissionStatus>(
      submissionNotifierProvider,
          (prev, next) async {
        if (next != SubmissionStatus.success) return;
        final elapsedSeconds = _appBarKey.currentState?.elapsedSeconds ?? 0;
        final userId = ref.read(userIdProvider);
        if (userId != null) {
          await ref.read(userServiceProvider).updateLearningTime(elapsedSeconds);
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LearningActivitiesPage()),
        );
      },
    );
  }

  /// 최초 1회 시드는 didChangeDependencies에서 (EasyLocalization 의존 안전)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ── 팝업 1회 ──
    if (!_dialogShownOnce) {
      _dialogShownOnce = true; // 먼저 막아 중복 방지
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => const DiagramMainDialog(),
        );
      });
    }

    // ── ★★★ 최초 1회 워드리스트 시드 ★★★ ──
    if (!_didSeedOnce) {
      _didSeedOnce = true;
      final stageNow = ref.read(currentStageProvider); // 현재 값 직접 읽기
      if (stageNow != null) {
        _seedFromStage(stageNow); // 내부에서 post-frame + locale-safe
      }
    }
  }


  /// 구독 해제
  @override
  void dispose() {
    _stageSub.close();
    _submitSub.close();
    super.dispose();
  }

  /// 빌드 중 프로바이더 변경 금지: 항상 포스트-프레임에서 시드 + 여기서 locale 접근
  void _seedFromStage(StageData stage) {
    final diag = stage.arData?.featureData?['feature4Diagram'] as Map<String, dynamic>?;
    if (diag == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final wordsInit = _pickLocaleList(context, diag['wordList']); // 여기서 locale 참조
      if (wordsInit.isNotEmpty) {
        ref.read(wordListProvider.notifier).setIfEmpty(wordsInit);
      }
    });
  }

  /// 그래프 빌더 (정규화된 트리 사용)
  void _buildTree(Graph graph, Map<String, dynamic> data, Node? parentNode) {
    final Node currentNode = Node.Id(data['id'] as String);
    if (parentNode != null) graph.addEdge(parentNode, currentNode);
    final children = (data['children'] as List).cast<Map<String, dynamic>>();
    for (final child in children) {
      _buildTree(graph, child, currentNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stage = ref.watch(currentStageProvider);
    final customColors = ref.watch(customColorsProvider);

    if (stage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final diagramData = stage.arData?.featureData?['feature4Diagram'] as Map<String, dynamic>?;
    if (diagramData == null) {
      return Scaffold(body: Center(child: Text("diagram_no_data").tr()));
    }

    // 안내 다이얼로그 1회 표시 (post-frame에서 state set)
    // if (!ref.read(dialogShownProvider)) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (!mounted) return;
    //     showDialog(
    //       context: context,
    //       builder: (_) => const DiagramMainDialog(),
    //     );
    //     ref.read(dialogShownProvider.notifier).state = true;
    //   });
    // }

    // ── 다국어 대응 필드 파싱 ──
    final diagramTitle = _pickLocaleString(context, diagramData['title'], fallback: "다이어그램");
    final diagramSubtitle = _pickLocaleString(context, diagramData['subtitle'], fallback: "");
    final correctAnswersRaw = (diagramData['correctAnswers'] as Map?) ?? const {};
    final correctAnswersMap = _pickLocaleStringMap(context, correctAnswersRaw as Map);

    // ── 트리 구조 정규화 ──
    final treeStructure =
        (diagramData['treeStructure'] as List?)?.whereType<Map>().toList() ?? const [];
    final graph = Graph();
    if (treeStructure.isNotEmpty) {
      final normalizedRoot = _normalizeTree(context, treeStructure.first);
      _buildTree(graph, normalizedRoot, null);
    }

    // 레이아웃 설정
    builder
      ..siblingSeparation = 30
      ..levelSeparation = 70
      ..subtreeSeparation = 50
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_2depth_8(title: 'diagram_title'.tr(), key: _appBarKey),
      body: Column(
        children: [
          // 상단 설명
          Container(
            decoration: ShapeDecoration(
              color: customColors.neutral100,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TitleSection_withIcon(
                customColors: Theme.of(context).extension<CustomColors>()!,
                title: diagramTitle, // ⚠️ 이미 로컬라이즈된 문자열. 위젯 내부에서 .tr() 하지 마세요.
                subtitle: diagramSubtitle, // ⚠️ 동일
                author: "author_none".tr(),
                stageId: stage.stageId,
                subdetailTitle: lx(context, stage.subdetailTitle),
              ),
            ),
          ),

          // 트리 뷰
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final nodeCount = graph.nodeCount().clamp(1, 999);
                    builder
                      ..siblingSeparation =
                      (constraints.maxWidth / (nodeCount * 1.5)).clamp(20, 100).toInt()
                      ..levelSeparation =
                      (constraints.maxHeight / (nodeCount * 2.5)).clamp(50, 200).toInt();

                    return InteractiveViewer(
                      constrained: false,
                      child: GraphView(
                        graph: graph,
                        algorithm:
                        BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                        paint: Paint()
                          ..color = customColors.neutral80!
                          ..strokeWidth = 1.5
                          ..style = PaintingStyle.stroke,
                        builder: (Node node) {
                          final nodeId = node.key!.value as String; // 정상적으로 String
                          return _nodeWidget(nodeId, ref, correctAnswersMap);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 단어 리스트 / 제출 버튼
          WordListWidget(correctAnswersMap: correctAnswersMap),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 노드 위젯
  Widget _nodeWidget(String nodeId, WidgetRef ref, Map<String, String> correctAnswersMap) {
    final label = ref.watch(nodeLabelProvider.select((m) => m[nodeId] ?? ""));
    final customColors = ref.watch(customColorsProvider);
    final submitted = ref.watch(submissionStatusProvider);

    // 색상
    Color? nodeColor;
    if (submitted) {
      final correct = correctAnswersMap[nodeId] ?? "";
      nodeColor = (label == correct) ? customColors.success40 : customColors.error40;
    } else {
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
      }
    }

    return GestureDetector(
      onTap: () {
        if (label.isEmpty) return;
        // 라벨 회수 → 워드리스트로 복원
        final list = ref.read(wordListProvider);
        ref.read(wordListProvider.notifier).state = [...list, label];
        // 노드 라벨 초기화 + 제출상태 초기화
        ref.read(nodeLabelProvider.notifier).updateNodeLabel(nodeId, "");
        ref.read(submissionStatusProvider.notifier).state = false;
        ref.read(submissionCompleteProvider.notifier).state = false;
      },
      child: DragTarget<String>(
        onWillAccept: (_) => label.isEmpty,
        onAccept: (word) {
          ref.read(nodeLabelProvider.notifier).updateNodeLabel(nodeId, word);
          ref.read(wordListProvider.notifier).removeWord(word);
        },
        builder: (_, candidate, __) {
          return Container(
            width: 80,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: candidate.isNotEmpty ? customColors.success40 : nodeColor,
            ),
            child: Text(
              label.isEmpty ? " " : label,
              style: body_small_semi(_).copyWith(fontSize: 12, color: customColors.neutral100),
            ),
          );
        },
      ),
    );
  }
}

/// ───────────────────────────── Word bank & Submit ─────────────────────────────
class WordListWidget extends ConsumerStatefulWidget {
  final Map<String, String> correctAnswersMap;
  const WordListWidget({Key? key, required this.correctAnswersMap}) : super(key: key);

  @override
  ConsumerState<WordListWidget> createState() => _WordListWidgetState();
}

class _WordListWidgetState extends ConsumerState<WordListWidget> {
  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    final wordList = ref.watch(wordListProvider);
    final submitted = ref.watch(submissionStatusProvider);
    final complete = ref.watch(submissionCompleteProvider);

    final buttonTitle = submitted
        ? (complete ? 'submit_complete'.tr() : 'edit_submission'.tr())
        : 'submit'.tr();

    // 모든 단어 배치 완료 → 제출/수정 버튼
    if (wordList.isEmpty) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ButtonPrimary(
          function: () async {
            await ref
                .read(submissionNotifierProvider.notifier)
                .submitFeature(widget.correctAnswersMap);
          },
          title: buttonTitle,
        ),
      );
    }

    // 남은 단어들 draggable
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(word, style: body_small(context)),
    );
  }
}
