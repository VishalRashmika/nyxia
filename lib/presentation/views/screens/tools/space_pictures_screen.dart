import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodels/space_pictures_viewmodel.dart';

class SpacePicturesScreen extends StatefulWidget {
  const SpacePicturesScreen({Key? key}) : super(key: key);

  @override
  State<SpacePicturesScreen> createState() => _SpacePicturesScreenState();
}

class _SpacePicturesScreenState extends State<SpacePicturesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'SPACE PICTURES',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Latest button (yesterday APOD)
          Consumer<SpacePicturesViewModel>(
            builder: (context, viewModel, child) {
              final isLatest = viewModel.isAtLatestAvailableDate;

              if (isLatest) return const SizedBox();

              return IconButton(
                icon: const Icon(Icons.today),
                tooltip: 'Go to Latest',
                onPressed: () => viewModel.gotoToday(),
              );
            },
          ),
        ],
      ),
      body: Consumer<SpacePicturesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && !viewModel.hasApod) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null && !viewModel.hasApod) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.error!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!viewModel.hasApod) {
            return const Center(child: Text('No picture available'));
          }

          final apod = viewModel.currentApod!;

          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Date Display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      DateFormat('MMMM dd, yyyy').format(viewModel.currentDate),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Image
                  if (apod.mediaType == 'image')
                    GestureDetector(
                      onTap: () =>
                          _showFullScreenImage(context, apod.hdUrl ?? apod.url),
                      child: Hero(
                        tag: 'apod_image',
                        child: Image.network(
                          apod.url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 300,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.error,
                                size: 64,
                                color: Colors.red,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 300,
                      color: Colors.black,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam, size: 64, color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Video content',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          apod.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Copyright
                        if (apod.copyright != null)
                          Text(
                            '© ${apod.copyright}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Explanation
                        Text(
                          apod.explanation,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(
                          height: 80,
                        ), // Space for navigation buttons
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<SpacePicturesViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Previous Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: viewModel.canGoPrevious && !viewModel.isLoading
                          ? () => viewModel.gotoPrevious()
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('PREVIOUS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Next Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: viewModel.canGoNext && !viewModel.isLoading
                          ? () => viewModel.gotoNext()
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('NEXT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: Center(
            child: InteractiveViewer(
              child: Hero(tag: 'apod_image', child: Image.network(imageUrl)),
            ),
          ),
        ),
      ),
    );
  }
}
