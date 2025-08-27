// lib/model/badge_data.dart
// Purpose: Badge 모델 + L10N 타입 + 텍스트 선택 유틸 + 시드/마이그레이션 유틸(옵션)
// Author: 민준팀
// Last Modified: 2025-08-26

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:easy_localization/easy_localization.dart';

/// ─────────────────────────────────────────────────────────────────
/// L10N 타입: 문자열을 ko/en 이중언어로 관리 (레거시 호환)
/// - fromJson(dynamic): String 또는 Map<String,dynamic> 모두 안전 처리
/// - toJson(): Firestore 저장용 Map
/// - pick(BuildContext): 현재 로케일에 맞는 문자열 선택
/// ─────────────────────────────────────────────────────────────────
class LocalizedText {
  final String ko;
  final String en;
  const LocalizedText({this.ko = '', this.en = ''});

  factory LocalizedText.fromJson(dynamic j) {
    if (j == null) return const LocalizedText();
    if (j is String) {
      // 레거시: 단일 문자열이면 ko로 승격
      return LocalizedText(ko: j, en: '');
    }
    if (j is Map<String, dynamic>) {
      return LocalizedText(
        ko: (j['ko'] ?? '').toString(),
        en: (j['en'] ?? '').toString(),
      );
    }
    return const LocalizedText();
  }

  Map<String, dynamic> toJson() => {'ko': ko, 'en': en};

  /// 현재 로케일에 맞춰 ko/en 중 하나를 리턴 (둘 다 비어있으면 fallback)
  String pick(BuildContext context, {String fallback = ''}) {
    final lang = context.locale.languageCode.toLowerCase();
    if (lang == 'ko') return ko.isNotEmpty ? ko : (en.isNotEmpty ? en : fallback);
    return en.isNotEmpty ? en : (ko.isNotEmpty ? ko : fallback);
  }
}

/// ─────────────────────────────────────────────────────────────────
/// AppBadge 모델 (이중언어 필드 적용)
/// - name/description/howToEarn: LocalizedText
/// - imageUrl: asset 또는 network 모두 가능(표시는 위젯에서 결정)
/// - fromFirestore: id 필드 없으면 doc.id 사용, 레거시 문자열도 수용
/// ─────────────────────────────────────────────────────────────────
class AppBadge {
  final String id;
  final LocalizedText name;
  final LocalizedText description;
  final LocalizedText howToEarn;
  final String? imageUrl;

  AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.howToEarn,
    this.imageUrl,
  });

  factory AppBadge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final id = (data['id'] as String?) ?? doc.id;

    return AppBadge(
      id: id,
      name: LocalizedText.fromJson(data['name']),
      description: LocalizedText.fromJson(data['description']),
      howToEarn: LocalizedText.fromJson(data['howToEarn']),
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name.toJson(),
    'description': description.toJson(),
    'howToEarn': howToEarn.toJson(),
    if (imageUrl != null) 'imageUrl': imageUrl,
  };
}

/// ─────────────────────────────────────────────────────────────────
/// (옵션) 기존 단일 문자열 문서를 L10N 스키마로 올려주는 마이그레이션
/// - 문자열이면 ko로 승격, en은 빈 문자열로 유지
/// - id 필드가 비어있으면 doc.id로 채움
/// ─────────────────────────────────────────────────────────────────
Future<void> migrateBadgesToL10n() async {
  final col = FirebaseFirestore.instance.collection('badges');
  final snap = await col.get();
  for (final d in snap.docs) {
    final data = d.data();
    final upd = <String, dynamic>{};

    for (final key in ['name', 'description', 'howToEarn']) {
      final v = data[key];
      if (v is String) {
        upd[key] = {'ko': v, 'en': ''};
      }
    }
    if ((data['id'] as String?) == null || (data['id'] as String?)!.isEmpty) {
      upd['id'] = d.id;
    }
    if (upd.isNotEmpty) {
      await d.reference.update(upd);
    }
  }
}

