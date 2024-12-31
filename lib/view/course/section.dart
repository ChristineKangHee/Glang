import 'package:flutter/material.dart';

class SectionData {
  final Color color;
  final Color colorOscuro;
  final int etapa;
  final int section;
  final String title;

  const SectionData({
    required this.color,
    required this.colorOscuro,
    required this.etapa,
    required this.section,
    required this.title,
  });
}

class Section extends StatelessWidget {
  final SectionData data;

  const Section({super.key, required this.data});

  double getLeft(int indice) {
    const margin = 72.0;
    int pos = indice % 9;

    if (pos == 1) {
      return margin;
    }
    if (pos == 2) {
      return margin * 2;
    }
    if (pos == 3) {
      return margin;
    }
    return 0.0;
  }

  double getRight(int indice) {
    const margin = 72.0;
    int pos = indice % 9;

    if (pos == 5) {
      return margin;
    }
    if (pos == 6) {
      return margin * 2;
    }
    if (pos == 7) {
      return margin;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(
                color: Color(0xFF2D3D41),
              ),
            ),
            const SizedBox(width: 16,),
            Text(
              data.title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(width: 16,),
            const Expanded(
              child: Divider(
                color: Color(0xFF2D3D41),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 24.0,
        ),
        ...List.generate(
            9, (i) => i % 9 != 4? Container(
              margin: EdgeInsets.only(
                bottom: i != 8 ? 24.0 : 0,
                left: getLeft(i),
                right: getRight(i),
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: data.colorOscuro,
                    width: 6.0,
                  )
                ),
                borderRadius: BorderRadius.circular(36.0)
              ),
              child: ElevatedButton(
                onPressed: (){},
                style: ElevatedButton.styleFrom(
                  backgroundColor: data.color,
                  fixedSize: const Size(56, 48),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                ),
                child: Icon(Icons.star, color: Colors.white, size: 30,)
              ),
            ) : Container(
          child: ElevatedButton(
              onPressed: (){},
              style: ElevatedButton.styleFrom(
                backgroundColor: data.color,
                fixedSize: const Size(56, 48),
                elevation: 0,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size.zero,
              ),
              child: Icon(Icons.star, color: Colors.red, size: 30,)
          ),
        )
        ),
      ],
    );
  }
}
