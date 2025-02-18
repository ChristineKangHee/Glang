class Memo {
  final String id;
  final String stageId;            // 스테이지 식별자 (나중에 원문 데이터를 불러올 때 사용)
  final String subdetailTitle;     // StageData의 subdetailTitle (메모 목록에 보여질 원문 제목)
  final String selectedText;       // 사용자가 선택한 텍스트
  final String note;               // 사용자가 입력한 메모 내용
  final DateTime createdAt;        // 생성일

  Memo({
    required this.id,
    required this.stageId,
    required this.subdetailTitle,
    required this.selectedText,
    required this.note,
    required this.createdAt,
  });

  // Firestore에 저장할 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'stageId': stageId,
      'subdetailTitle': subdetailTitle,
      'selectedText': selectedText,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Firestore 데이터로부터 Memo 생성
  factory Memo.fromMap(String id, Map<String, dynamic> map) {
    return Memo(
      id: id,
      stageId: map['stageId'] as String,
      subdetailTitle: map['subdetailTitle'] as String,
      selectedText: map['selectedText'] as String,
      note: map['note'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
