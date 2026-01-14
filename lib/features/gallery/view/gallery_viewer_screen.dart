import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../controller/gallery_controller.dart';
import '../widgets/delete_fab.dart';
import '../widgets/media_page.dart';

class GalleryViewerScreen extends StatefulWidget {
  final int initialIndex;

  const GalleryViewerScreen({super.key, required this.initialIndex});

  @override
  State<GalleryViewerScreen> createState() => _GalleryViewerScreenState();
}

class _GalleryViewerScreenState extends State<GalleryViewerScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    String fileName(String path) {
      return path.split('/').last;
    }

    final controller = context.watch<GalleryController>();
    final media = controller.media;

    if (media.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.kSecondaryColour,
        body: Center(
          child: Text(
            'No media',
            style: TextStyle(color: AppColors.kWhiteColour),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.kSecondaryColour,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: media.length,
              onPageChanged: (i) {
                setState(() => _currentIndex = i);
              },
              itemBuilder: (_, index) => MediaPage(item: media[index]),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.kSecondaryColour, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.kWhiteColour,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),

                    Expanded(
                      child: Text(
                        fileName(media[_currentIndex].file.path),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.kWhiteColour,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DeleteFab(
              isDeleting: controller.isDeleting,
              color: AppColors.kRedColour,
              onPressed: () async {
                final controller = context.read<GalleryController>();

                final shouldDelete = await controller.showDeleteConfirmation(
                  context,
                );
                if (!shouldDelete) return;

                final nextIndex = await controller.deleteAndResolveIndex(
                  _currentIndex,
                );

                if (!mounted) return;

                if (nextIndex == null) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  return;
                }

                _currentIndex = nextIndex;
                _pageController.jumpToPage(nextIndex);
              },
            ),
          ],
        ),
      ),
    );
  }
}
