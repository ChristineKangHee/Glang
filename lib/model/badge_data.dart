import 'package:cloud_firestore/cloud_firestore.dart';

class AppBadge {
  final String id;
  final String name;
  final String description;
  final String howToEarn;
  final String? imageUrl;

  AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.howToEarn,
    this.imageUrl,
  });

  factory AppBadge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppBadge(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      howToEarn: data['howToEarn'] as String,
      imageUrl: data['imageUrl'] as String?,
    );
  }
}

Future<void> addBadgesToFirebase() async {
  final CollectionReference badgesCollection =
  FirebaseFirestore.instance.collection('badges');

  final List<Map<String, dynamic>> badges = [
    {
      'id': 'first_step',
      'name': '첫걸음',
      'description': '글랑에 오신 걸 환영합니다! 첫 발걸음을 내디뎠어요.',
      'howToEarn': '첫출석',
      'imageUrl': 'assets/images/first_badge.png',
    },
    {
      'id': 'three_day_streak',
      'name': '3일 연속 출석',
      'description': '꾸준한 학습 습관이 시작되었어요!',
      'howToEarn': '3일 연속 출석하기',
    },
    {
      'id': 'seven_day_streak',
      'name': '7일 연속 출석',
      'description': '일주일 동안 쉬지 않고 학습을 이어갔어요! 앞으로도 계속 도전해 보세요.',
      'howToEarn': '7일 연속 출석하기',
      'imageUrl': 'assets/images/seven_day_badge.png',
    },
    {
      'id': 'summary_master',
      'name': '요약 마스터',
      'description': '핵심을 짚어내는 능력이 뛰어나군요! 요약 실력이 날로 성장하고 있어요.',
      'howToEarn': '요약 미션 완수하기',
    },
    {
      'id': 'critical_thinker',
      'name': '비판적 사고가',
      'description': '깊이 있는 질문을 던지는 능력이 돋보이네요!',
      'howToEarn': '챗봇에게 질문하기',
    },
    {
      'id': 'key_point_expert',
      'name': '핵심찾기 고수',
      'description': '텍스트 속에서 중요한 부분을 정확히 찾아내는 능력이 뛰나요!',
      'howToEarn': '다지선다 미션 완수하기',
    },
    {
      'id': 'creative_thinker',
      'name': '창의적 사고가',
      'description': '남다른 시각으로 세상을 바라보는 능력을 키워가고 있어요!',
      'howToEarn': '결말 바꾸기 미션 완수하기',
    },
    {
      'id': 'first_post',
      'name': '첫 글 작성',
      'description': '처음으로 자신의 생각을 글로 표현했어요. 앞으로 더 많은 이야기를 들려주세요!',
      'howToEarn': '첫 번째 글 작성하기',
    },
    {
      'id': 'communication_master',
      'name': '소통왕',
      'description': '활발하게 소통하며 생각을 나누고 있어요!',
      'howToEarn': '토론 미션 완수하기',
    },
    {
      'id': 'sharing_champion',
      'name': '글 공유 챔피언',
      'description': '좋은 글은 함께 나눠야 하죠! 여러분의 공유가 더 많은 배움을 만듭니다.',
      'howToEarn': '에세이 글 올리기',
    },
    {
      'id': 'monthly_challenge',
      'name': '월간 챌린지',
      'description': '이달의 목표를 달성했어요! 꾸준한 도전을 응원합니다.',
      'howToEarn': '월간 목표 완료',
    },
    {
      'id': 'like_star',
      'name': '좋아요 스타',
      'description': '사람들의 공감을 얻는 멋진 글을 작성하고 있어요!',
      'howToEarn': '좋아요를 많이 받은 글 작성하기',
    },
  ];


  for (var badges in badges) {
    await badgesCollection.add(badges);
  }

  print('배지 데이터가 Firestore에 추가되었습니다.');
}