/// ─────────────────────────────────────────────────────────────────
/// (옵션) L10N 형태로 뱃지 시드 넣기
/// - 문서 ID를 id와 동일하게 고정 (set with merge)
/// ─────────────────────────────────────────────────────────────────
Future<void> addBadgesToFirebaseL10N() async {
  final col = FirebaseFirestore.instance.collection('badges');

  final List<Map<String, dynamic>> badges = [
    {
      'id': 'first_step',
      'name': {'ko': '첫걸음', 'en': 'First Step'},
      'description': {
        'ko': '글랑에 오신 걸 환영합니다! 첫 발걸음을 내디뎠어요.',
        'en': 'Welcome to GLANG! You’ve taken your first step.'
      },
      'howToEarn': {'ko': '첫출석', 'en': 'First attendance'},
      'imageUrl': 'assets/images/first_badge.png',
    },
    {
      'id': 'three_day_streak',
      'name': {'ko': '3일 연속 출석', 'en': '3-Day Streak'},
      'description': {
        'ko': '꾸준한 학습 습관이 시작되었어요!',
        'en': 'A steady learning habit has begun!'
      },
      'howToEarn': {'ko': '3일 연속 출석하기', 'en': 'Attend 3 days in a row'},
    },
    {
      'id': 'seven_day_streak',
      'name': {'ko': '7일 연속 출석', 'en': '7-Day Streak'},
      'description': {
        'ko': '일주일 동안 쉬지 않고 학습을 이어갔어요! 앞으로도 계속 도전해 보세요.',
        'en': 'You kept learning for a full week! Keep it up.'
      },
      'howToEarn': {'ko': '7일 연속 출석하기', 'en': 'Attend 7 days in a row'},
      'imageUrl': 'assets/images/seven_day_badge.png',
    },
    {
      'id': 'summary_master',
      'name': {'ko': '요약 마스터', 'en': 'Summary Master'},
      'description': {
        'ko': '핵심을 짚어내는 능력이 뛰어나군요! 요약 실력이 날로 성장하고 있어요.',
        'en': 'You excel at extracting the gist! Your summarizing skill is growing.'
      },
      'howToEarn': {'ko': '요약 미션 완수하기', 'en': 'Complete a summary mission'},
    },
    {
      'id': 'critical_thinker',
      'name': {'ko': '비판적 사고가', 'en': 'Critical Thinker'},
      'description': {
        'ko': '깊이 있는 질문을 던지는 능력이 돋보이네요!',
        'en': 'You stand out by asking insightful questions!'
      },
      'howToEarn': {'ko': '챗봇에게 질문하기', 'en': 'Ask the chatbot a question'},
    },
    {
      'id': 'key_point_expert',
      'name': {'ko': '핵심찾기 고수', 'en': 'Key Point Expert'},
      'description': {
        'ko': '텍스트 속에서 중요한 부분을 정확히 찾아내는 능력이 뛰나요!',
        'en': 'You spot what truly matters in the text!'
      },
      'howToEarn': {'ko': '다지선다 미션 완수하기', 'en': 'Complete an MCQ mission'},
    },
    {
      'id': 'creative_thinker',
      'name': {'ko': '창의적 사고가', 'en': 'Creative Thinker'},
      'description': {
        'ko': '남다른 시각으로 세상을 바라보는 능력을 키워가고 있어요!',
        'en': 'You’re building the habit of seeing differently.'
      },
      'howToEarn': {
        'ko': '결말 바꾸기 미션 완수하기',
        'en': 'Complete an alternate-ending mission'
      },
    },
    {
      'id': 'first_post',
      'name': {'ko': '첫 글 작성', 'en': 'First Post'},
      'description': {
        'ko': '처음으로 자신의 생각을 글로 표현했어요. 앞으로 더 많은 이야기를 들려주세요!',
        'en': 'Your first written voice—can’t wait to read more!'
      },
      'howToEarn': {'ko': '첫 번째 글 작성하기', 'en': 'Write your first post'},
    },
    {
      'id': 'communication_master',
      'name': {'ko': '소통왕', 'en': 'Communication Master'},
      'description': {
        'ko': '활발하게 소통하며 생각을 나누고 있어요!',
        'en': 'You actively share and communicate ideas!'
      },
      'howToEarn': {'ko': '토론 미션 완수하기', 'en': 'Complete a discussion mission'},
    },
    {
      'id': 'sharing_champion',
      'name': {'ko': '글 공유 챔피언', 'en': 'Sharing Champion'},
      'description': {
        'ko': '좋은 글은 함께 나눠야 하죠! 여러분의 공유가 더 많은 배움을 만듭니다.',
        'en': 'Great writing should be shared—your share inspires learning.'
      },
      'howToEarn': {'ko': '에세이 글 올리기', 'en': 'Upload an essay post'},
    },
    {
      'id': 'monthly_challenge',
      'name': {'ko': '월간 챌린지', 'en': 'Monthly Challenge'},
      'description': {
        'ko': '이달의 목표를 달성했어요! 꾸준한 도전을 응원합니다.',
        'en': 'You achieved this month’s goal! Keep challenging yourself.'
      },
      'howToEarn': {'ko': '월간 목표 완료', 'en': 'Complete the monthly goal'},
    },
    {
      'id': 'like_star',
      'name': {'ko': '좋아요 스타', 'en': 'Like Star'},
      'description': {
        'ko': '사람들의 공감을 얻는 멋진 글을 작성하고 있어요!',
        'en': 'Your writing truly resonates with others!'
      },
      'howToEarn': {
        'ko': '좋아요를 많이 받은 글 작성하기',
        'en': 'Write a post that receives many likes'
      },
    },
  ];

  for (final b in badges) {
    final id = b['id'] as String;
    await col.doc(id).set(b, SetOptions(merge: true));
  }
}
