import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/core_constants.dart';
import '../services/statistics_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsService>().loadStatistics();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'آمار و گزارش',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StatisticsService>().loadStatistics();
            },
            tooltip: 'به‌روزرسانی',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _showResetDialog,
            tooltip: 'پاک کردن آمار',
          ),
        ],
      ),
      body: Consumer<StatisticsService>(
        builder: (context, stats, child) {
          if (!stats.isLoaded) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(stats),
                    const SizedBox(height: 16),
                    _buildStatsGrid(stats),
                    const SizedBox(height: 16),
                    _buildQualityChart(stats),
                    const SizedBox(height: 16),
                    _buildDetailsList(stats),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(StatisticsService stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        child: Column(
          children: [
            const Icon(Icons.bar_chart, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'آمار کلی',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تا ${DateTime.now().toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(StatisticsService stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'تعداد PDF ها',
          value: stats.totalPdfsCreated.toString(),
          icon: Icons.picture_as_pdf,
          color: AppColors.primary,
          gradient: AppColors.primaryGradient,
        ),
        _buildStatCard(
          title: 'تعداد عکس‌ها',
          value: stats.totalImagesProcessed.toString(),
          icon: Icons.photo_library,
          color: AppColors.success,
          gradient: AppColors.successGradient,
        ),
        _buildStatCard(
          title: 'میانگین عکس',
          value: stats.averageImagesPerPdf.toStringAsFixed(1),
          icon: Icons.analytics,
          color: AppColors.warning,
          gradient: AppColors.sunsetGradient,
        ),
        _buildStatCard(
          title: 'حجم کل',
          value: stats.formatFileSize(stats.totalPdfSize),
          icon: Icons.storage,
          color: AppColors.info,
          gradient: AppColors.oceanGradient,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityChart(StatisticsService stats) {
    final qualityData = stats.qualityUsage;
    final total = qualityData.values.fold(0, (a, b) => a + b);

    if (total == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'هنوز آماری ثبت نشده است',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.pie_chart, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'توزیع کیفیت PDF',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildQualityBar(
              'کیفیت پایین',
              qualityData['low'] ?? 0,
              total,
              AppColors.danger,
            ),
            const SizedBox(height: 12),
            _buildQualityBar(
              'کیفیت متوسط',
              qualityData['medium'] ?? 0,
              total,
              AppColors.warning,
            ),
            const SizedBox(height: 12),
            _buildQualityBar(
              'کیفیت بالا',
              qualityData['high'] ?? 0,
              total,
              AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 10,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsList(StatisticsService stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'جزئیات بیشتر',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'آخرین PDF ساخته شده',
              stats.lastPdfCreated != null
                  ? _formatDateTime(stats.lastPdfCreated!)
                  : 'هیچ',
              Icons.access_time,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'میانگین حجم فایل',
              stats.formatFileSize(stats.averagePdfSize.toInt()),
              Icons.file_present,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'محبوب‌ترین کیفیت',
              _getQualityLabel(stats.mostUsedQuality),
              Icons.star,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'میانگین عکس در هر PDF',
              stats.averageImagesPerPdf.toStringAsFixed(1),
              Icons.collections,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryUltraLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} دقیقه پیش';
      }
      return '${difference.inHours} ساعت پیش';
    } else if (difference.inDays == 1) {
      return 'دیروز';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} روز پیش';
    } else {
      return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
    }
  }

  String _getQualityLabel(String quality) {
    switch (quality) {
      case 'low':
        return 'پایین';
      case 'medium':
        return 'متوسط';
      case 'high':
        return 'بالا';
      default:
        return 'نامشخص';
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('پاک کردن آمار'),
          content: const Text(
            'آیا مطمئن هستید که می‌خواهید تمام آمار را پاک کنید؟ این عملیات قابل بازگشت نیست.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<StatisticsService>().resetStatistics();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('آمار با موفقیت پاک شد'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('پاک کردن'),
            ),
          ],
        );
      },
    );
  }
}