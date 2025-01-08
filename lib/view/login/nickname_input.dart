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
  final TextEditingController _controller = TextEditingController();
  String? errorMessage; // To store the error message
  final List<String> existingNicknames = ['user1', 'user2', 'admin']; // Example existing nicknames

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final hasError = errorMessage != null;
    final isInputNotEmpty = _controller.text.isNotEmpty;

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar_Logo(),
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
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
                        controller: _controller,
                        style: body_large_semi(context),
                        cursorColor: customColors.primary ?? Colors.purple,
                        cursorWidth: 2,
                        cursorRadius: Radius.circular(5),
                        decoration: InputDecoration(
                          hintText: '별명을 입력하세요',
                          hintStyle: body_large_semi(context).copyWith(color: customColors.neutral60),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: hasError
                                    ? customColors.error ?? Colors.red
                                    : customColors.primary ?? Colors.purple,
                                width: 2),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: hasError
                                    ? customColors.error ?? Colors.red
                                    : customColors.neutral60 ?? Colors.grey,
                                width: 2),
                          ),
                          suffixIcon: isInputNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.cancel_rounded, color: customColors.neutral60 ?? Colors.purple),
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                errorMessage = null; // Clear the error message
                              });
                            },
                          )
                              : null,
                        ),
                        onChanged: (text) {
                          setState(() {
                            if (existingNicknames.contains(text)) {
                              errorMessage = '이미 사용 중인 닉네임이에요';
                            } else {
                              errorMessage = null;
                            }
                          });
                        },
                      ),
                      if (hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            errorMessage!,
                            style: body_xsmall(context).copyWith(color: customColors.error),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20),
              child: hasError || !isInputNotEmpty
                  ? ButtonPrimary20(
                function: () {
                  print("완료");
                },
                title: '완료',
              )
                  : ButtonPrimary(
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
