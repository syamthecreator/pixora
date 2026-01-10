import 'package:flutter/material.dart';
import 'package:pixora/features/gallery/widgets/delete_fab.dart';
import 'package:pixora/features/gallery/widgets/gallery_delete_helper.dart';
import 'package:provider/provider.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:pixora/features/gallery/controller/gallery_controller.dart';
import 'package:pixora/features/gallery/models/media_type.dart';

class GalleryImageScreen extends StatelessWidget {
  final MediaItem mediaItem;

  const GalleryImageScreen({super.key, required this.mediaItem});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GalleryController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.file(mediaItem.file),
            ),
          ),

          DeleteFab(
            isDeleting: controller.isDeleting,
            color: AppColors.neonPurple,
            onPressed: () => GalleryDeleteHelper.delete(
              context: context,
              controller: controller,
              item: mediaItem,
              snackbarColor: AppColors.neonPurple,
            ),
          ),
        ],
      ),
    );
  }
}
