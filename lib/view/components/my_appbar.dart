import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Function()? onSearchPressed; //action 함수를 호출하는 곳에서 설정할 수 있도록 함

  const CustomAppBar({
    Key? key,
    required this.title,
    this.backgroundColor = Colors.white, // 기본값을 흰색으로 설정
    this.onSearchPressed,
  }) : super(key: key);
  /*
    사용 방법
    Scaffold 에서 아래와 같이 사용

    appBar: CustomAppBar(
      title: '매장 목록',
      onSearchPressed: () {
        print("검색");
      },
    ),

   */



  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.orange),
        onPressed: () {
          // Navigator.pop(context); //뒷 페이지로 돌아가는 기능. 상황에 맞게 수정.
        },
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [// 이 부분에 아이콘 버튼을 추가
        IconButton(
          icon: Icon(Icons.search, color: Colors.orange),
          onPressed: onSearchPressed,
        ),
      ],
      backgroundColor: backgroundColor,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}