import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_ui_app/presentation/providers/image/generated_history_provider.dart';

class HistoryGrid extends ConsumerWidget {
  const HistoryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generatedHistory = ref.watch(generatedHistoryProvider);

    return GridView.builder(
      itemCount: generatedHistory.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final imageUrl = generatedHistory[index];

        return GestureDetector(
          onTap: () {},
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(width: 3, color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
