import 'section_data.dart';

/// 스테이지 데이터 목록
final List<StageData> stageList = [
  StageData(
    subdetailTitle: '읽기 도구의 필요성',
    totalTime: '30',
    achievement: '10',
    difficultyLevel: '쉬움',
    textContents: '읽기 도구가 왜 필요한지에 대해 알아봅니다.',
    missions: ['미션 1-1', '미션 1-2', '미션 1-3'],
    effects: ['이해력 향상', '집중력 향상', '읽기 속도 증가'],
    status: 'start',
  ),
  StageData(
    subdetailTitle: '읽기 도구 사용법',
    totalTime: '20',
    achievement: '0',
    difficultyLevel: '쉬움',
    textContents: '읽기 도구의 사용법을 익힙니다.',
    missions: ['미션 2-1', '미션 2-2', '미션 2-3'],
    effects: ['읽기 효율성 증가', '정확도 향상'],
    status: 'locked',
  ),
  StageData(
    subdetailTitle: '긴 글 읽기 연습',
    totalTime: '40',
    achievement: '0',
    difficultyLevel: '보통',
    textContents: '긴 글을 빠르고 정확하게 읽는 방법을 배웁니다.',
    missions: ['미션 3-1', '미션 3-2', '미션 3-3'],
    effects: ['속독 능력 향상', '핵심 내용 파악'],
    status: 'locked',
  ),
  StageData(
    subdetailTitle: '논리적 사고를 위한 독서법',
    totalTime: '50',
    achievement: '0',
    difficultyLevel: '어려움',
    textContents: '논리적 사고를 향상시키는 독서법을 학습합니다.',
    missions: ['미션 4-1', '미션 4-2', '미션 4-3'],
    effects: ['논리적 사고 향상', '비판적 읽기 능력'],
    status: 'locked',
  ),
];
