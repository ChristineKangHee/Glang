import 'package:flutter/material.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_navigation_bar.dart';
import 'section.dart';

class CourseMain extends StatefulWidget {
  CourseMain({super.key}); // const 제거

  static Color _darkenColor(Color color, double factor) {
    return HSLColor.fromColor(color)
        .withLightness(
        (HSLColor.fromColor(color).lightness - factor).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  State<CourseMain> createState() => _CourseMainState();
}

class _CourseMainState extends State<CourseMain> {
  final data = <SectionData>[
    SectionData(
      color: Colors.blue,
      colorOscuro: CourseMain._darkenColor(Colors.blue, 0.1),
      etapa: 1,
      section: 1,
      title: 'Section 1',
    ),
    SectionData(
      color: Colors.green,
      colorOscuro: CourseMain._darkenColor(Colors.green, 0.1),
      etapa: 1,
      section: 2,
      title: 'Section 2',
    ),
    SectionData(
      color: Colors.orange,
      colorOscuro: CourseMain._darkenColor(Colors.orange, 0.1),
      etapa: 1,
      section: 3,
      title: 'Section 3',
    ),
  ];
  int iCurrentSection = 0;
  final heightFirstBox = 56.0;
  final heightSection = 764.0;
  final scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(scrollListener);
  }

  void scrollListener() {
    final currentScroll = scrollCtrl.position.pixels - heightFirstBox - 24.0;
    int index = (currentScroll / heightSection).floor();

    if (index < 0) index = 0;

    if (index != iCurrentSection) setState(() => iCurrentSection = index);
  }

  @override
  void dispose() {
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(title: 'App Title'),
        body: Stack(
          children: [
            ListView.separated(
              controller: scrollCtrl,
              itemBuilder: (_, i) => i == 0
                  ? SizedBox(
                      height: heightFirstBox,
                    )
                  : Section(
                      data: data[i - 1]
                    ),
              separatorBuilder: (_, i)=> const SizedBox(
                height: 24.0,
              ),
              padding: const EdgeInsets.only(
                bottom: 24.0,
                left: 16.0,
                right: 16.0,
              ),
              itemCount: data.length + 1,
            ),
            CurrentSection(data: data[iCurrentSection]),
          ],
        ),
        bottomNavigationBar: CustomNavigationBar(),
      ),
    );
  }
}

class CurrentSection extends StatelessWidget {
  final SectionData data;

  const CurrentSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("ETAPA ${data.etapa} SECTION ${data.section}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  ),
                  Text(data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0
                  ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

