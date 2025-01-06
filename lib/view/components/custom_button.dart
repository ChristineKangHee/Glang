/// File: custom_button.dart
/// Purpose: 앱에서 커스터마이즈된 버튼 위젯을 제공하여 타이틀, 검색 버튼 등을 설정 가능하게 함
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2024-12-31 by 박민준

import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';

import '../../util/box_shadow_styles.dart';

/*
    사용 방법

    // 혹시 폰트나, 색상 변경 필요하면 박민준 문의 바람

    1. 앱 기본 사용 버튼 (앱 Primary 컬러)
    Container(
      width: MediaQuery.of(context).size.width,
      child: Button(
        function: () {
          print("Button pressed");
          //function 은 상황에 맞게 재 정의 할 것.
        },
        title: 'Custom Button',
        // 버튼 안에 들어갈 텍스트.
      ),
    ),

    2. Primary20 Color 버튼
    Container(
      width: MediaQuery.of(context).size.width,
      child: ButtonPrimary20(
        function: () {
          print("Button pressed");
          //function 은 상황에 맞게 재 정의 할 것.
        },
        title: 'Custom Button',
        // 버튼 안에 들어갈 텍스트.
      ),
    ),
    ------------------------- 이전 버전 코드 -------------------------
    3. 아이콘 있는 버튼
    Container(
      width: MediaQuery.of(context).size.width,
      child: ButtonNatural(
        function: () {
          print("Button pressed");
          //function 은 상황에 맞게 재 정의 할 것.
        },
        title: 'Custom Button',
        // 버튼 안에 들어갈 텍스트.
        icon: Icons.apple,
      ),
    ),

    4. 이미지 있는 버튼
    Container(
      width: MediaQuery.of(context).size.width,
      child: ButtonImage(
        function: () {
          print("Button pressed");
          //function 은 상황에 맞게 재 정의 할 것.
        },
        title: '애플로 로그인하기',
        // 버튼 안에 들어갈 텍스트.
        image: 'assets/images/apple.png',
      ),
    ),

 */

class ButtonPrimary extends StatelessWidget { //
  const ButtonPrimary( //파라미터
          {Key? key,
        required this.function,
        required this.title,
        this.condition = "not null",
        })
      : super(key: key);

  final String title;
  final Function function;
  final String condition;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return GestureDetector(
      onTap: condition.contains("not null")
          ? () {
        function();
      }
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), // 좌 우 패딩
        child: Container(
          width: MediaQuery.of(context).size.width, //MediaQuery 를 통해서 버튼 넓이 설정해놓음.
          height: 56, // 버튼 높이
          decoration: BoxDecoration(
            color: condition.contains("not null") ? Theme.of(context).colorScheme.primary : Colors.grey,
            borderRadius: BorderRadius.circular(16),
            boxShadow: BoxShadowStyles.shadow1(context),
          ), // Button Edge 둥글게
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: body_medium_semi(context).copyWith(color: customColors.neutral100) // SemiBold에 색상 흰색으로 설정. 설정 관련은 font.dart
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonPrimary20 extends StatelessWidget { //
  const ButtonPrimary20( //파라미터
          {Key? key,
        required this.function,
        required this.title,
        this.condition = "not null",
      })
      : super(key: key);

  final String title;
  final Function function;
  final String condition;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return GestureDetector(
      onTap: condition.contains("not null")
          ? () {
        function();
      }
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), // 좌 우 패딩
        child: Container(
          width: MediaQuery.of(context).size.width, //MediaQuery 를 통해서 버튼 넓이 설정해놓음.
          height: 56, // 버튼 높이
          decoration: BoxDecoration(
            color: condition.contains("not null") ? Theme.of(context).colorScheme.primary : Colors.grey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: body_medium_semi(context).copyWith(color: customColors.neutral100) // SemiBold에 색상 흰색으로 설정. 설정 관련은 font.dart
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonIcon extends StatelessWidget { //
  const ButtonIcon( //파라미터
          {Key? key,
        required this.function,
        required this.title,
        required this.icon,
        this.condition = "not null",
      })
      : super(key: key);

  final String title;
  final Function function;
  final String condition;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: condition.contains("not null")
          ? () {
        function();
      }
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16,0,16,0),
        child: Container(
          width: MediaQuery.of(context).size.width, //MediaQuery 를 통해서 버튼 넓이 설정해놓음.
          height: 52,
          decoration: BoxDecoration(
              color: condition.contains("not null") ? Theme.of(context).colorScheme.surface : Colors.grey,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline
              )
          ), // Button Edge 둥글게
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                Text(
                    title,
                    textAlign: TextAlign.center,
                    style: pretendardRegular(context) // Text Regular로 설정. 설정 관련은 font.dart
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonImage extends StatelessWidget {
  //
  const ButtonImage( //파라미터
          {Key? key,
        required this.function,
        required this.title,
        required this.image,
        this.condition = "not null",
      })
      : super(key: key);

  final String title;
  final Function function;
  final String condition;
  final String image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: condition.contains("not null")
          ? () {
        function();
      }
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16,0,16,0),
        child: Container(
          width: MediaQuery.of(context).size.width, //MediaQuery 를 통해서 버튼 넓이 설정해놓음.
          height: 52,
          decoration: BoxDecoration(
              color: condition.contains("not null") ? Theme.of(context).colorScheme.surface : Colors.grey,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
          ), // Button Edge 둥글게
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: 30,
                    child: Image.asset(image)
                ),
                SizedBox(width: 15),
                Text(
                    title,
                    textAlign: TextAlign.center,
                    style: pretendardRegular(context) // Text Regular로 설정. 설정 관련은 font.dart
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}