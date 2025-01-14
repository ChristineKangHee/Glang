import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';

class CELearning extends StatelessWidget {
  const CELearning({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar_2depth_8(title: "결말바꾸기"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이머와 제목 섹션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.timer, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text("00:23", style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const Text("글을 읽고 나만의 결말을 작성해보세요!",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            // 책 정보
            Row(
              children: const [
                Text(
                  "<글의 가족 이야기>",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  "| 김담당",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 본문 텍스트
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Text(
                "결국 주인공은 친구들과 힘을 합쳐 어려움을 극복했습니다. "
                    "용기와 지혜를 발휘한 덕분에 모두가 함께 웃으며 행복한 결말을 맞이했습니다. "
                    "그날 이후로 마을에는 평화와 기쁨이 가득했고, 주인공은 소중한 가르침을 "
                    "마음에 새기며 새로운 모험을 준비했습니다.",
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            // 사용자 입력 영역
            const Text("나의 답변", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 5,
              maxLength: 50,
              decoration: InputDecoration(
                hintText: "글을 작성해주세요.",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                counterText: "0/50",
              ),
            ),
            const Spacer(),
            // 제출 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 제출 버튼 액션
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade100,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text("제출하기", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
