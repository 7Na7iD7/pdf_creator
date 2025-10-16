import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/core_constants.dart';
import '../core/constants/app_colors.dart';
import '../services/pdf_service.dart';
import '../services/statistics_service.dart';
import '../services/quick_actions_service.dart';
import 'preview_page.dart';
import 'settings_page.dart';
import 'statistics_page.dart';
import '../providers/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _listAnimationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _listAnimation;
  late Animation<double> _headerAnimation;

  final QuickActionsService _quickActionsService = QuickActionsService();

  bool _isGridView = true;
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _initServices();
    _initAnimations();
  }

  void _initServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PdfService>().loadSettings();
      context.read<StatisticsService>().loadStatistics();
    });
  }

  void _initAnimations() {
    _fabAnimationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );

    _listAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _listAnimationController, curve: Curves.easeOutBack),
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeIn),
    );

    _fabAnimationController.forward();
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _listAnimationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<PdfService>(
        builder: (context, pdfService, child) {
          return Column(
            children: [
              _buildInfoBar(pdfService),
              Expanded(
                child: pdfService.selectedImages.isEmpty
                    ? _buildEmptyState()
                    : _buildImageView(pdfService),
              ),
              if (pdfService.isGenerating) _buildProgressBar(pdfService),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(),
      drawer: _buildDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: FadeTransition(
        opacity: _headerAnimation,
        child: const Text(
          AppConstants.appTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
          tooltip: _isGridView ? 'نمای لیست' : 'نمای شبکه',
        ),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
              tooltip: 'تغییر تم',
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _openSettings,
          tooltip: 'تنظیمات',
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.picture_as_pdf, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  AppConstants.appNamePersian,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'نسخه ${AppConstants.appVersion}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.primary),
            title: const Text('صفحه اصلی'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: AppColors.success),
            title: const Text('آمار و گزارش'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.secondary),
            title: const Text('تنظیمات'),
            onTap: () {
              Navigator.pop(context);
              _openSettings();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history, color: AppColors.info),
            title: const Text('فایل‌های اخیر'),
            onTap: () async {
              Navigator.pop(context);
              await _quickActionsService.showRecent(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_open, color: AppColors.warning),
            title: const Text('مدیریت فایل‌ها'),
            onTap: () {
              Navigator.pop(context);
              _manageFiles();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.info),
            title: const Text('درباره برنامه'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: AppColors.primary),
            title: const Text('اشتراک‌گذاری برنامه'),
            onTap: () {
              Navigator.pop(context);
              _shareApp();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar(PdfService pdfService) {
    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          gradient: AppColors.glassColor,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(AppConstants.radiusLarge),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.photo_library, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'تعداد: ${pdfService.selectedImages.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'کیفیت: ${pdfService.settings.quality.displayName}',
                    style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'اندازه: ${pdfService.settings.pageSize.displayName}',
                    style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'جهت: ${pdfService.settings.orientation.displayName}',
                    style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: _headerAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.glassWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
              ),
              child: Icon(
                Icons.image_not_supported,
                size: 80,
                color: AppColors.secondary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'هیچ عکسی انتخاب نشده',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'برای شروع، عکس‌هایتان را اضافه کنید',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('انتخاب عکس‌ها'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageView(PdfService pdfService) {
    _listAnimationController.forward();

    return SlideTransition(
      position: _listAnimation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: _isGridView
            ? _buildGridView(pdfService)
            : _buildListView(pdfService),
      ),
    );
  }

  Widget _buildGridView(PdfService pdfService) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: pdfService.selectedImages.length,
      itemBuilder: (context, index) {
        return _buildImageCard(pdfService, index);
      },
    );
  }

  Widget _buildListView(PdfService pdfService) {
    return ListView.builder(
      itemCount: pdfService.selectedImages.length,
      itemBuilder: (context, index) {
        return _buildImageListTile(pdfService, index);
      },
    );
  }

  Widget _buildImageCard(PdfService pdfService, int index) {
    final image = pdfService.selectedImages[index];
    final isSelected = _selectedIndices.contains(index);

    return GestureDetector(
      onTap: () => _isSelectionMode
          ? _toggleSelection(index)
          : _previewImages(index),
      onLongPress: () {
        if (!_isSelectionMode) {
          setState(() {
            _isSelectionMode = true;
            _selectedIndices.add(index);
          });
        }
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                tag: 'image_$index',
                child: Image.file(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.secondaryUltraLight,
                      child: const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: AppColors.secondary,
                      ),
                    );
                  },
                ),
              ),
            ),
            if (isSelected)
              Positioned.fill(
                child: Container(
                  color: AppColors.primary.withOpacity(0.3),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () => _removeImage(pdfService, index),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                child: Text(
                  image.path.split('/').last,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageListTile(PdfService pdfService, int index) {
    final image = pdfService.selectedImages[index];
    final isSelected = _selectedIndices.contains(index);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
          child: isSelected
              ? Container(
            color: AppColors.primary.withOpacity(0.5),
            child: const Icon(Icons.check, color: Colors.white),
          )
              : null,
        ),
        title: Text(
          image.path.split('/').last,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('موقعیت: ${index + 1}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: AppColors.info),
              onPressed: () => _previewImages(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.danger),
              onPressed: () => _removeImage(pdfService, index),
            ),
          ],
        ),
        onTap: () => _isSelectionMode
            ? _toggleSelection(index)
            : _previewImages(index),
        onLongPress: () {
          if (!_isSelectionMode) {
            setState(() {
              _isSelectionMode = true;
              _selectedIndices.add(index);
            });
          }
        },
      ),
    );
  }

  Widget _buildProgressBar(PdfService pdfService) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'در حال تولید PDF...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${(pdfService.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            child: LinearProgressIndicator(
              value: pdfService.progress,
              minHeight: 8,
              backgroundColor: AppColors.primaryUltraLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (pdfService.currentProcessingFile.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'پردازش: ${pdfService.currentProcessingFile}',
              style: const TextStyle(fontSize: 12, color: AppColors.secondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: pdfService.cancelGeneration,
            icon: const Icon(Icons.cancel, color: AppColors.danger),
            label: const Text('لغو', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Consumer<PdfService>(
      builder: (context, pdfService, child) {
        if (_isSelectionMode && _selectedIndices.isNotEmpty) {
          return _buildSelectionFAB(pdfService);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pdfService.selectedImages.isNotEmpty)
              AnimatedBuilder(
                animation: _fabAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _fabAnimation.value,
                    child: FloatingActionButton.extended(
                      heroTag: 'generate_pdf',
                      onPressed: pdfService.isGenerating ? null : _generatePdf,
                      backgroundColor: AppColors.success,
                      icon: pdfService.isGenerating
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(Icons.picture_as_pdf),
                      label: Text(
                        pdfService.isGenerating ? 'در حال تولید...' : 'تبدیل به PDF',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _fabAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimation.value,
                  child: FloatingActionButton(
                    heroTag: 'add_images',
                    onPressed: _pickImages,
                    tooltip: 'اضافه کردن عکس',
                    child: const Icon(Icons.add_photo_alternate),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectionFAB(PdfService pdfService) {
    return FloatingActionButton.extended(
      onPressed: () {
        _deleteSelectedImages(pdfService);
      },
      backgroundColor: AppColors.danger,
      icon: const Icon(Icons.delete_sweep),
      label: Text('حذف ${_selectedIndices.length} مورد'),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        if (_selectedIndices.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _deleteSelectedImages(PdfService pdfService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف عکس‌های انتخاب شده'),
          content: Text('آیا می‌خواهید ${_selectedIndices.length} عکس را حذف کنید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                final indices = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
                for (final index in indices) {
                  pdfService.removeImage(index);
                }
                setState(() {
                  _selectedIndices.clear();
                  _isSelectionMode = false;
                });
                _showSnackBar('عکس‌ها حذف شدند', isError: false);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImages() async {
    try {
      final permission = await Permission.photos.request();
      if (!permission.isGranted && mounted) {
        _showSnackBar('مجوز دسترسی به گالری لازم است', isError: true);
        return;
      }

      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: AppConstants.defaultImagePickerQuality,
      );

      if (images.isNotEmpty && mounted) {
        final imageFiles = images.map((image) => File(image.path)).toList();
        if (mounted) {
          context.read<PdfService>().addImages(imageFiles);
          _showSnackBar('${images.length} عکس اضافه شد', isError: false);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('خطا در انتخاب عکس‌ها: $e', isError: true);
      }
    }
  }

  void _removeImage(PdfService pdfService, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف عکس'),
          content: const Text('آیا مطمئن هستید که می‌خواهید این عکس را حذف کنید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                pdfService.removeImage(index);
                _showSnackBar('عکس حذف شد', isError: false);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  void _previewImages(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewPage(initialIndex: initialIndex),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  Future<void> _generatePdf() async {
    try {
      final pdfService = context.read<PdfService>();
      final statsService = context.read<StatisticsService>();

      final filePath = await pdfService.generatePdf();

      if (filePath != null && mounted) {
        // ثبت آمار
        final file = File(filePath);
        final fileSize = await file.length();

        await statsService.recordPdfCreation(
          imageCount: pdfService.selectedImages.length,
          fileSize: fileSize,
          quality: pdfService.settings.quality.name,
        );

        _showSuccessDialog(filePath);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('خطا در تولید PDF: $e', isError: true);
      }
    }
  }

  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'PDF با موفقیت ایجاد شد',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('فایل PDF شما آماده است:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryUltraLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        filePath.split('/').last,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await _quickActionsService.shareFile(context, filePath);
              },
              icon: const Icon(Icons.share),
              label: const Text('اشتراک‌گذاری'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<PdfService>().clearImages();
              },
              child: const Text('پاک کردن لیست'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('تمام'),
            ),
          ],
        );
      },
    );
  }

  void _manageFiles() {
    _quickActionsService.showRecent(context);
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      AppConstants.appNamePersian,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'نسخه 1.0.0',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                AppConstants.appDescription,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'TNa7iDT',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Text(
                'این برنامه به شما امکان می‌دهد تصاویر خود را به راحتی به PDF تبدیل کنید',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('بستن'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareApp() async {
    try {
      await Share.share(
        'از برنامه ${AppConstants.appNamePersian} استفاده کنید!\n\n'
            'تبدیل آسان تصاویر به PDF\n'
            'نسخه: ${AppConstants.appVersion}\n\n'
            '✨ ویژگی‌ها:\n'
            '📸 تبدیل عکس به PDF\n'
            '🎨 تنظیمات کیفیت\n'
            '📊 گزارش‌های آماری\n'
            '☁️ اشتراک‌گذاری آسان\n\n'
            'دانلود از فروشگاه‌های اپلیکیشن',
        subject: 'معرفی برنامه ${AppConstants.appNamePersian}',
      );

      _showSnackBar('از اشتراک‌گذاری شما متشکریم!', isError: false);
    } catch (e) {
      _showSnackBar('خطا در اشتراک‌گذاری برنامه: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'باشه',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}