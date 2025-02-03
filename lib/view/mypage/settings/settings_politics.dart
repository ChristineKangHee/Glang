import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/custom_app_bar.dart';

class SettingsPolitics extends ConsumerWidget {
  const SettingsPolitics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '약관 및 정책'.tr(),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              '서비스 이용약관',
              style: body_medium_semi(context).copyWith(color: customColors.neutral0),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PolicyDetailScreen(title: '서비스 이용약관', content: termsOfService)),
              );
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          Divider(color: customColors.neutral80),
          ListTile(
            title: Text(
              '개인정보 처리방침',
              style: body_medium_semi(context).copyWith(color: customColors.neutral0),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PolicyDetailScreen(title: '개인정보 처리방침', content: privacyPolicy)),
              );
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          Divider(color: customColors.neutral80),
        ],
      ),
    );
  }
}

class PolicyDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const PolicyDetailScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: title.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            content,
            style: body_small(context),
          ),
        ),
      ),
    );
  }
}

const String termsOfService = '''
제1조 (목적)
본 약관은 글랑(이하 "서비스")의 이용과 관련하여 회사와 회원 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (용어 정의)
"회사"란 글랑 서비스를 운영하는 주체를 의미합니다.
"회원"이란 본 약관에 동의하고 서비스를 이용하는 개인을 의미합니다.
"콘텐츠"란 회원이 서비스 내에서 생성하는 노트, 질문, AI 추천 결과 등을 포함한 정보를 의미합니다.

제3조 (이용계약 체결)
회원은 본 약관에 동의함으로써 서비스 이용 계약을 체결합니다.
회사는 회원의 정보(이메일, 닉네임 등)를 등록받아 서비스를 제공합니다.

제4조 (서비스 제공 및 변경)
회사는 회원에게 독서 활동, AI 분석, 챗봇 기능, 학습 기록 관리 등의 서비스를 제공합니다.
회사는 서비스의 일부를 변경하거나 중단할 수 있으며, 중대한 변경 사항은 사전 공지합니다.

제5조 (회원의 의무)
회원은 타인의 권리를 침해하거나 법령을 위반하는 행위를 해서는 안 됩니다.
회원은 자신의 계정 정보를 안전하게 관리할 책임이 있습니다.

제6조 (서비스 이용 제한)
회사는 다음과 같은 경우 회원의 서비스 이용을 제한할 수 있습니다.
- 타인의 개인정보를 도용한 경우
- 불법적이거나 부적절한 콘텐츠를 생성한 경우
- 서비스 운영을 방해하는 행위를 한 경우

제7조 (면책 조항)
회사는 AI 추천 및 챗봇 응답의 정확성을 보장하지 않습니다.
서비스 장애 또는 데이터 손실에 대해 회사는 책임을 지지 않습니다.

제8조 (계정 탈퇴 및 데이터 삭제)
회원은 언제든지 계정을 삭제할 수 있습니다.
계정 삭제 시, 회원이 작성한 데이터는 복구할 수 없습니다.

제9조 (약관 개정)
회사는 약관을 변경할 수 있으며, 변경 사항은 사전 공지 후 효력이 발생합니다.
''';

const String privacyPolicy = '''
제1조 (개인정보 수집 항목)
- 필수 정보: 이메일, 닉네임, 학습 활동 데이터
- 선택 정보: 챗봇 대화 기록, 노트, AI 추천 정보

제2조 (개인정보 이용 목적)
- 서비스 제공 및 운영
- 학습 데이터 분석 및 맞춤형 추천
- 서비스 개선 및 오류 분석

제3조 (개인정보 보관 및 삭제)
- 회원이 계정을 삭제하면 관련 데이터는 즉시 삭제됩니다.
- 장기 미사용 계정은 일정 기간 후 자동 삭제될 수 있습니다.

제4조 (개인정보의 제3자 제공)
- 원칙적으로 회원 동의 없이 제3자에게 정보를 제공하지 않습니다.
- 서비스 운영을 위해 Firebase 등 외부 플랫폼을 이용할 수 있습니다.

제5조 (데이터 보안 조치)
- 회원 정보는 암호화하여 저장됩니다.
- 보안 강화를 위해 정기적인 점검을 수행합니다.

제6조 (이용자의 권리)
- 회원은 자신의 개인정보를 조회, 수정, 삭제할 수 있습니다.
- 개인정보 관련 문의는 고객센터를 통해 가능합니다.

제7조 (쿠키 및 트래킹 기술)
- 서비스 품질 향상을 위해 Firebase Analytics 등 트래킹 기술을 사용할 수 있습니다.

제8조 (문의처)
- 서비스 관련 문의는 다음 이메일을 통해 가능합니다: hgu.zero24@gmail.com
''';