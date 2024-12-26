import 'package:flutter/material.dart';

// Text(
//   '예제 텍스트',
//   style: pretendardBlack(context).copyWith(fontSize: 20), // 폰트 크기만 20으로 변경
// )

//////////////////////////////////////////////////////////////////////
///////                      기본 폰트들                          ///////
//////////////////////////////////////////////////////////////////////

TextStyle pretendardBlack(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w900,
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface, // Light: 검 Dark: 흰
    );
}

TextStyle pretendardExtraBold(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w800,
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface, // Light: 검 Dark: 흰
    );
}

TextStyle pretendardBold(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface, // Light: 검 Dark: 흰
    );
}

TextStyle pretendardSemiBold(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface, // Light: 검 Dark: 흰
    );
}

TextStyle pretendardMedium(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface, // Light: 검 Dark: 흰
    );
}

TextStyle pretendardRegular(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface, // Light: 검 Dark: 흰
    );
}

TextStyle pretendardLight(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w300,
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface, // Light: 검 Dark: 흰
    );
}

TextStyle pretendardExtraLight(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w200,
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface, // Light: 검 Dark: 흰
    );
}

TextStyle pretendardThin(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w100,
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface, // Light: 검 Dark: 흰
    );
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////      폰트 색, 사이즈 등 개별 사용   //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

TextStyle pretendardBoldPrimary(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w700,
        fontSize: 36,
        color: Theme.of(context).colorScheme.primary, // Light: 검 Dark: 흰
    );
}

TextStyle pretendardLightLast(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w300,
        fontSize: 16,
        color: Theme.of(context).colorScheme.shadow, // Light: 검 Dark: 흰
    );
}

TextStyle pretendardSemiBoldPrimary(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Theme.of(context).colorScheme.primary, // Light: 흰 Dark: 검
    );
}

TextStyle pretendardSemiBoldSecond(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Theme.of(context).colorScheme.secondary, // Light: 흰 Dark: 검
    );
}

TextStyle pretendardRegularSecond(BuildContext context) {
    return TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: Theme.of(context).colorScheme.secondary, // Light: 검 Dark: 흰
    );
}