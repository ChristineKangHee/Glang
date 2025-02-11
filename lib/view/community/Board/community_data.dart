class Post {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String profileImage;
  final List<String> tags;
  final int likes;
  final int views;
  final DateTime? createdAt;
  final String category; // '코스', '인사이트', '에세이' 구분

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.profileImage,
    required this.tags,
    required this.likes,
    required this.views,
    required this.createdAt,
    required this.category,
  });
}

final List<Post> posts = [
  Post(
    id: '1',
    title: 'TOPIC 시험 준비',
    content: '시험 준비를 어떻게 해야할까요?',
    authorName: '김서현',
    profileImage: 'https://via.placeholder.com/40x40',
    tags: ['#카페', '#일상'],
    likes: 67,
    views: 203,
    createdAt: DateTime.now().subtract(Duration(hours: 3)),
    category: '미션 글',
  ),
  Post(
    id: '2',
    title: 'two',
    content: '두 번째 게시글의 내용입니다.',
    authorName: '사용자2',
    profileImage: 'https://via.placeholder.com/40x40',
    tags: ['#공부', '#토픽'],
    likes: 45,
    views: 180,
    createdAt: DateTime.now().subtract(Duration(days: 1, hours: 5)),
    category: '자유글',
  ),
  Post(
    id: '3',
    title: '에세이: 독서의 힘',
    content: '독서를 통해 얻을 수 있는 것들...',
    authorName: '이민준',
    profileImage: 'https://via.placeholder.com/40x40',
    tags: ['#독서', '#에세이'],
    likes: 88,
    views: 342,
    createdAt: DateTime.now().subtract(Duration(days: 2)),
    category: '에세이',
  ),
];