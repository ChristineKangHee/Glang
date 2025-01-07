import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';

class NicknameInput extends ConsumerStatefulWidget {
  const NicknameInput({super.key});

  @override
  ConsumerState<NicknameInput> createState() => _NicknameInputState();
}

class _NicknameInputState extends ConsumerState<NicknameInput> {
  // Controller to manage TextField input
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar_Logo(),
        resizeToAvoidBottomInset: false,  // Disable resizing of the body when keyboard shows
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(  // Allow scrolling if content is larger than screen
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '별명을 입력해주세요',
                        style: heading_medium(context),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '별명',
                        style: body_xsmall(context).copyWith(color: customColors.primary),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controller,  // Attach the controller to the TextField
                        style: body_large_semi(context),  // Set the text style for the input text
                        cursorColor: customColors.primary ?? Colors.purple,  // Set cursor color
                        cursorWidth: 2,  // Customize cursor width
                        cursorRadius: Radius.circular(5),  // Customize cursor radius (rounded edges)
                        decoration: InputDecoration(
                          hintText: '별명을 입력하세요',
                          hintStyle: body_large_semi(context).copyWith(color: customColors.neutral60),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: customColors.primary ?? Colors.purple, width: 2),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: customColors.neutral60 ?? Colors.grey, width: 2),
                          ),
                          // Add delete icon when text is not empty
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.cancel_rounded, color: customColors.neutral60 ?? Colors.purple),
                            onPressed: () {
                              _controller.clear();  // Clear the text when the delete icon is clicked
                              setState(() {
                                // Trigger rebuild to hide the delete icon after clearing text
                              });
                            },
                          )
                              : null,
                        ),
                        onChanged: (text) {
                          setState(() {
                            // Trigger rebuild to show/hide the delete icon based on the text input
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Button Container - Fixed at the bottom
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20),
              child: ButtonPrimary(
                function: () {
                  print("완료");
                  // function 은 상황에 맞게 재 정의 할 것.
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
