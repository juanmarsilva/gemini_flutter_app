import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_ui_app/config/theme/app_theme.dart';
import 'package:gemini_ui_app/presentation/providers/image/generated_images_provider.dart';
import 'package:gemini_ui_app/presentation/providers/image/is_generating_provider.dart';
import 'package:gemini_ui_app/presentation/providers/image/selected_art_provider.dart';
import 'package:gemini_ui_app/presentation/providers/image/selected_image_provider.dart';

import 'package:gemini_ui_app/presentation/widgets/chat/custom_bottom_input.dart';
import 'package:gemini_ui_app/presentation/widgets/images/history_grid.dart';
import 'package:image_picker/image_picker.dart';

const imageArtStyles = [
  'Realista',
  'Acuarela',
  'Dibujo a Lápiz',
  'Arte Digital',
  'Pintura al Óleo',
  'Dibujo al Carboncillo',
  'Ilustración Digital',
  'Estilo Manga',
  'Pixelado',
];

class ImagePlaygroundScreen extends ConsumerWidget {
  const ImagePlaygroundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Imágenes con Gemini')),
      backgroundColor: seedColor,
      body: Column(
        children: [
          // Espacio para imágenes generadas
          GeneratedImageGallery(),

          // Selector de estilo de arte
          ArtStyleSelector(),

          // Llenar el espacio
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: HistoryGrid(),
            ),
          ),

          // Espacio para el prompt
          CustomBottomInput(
            onSend: (partialText, {List<XFile> images = const []}) async {
              final generatedImagesNotifier = ref.read(
                generatedImagesProvider.notifier,
              );

              final selectedStyle = ref.read(selectedArtStyleProvider);

              final selectedImage =
                  await ref
                      .read(selectedImageProvider.notifier)
                      .getXFileFromSelectedImage();

              if (selectedImage != null) {
                images.add(selectedImage);
              }

              generatedImagesNotifier.clearImages();

              String promptWithStyle = partialText.text;

              if (selectedStyle.isNotEmpty) {
                promptWithStyle += 'con un estilo $selectedStyle';
              }

              generatedImagesNotifier.generateImage(
                promptWithStyle,
                images: images,
              );
            },
          ),
        ],
      ),
    );
  }
}

class GeneratedImageGallery extends ConsumerWidget {
  const GeneratedImageGallery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generatedImages = ref.watch(generatedImagesProvider);
    final isGenerating = ref.watch(isGeneratingProvider);

    final PageController pageController = PageController(
      viewportFraction: 0.6,
      initialPage: 0,
    );

    return SizedBox(
      height: 200,
      child: PageView(
        onPageChanged: (index) {
          if (index == generatedImages.length - 1) {
            ref
                .read(generatedImagesProvider.notifier)
                .generateImageWithPreviousPrompt();
          }
        },
        controller: pageController,
        padEnds: true, // Cambiado a true para centrar la primera imagen
        children: [
          if (generatedImages.isEmpty && !isGenerating)
            const EmptyPlaceholderImage(),

          ...generatedImages.map(
            (imageUrl) => GeneratedImage(imageUrl: imageUrl),
          ),

          if (isGenerating) const GeneratingPlaceholderImage(),
        ],
      ),
    );
  }
}

class GeneratedImage extends StatelessWidget {
  final String imageUrl;

  const GeneratedImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 5,
            spreadRadius: 5,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}

class ArtStyleSelector extends ConsumerWidget {
  const ArtStyleSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedArt = ref.watch(selectedArtStyleProvider);

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageArtStyles.length,
        itemBuilder: (context, index) {
          final style = imageArtStyles[index];

          final activeColor =
              selectedArt == style
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null;

          return GestureDetector(
            onTap: () {
              ref.read(selectedArtStyleProvider.notifier).setSelectedArt(style);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Chip(label: Text(style), backgroundColor: activeColor),
            ),
          );
        },
      ),
    );
  }
}

class EmptyPlaceholderImage extends StatelessWidget {
  const EmptyPlaceholderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 5,
            spreadRadius: 5,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, size: 50, color: Colors.white),
          const Text('Empieza a generar imágenes'),
        ],
      ),
    );
  }
}

class GeneratingPlaceholderImage extends StatelessWidget {
  const GeneratingPlaceholderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 5,
            spreadRadius: 5,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          const SizedBox(height: 15),
          const Text(
            'Generando imagen...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
