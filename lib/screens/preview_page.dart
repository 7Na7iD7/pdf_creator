import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../services/pdf_service.dart';
import '../services/pdf_service.dart';

class PreviewPage extends StatefulWidget {
  final int initialIndex;

  const PreviewPage({
    super.key,
    required this.initialIndex,
  });

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _infoAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentIndex = 0;
  bool _showInfo = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _infoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _infoAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _infoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<PdfService>(
          builder: (context, pdfService, child) {
            return Text(
              '${_currentIndex + 1} از ${pdfService.selectedImages.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showInfo ? Icons.info : Icons.info_outline,
              color: Colors.white,
            ),
            onPressed: _toggleInfo,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: AppColors.danger),
                  title: Text('حذف عکس'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'move_first',
                child: ListTile(
                  leading: Icon(Icons.first_page, color: AppColors.primary),
                  title: Text('انتقال به ابتدا'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'move_last',
                child: ListTile(
                  leading: Icon(Icons.last_page, color: AppColors.primary),
                  title: Text('انتقال به انتها'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<PdfService>(
        builder: (context, pdfService, child) {
          if (pdfService.selectedImages.isEmpty) {
            return const Center(
              child: Text(
                'هیچ عکسی یافت نشد',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            );
          }

          return Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: pdfService.selectedImages.length,
                  itemBuilder: (context, index) {
                    return _buildImageView(pdfService.selectedImages[index], index);
                  },
                ),
              ),

              _buildNavigationButtons(pdfService),
              if (_showInfo) _buildInfoPanel(pdfService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageView(File image, int index) {
    return Center(
      child: Hero(
        tag: 'image_$index',
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            image,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 60,
                      color: AppColors.secondary,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'خطا در بارگذاری تصویر',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(PdfService pdfService) {
    return Positioned.fill(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _currentIndex > 0 ? _previousImage : null,
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _currentIndex > 0 ? 0.7 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: GestureDetector(
              onTap: _currentIndex < pdfService.selectedImages.length - 1
                  ? _nextImage
                  : null,
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _currentIndex < pdfService.selectedImages.length - 1
                        ? 0.7
                        : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(PdfService pdfService) {
    final image = pdfService.selectedImages[_currentIndex];
    
    return SlideTransition(
      position: _slideAnimation,
      child: Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'اطلاعات فایل',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleInfo,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              _buildInfoRow('نام فایل:', image.path.split('/').last),
              _buildInfoRow('مسیر:', image.path),
              _buildInfoRow('اندازه:', _getFileSize(image)),
              _buildInfoRow('ترتیب در PDF:', '${_currentIndex + 1}'),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.delete,
                    label: 'حذف',
                    color: AppColors.danger,
                    onTap: () => _deleteCurrentImage(pdfService),
                  ),
                  _buildActionButton(
                    icon: Icons.first_page,
                    label: 'ابتدا',
                    color: AppColors.primary,
                    onTap: () => _moveToFirst(pdfService),
                  ),
                  _buildActionButton(
                    icon: Icons.last_page,
                    label: 'انتها',
                    color: AppColors.primary,
                    onTap: () => _moveToLast(pdfService),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextImage() {
    final pdfService = context.read<PdfService>();
    if (_currentIndex < pdfService.selectedImages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleInfo() {
    setState(() {
      _showInfo = !_showInfo;
    });
    
    if (_showInfo) {
      _infoAnimationController.forward();
    } else {
      _infoAnimationController.reverse();
    }
  }

  void _handleMenuAction(String action) {
    final pdfService = context.read<PdfService>();
    
    switch (action) {
      case 'delete':
        _deleteCurrentImage(pdfService);
        break;
      case 'move_first':
        _moveToFirst(pdfService);
        break;
      case 'move_last':
        _moveToLast(pdfService);
        break;
    }
  }

  void _deleteCurrentImage(PdfService pdfService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف عکس'),
          content: const Text('آیا مطمئن هستید که می‌خواهید این عکس را حذف کنید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('لغو'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                pdfService.removeImage(_currentIndex);
                
                if (pdfService.selectedImages.isEmpty) {
                  Navigator.of(context).pop();
                } else {
                  if (_currentIndex >= pdfService.selectedImages.length) {
                    setState(() {
                      _currentIndex = pdfService.selectedImages.length - 1;
                    });
                    _pageController.animateToPage(
                      _currentIndex,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('عکس حذف شد'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
              ),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  void _moveToFirst(PdfService pdfService) {
    if (_currentIndex > 0) {
      pdfService.reorderImages(_currentIndex, 0);
      setState(() {
        _currentIndex = 0;
      });
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('عکس به ابتدای لیست منتقل شد'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _moveToLast(PdfService pdfService) {
    final lastIndex = pdfService.selectedImages.length - 1;
    if (_currentIndex < lastIndex) {
      pdfService.reorderImages(_currentIndex, lastIndex);
      setState(() {
        _currentIndex = lastIndex;
      });
      _pageController.animateToPage(
        lastIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('عکس به انتهای لیست منتقل شد'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  String _getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'نامشخص';
    }
  }
}