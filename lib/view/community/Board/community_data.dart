class Post {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String profileImage;
  final List<String> tags;
  final int likes;
  final int views;
  final DateTime? createdAt; // Make it nullable

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.profileImage,
    required this.tags,
    required this.likes,
    required this.views,
    required this.createdAt, // CreatedAt should be nullable now
  });
}

final List<Post> posts = [
  Post(
    id: '1',
    title: 'TOPIC 시험 준비',
    content: '시험 준비를 어떻게 해야할까요? 시험 준비를 시험 준비를 어떻게 해야할까요? 첫번째 글의 더미입니다. 어떻게 작성하는지 보려고 더미 데이터를 만들었어요.',
    authorName: '김서현',
    profileImage: 'https://via.placeholder.com/40x40',
    tags: ['#카페', '#일상'],
    likes: 67,
    views: 203,
    createdAt: DateTime.now().subtract(Duration(hours: 3)), // 3시간 전
  ),
  Post(
    id: '2',
    title: '두 번째 게시글',
    content: '두 번째 게시글의 내용입니다. 어떻게 준비하면 좋을까요?두 번째 게시글의 내용입니다. 어떻게 준비하면 좋을까요?두 번째 게시글의 내용입니다. 어떻게 준비하면 좋을까요?두 번째 게시글의 내용입니다. 어떻게 준비하면 좋을까요?두 번째 게시글의 내용입니다. 어떻게 준비하면 좋을까요?',
    authorName: '사용자2',
    profileImage: 'https://via.placeholder.com/40x40',
    tags: ['#공부', '#토픽'],
    likes: 45,
    views: 180,
    createdAt: DateTime.now().subtract(Duration(days: 1, hours: 5)), // 1일 5시간 전
  ),
];
