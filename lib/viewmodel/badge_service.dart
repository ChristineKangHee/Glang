import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/badge_data.dart';

class BadgeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 사용자의 뱃지 subcollection 스트림을 리턴
  Stream<List<Badge>> userBadgesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('badges')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Badge.fromDocument(doc)).toList());
  }

  // 특정 뱃지의 상태 업데이트 (예: 조건 충족 시 obtained를 true로)
  Future<void> updateBadgeStatus(String userId, String badgeId, bool obtained) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('badges')
        .doc(badgeId)
        .update({'obtained': obtained});
  }

  // 신규 사용자 뱃지 초기화 예시 (앱 최초 가입 시 호출)
  Future<void> initializeUserBadges(String userId) async {
    final List<Map<String, dynamic>> badgeCatalog = [
      {
        'name': '첫걸음',
        'obtained': false,
        'description': '글랑에 오신 걸 환영합니다! 첫 발걸음을 내디뎠어요.',
        'howToEarn': '앱에 첫 로그인',
        'imageUrl': 'assets/images/first_badge.png', // 이미지 경로 지정
      },
      {
        'name': '3일 연속 출석',
        'obtained': false,
        'description': '꾸준한 학습 습관이 시작되었어요!',
        'howToEarn': '3일 연속 출석하기',
        'imageUrl': 'assets/images/three_day_badge.png', // 이미지 경로 지정
      },
      // 나머지 뱃지는 이미지 없이 현재의 형태 유지
      {
        'name': '7일 연속 출석',
        'obtained': false,
        'description': '일주일 동안 쉬지 않고 학습을 이어갔어요! 앞으로도 계속 도전해 보세요.',
        'howToEarn': '7일 연속 출석하기',
      },
      {
        'name': '요약 마스터',
        'obtained': false,
        'description': '핵심을 짚어내는 능력이 뛰어나군요! 요약 실력이 날로 성장하고 있어요.',
        'howToEarn': '주어진 텍스트를 잘 요약하기'
      },
      {'name': '비판적 사고가', 'obtained': false, 'description': '깊이 있는 질문을 던지는 능력이 돋보이네요!', 'howToEarn': '질문을 자주 던지기'},
      {'name': '핵심찾기 고수', 'obtained': false, 'description': '텍스트 속에서 중요한 부분을 정확히 찾아내는 능력이 뛰나요!', 'howToEarn': '중요한 정보를 뽑아내기'},
      {'name': '창의적 사고가', 'obtained': false, 'description': '남다른 시각으로 세상을 바라보는 능력을 키워가고 있어요!', 'howToEarn': '창의적인 아이디어를 제시하기'},
      {'name': '첫 글 작성', 'obtained': false, 'description': '처음으로 자신의 생각을 글로 표현했어요. 앞으로 더 많은 이야기를 들려주세요!', 'howToEarn': '첫 번째 글 작성'},
      {'name': '소통왕', 'obtained': false, 'description': '다른 사람과 활발하게 소통하며 생각을 나누고 있어요!', 'howToEarn': '다른 사람과 토론 참여하기'},
      {'name': '글 공유 챔피언', 'obtained': false, 'description': '좋은 글은 함께 나눠야 하죠! 여러분의 공유가 더 많은 배움을 만듭니다.', 'howToEarn': '글을 자주 공유하기'},
      {'name': '월간 챌린지', 'obtained': false, 'description': '이달의 목표를 달성했어요! 꾸준한 도전을 응원합니다.', 'howToEarn': '월간 목표 완료'},
      {'name': '좋아요 스타', 'obtained': false, 'description': '사람들의 공감을 얻는 멋진 글을 작성하고 있어요!', 'howToEarn': '좋아요를 많이 받은 글 작성'},
    ];

    final batch = _firestore.batch();
    final badgesCollection =
    _firestore.collection('users').doc(userId).collection('badges');

    for (var badge in badgeCatalog) {
      final docRef = badgesCollection.doc(); // 자동 ID 생성 또는 고유 key 사용
      batch.set(docRef, badge);
    }
    await batch.commit();
  }
}
