import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodel/custom_colors_provider.dart';
import '../components/custom_button.dart';

class InterestSelectionPage extends ConsumerStatefulWidget {
  @override
  _InterestSelectionPageState createState() => _InterestSelectionPageState();
}

class _InterestSelectionPageState extends ConsumerState<InterestSelectionPage> {
  final List<String> categories = ['소설', '에세이', '인문학', '사회과학', '역사/문화', '경제/경영','자기계발','과학/기술','예술/문화'];
  final Set<String> selectedCategories = {};

  void toggleSelection(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        if (selectedCategories.length < 3) {
          selectedCategories.add(category);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    final bool maxSelected = selectedCategories.length == 3;
    final bool hasSelection = selectedCategories.isNotEmpty;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Text(
              '어떤 글을 좋아하세요?',
              style: heading_large(context),
            ),
            SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '관심있는 카테고리를 최대 ', style: body_small(context)),
                  TextSpan(
                    text: '3가지',
                    style: body_small_semi(context).copyWith(color: customColors.primary),
                  ),
                  TextSpan(text: ' 선택해주세요', style: body_small(context)),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  String category = categories[index];
                  bool isSelected = selectedCategories.contains(category);
                  bool shouldBeNeutral80 = maxSelected && !isSelected;
                  return GestureDetector(
                    onTap: () => toggleSelection(category),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? customColors.primary10
                            : shouldBeNeutral80
                            ? customColors.neutral80
                            : customColors.neutral90,
                        border: Border.all(
                          color: isSelected ? customColors.primary! : Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: isSelected ? customColors.primary : customColors.neutral60,
                          ),
                          SizedBox(height: 4),
                          Text(
                            category,
                            style: body_small_semi(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: hasSelection
                  ? ButtonPrimary_noPadding(
                function: () {
                  print("완료");
                },
                title: '완료',
              )
                  : ButtonPrimary20_noPadding(
                function: () {
                  print("완료");
                },
                title: '완료',
              ),
            ),
          ],
        ),
      ),
    );
  }
}