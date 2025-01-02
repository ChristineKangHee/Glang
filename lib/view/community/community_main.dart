import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_navigation_bar.dart';
import '../../viewmodel/custom_colors_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityMain extends ConsumerWidget {
  const CommunityMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider); // CustomColors 가져오기

    return SafeArea(
        child: Scaffold(
          appBar: const CustomAppBar_Community(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ChatScreen(),
              ],
            ),
          ),
          bottomNavigationBar: const CustomNavigationBar(),
        )
    );
  }
}
