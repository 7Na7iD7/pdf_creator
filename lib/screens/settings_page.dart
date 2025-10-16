import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/core_constants.dart';
import '../services/pdf_service.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    final pdfService = context.read<PdfService>();
    _fileNameController.text = pdfService.settings.fileName;

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تنظیمات PDF',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefaults,
            tooltip: 'بازگردانی به پیش‌فرض',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Consumer<PdfService>(
            builder: (context, pdfService, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQualitySection(pdfService),
                    const SizedBox(height: 16),
                    _buildPageSizeSection(pdfService),
                    const SizedBox(height: 16),
                    _buildOrientationSection(pdfService),
                    const SizedBox(height: 16),
                    _buildFileNameSection(pdfService),
                    const SizedBox(height: 16),
                    _buildAdvancedSection(pdfService),
                    const SizedBox(height: 16),
                    _buildThemeSection(),
                    const SizedBox(height: 24),
                    _buildPreviewSection(pdfService),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQualitySection(PdfService pdfService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.high_quality, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'کیفیت PDF',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Slider(
                  value: pdfService.settings.quality.index.toDouble(),
                  min: 0,
                  max: 2,
                  divisions: 2,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.primaryLight,
                  onChanged: (value) {
                    final quality = PdfQuality.values[value.toInt()];
                    _updateSettings(pdfService.settings.copyWith(quality: quality));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQualityLabel('کم', PdfQuality.low, pdfService.settings.quality),
                    _buildQualityLabel('متوسط', PdfQuality.medium, pdfService.settings.quality),
                    _buildQualityLabel('بالا', PdfQuality.high, pdfService.settings.quality),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryUltraLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pdfService.settings.quality.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityLabel(String label, PdfQuality quality, PdfQuality currentQuality) {
    final isSelected = quality == currentQuality;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildPageSizeSection(PdfService pdfService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.aspect_ratio, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'اندازه صفحه',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: PdfPageSize.values.map((size) {
                final isSelected = pdfService.settings.pageSize == size;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        _updateSettings(pdfService.settings.copyWith(pageSize: size));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.surface,
                        foregroundColor: isSelected ? Colors.white : AppColors.secondary,
                        elevation: isSelected ? 4 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.secondaryLight,
                          ),
                        ),
                      ),
                      child: Text(
                        size.displayName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryUltraLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pdfService.settings.pageSize.dimensions,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrientationSection(PdfService pdfService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.rotate_90_degrees_ccw, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'جهت صفحه',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: PdfOrientation.values.map((orientation) {
                return RadioListTile<PdfOrientation>(
                  value: orientation,
                  groupValue: pdfService.settings.orientation,
                  onChanged: (value) {
                    if (value != null) {
                      _updateSettings(pdfService.settings.copyWith(orientation: value));
                    }
                  },
                  activeColor: AppColors.primary,
                  title: Text(orientation.displayName),
                  subtitle: Text(orientation.description),
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileNameSection(PdfService pdfService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'نام فایل PDF',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fileNameController,
              decoration: InputDecoration(
                hintText: 'نام فایل را وارد کنید',
                prefixIcon: const Icon(Icons.edit, color: AppColors.primary),
                suffixText: '.pdf',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  _updateSettings(pdfService.settings.copyWith(fileName: value.trim()));
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              'نام کامل فایل: ${_fileNameController.text}_timestamp.pdf',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection(PdfService pdfService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'تنظیمات پیشرفته',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              value: pdfService.settings.addPageNumbers,
              onChanged: (value) {
                _updateSettings(pdfService.settings.copyWith(addPageNumbers: value));
              },
              title: const Text('افزودن شماره صفحه'),
              subtitle: const Text('شماره صفحات در پایین PDF نمایش داده می‌شود'),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(height: 24),

            SwitchListTile(
              value: pdfService.settings.addWatermark,
              onChanged: (value) {
                _updateSettings(pdfService.settings.copyWith(addWatermark: value));
              },
              title: const Text('افزودن واترمارک'),
              subtitle: const Text('نام برنامه به عنوان واترمارک اضافه می‌شود'),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.palette, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'تم برنامه',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  title: const Text('حالت تاریک'),
                  subtitle: Text(
                    themeProvider.isDarkMode
                        ? 'تم تاریک فعال است'
                        : 'تم روشن فعال است',
                  ),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewSection(PdfService pdfService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.preview, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'پیش‌نمایش تنظیمات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryUltraLight.withOpacity(0.5),
                    AppColors.primary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildPreviewRow('کیفیت:', pdfService.settings.quality.displayName),
                  _buildPreviewRow('اندازه صفحه:', pdfService.settings.pageSize.displayName),
                  _buildPreviewRow('جهت صفحه:', pdfService.settings.orientation.displayName),
                  _buildPreviewRow('نام فایل:', '${pdfService.settings.fileName}.pdf'),
                  _buildPreviewRow(
                    'شماره صفحه:',
                    pdfService.settings.addPageNumbers ? 'فعال' : 'غیرفعال',
                  ),
                  _buildPreviewRow(
                    'واترمارک:',
                    pdfService.settings.addWatermark ? 'فعال' : 'غیرفعال',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (pdfService.selectedImages.isNotEmpty)
              FutureBuilder<int>(
                future: pdfService.estimatePdfSize(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final sizeInMB = snapshot.data! / (1024 * 1024);
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'حجم تقریبی: ${sizeInMB.toStringAsFixed(2)} MB',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.info,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: pdfService.selectedImages.isNotEmpty
                    ? () => _testSettings(pdfService)
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('تست تنظیمات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  void _updateSettings(PdfSettings newSettings) {
    context.read<PdfService>().updateSettings(newSettings);
    if (_fileNameController.text != newSettings.fileName) {
      _fileNameController.text = newSettings.fileName;
    }
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('بازگردانی تنظیمات'),
          content: const Text('آیا می‌خواهید همه تنظیمات را به حالت پیش‌فرض برگردانید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateSettings(const PdfSettings());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تنظیمات به حالت پیش‌فرض برگردانده شد'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('بازگردانی'),
            ),
          ],
        );
      },
    );
  }

  void _testSettings(PdfService pdfService) {
    if (pdfService.selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ابتدا عکس‌هایتان را انتخاب کنید'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    Navigator.of(context).pop();
    pdfService.generatePdf().then((filePath) {
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF با موفقیت ایجاد شد'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در تولید PDF: $error'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });
  }
}