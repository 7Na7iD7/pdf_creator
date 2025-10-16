import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsService extends ChangeNotifier {
  static const String _keyTotalPdfs = 'total_pdfs_created';
  static const String _keyTotalImages = 'total_images_processed';
  static const String _keyLastCreated = 'last_pdf_created';
  static const String _keyTotalSize = 'total_pdf_size';

  int _totalPdfsCreated = 0;
  int _totalImagesProcessed = 0;
  DateTime? _lastPdfCreated;
  int _totalPdfSize = 0;
  Map<String, int> _qualityUsage = {
    'low': 0,
    'medium': 0,
    'high': 0,
  };

  bool _isLoaded = false;

  // Getters
  int get totalPdfsCreated => _totalPdfsCreated;
  int get totalImagesProcessed => _totalImagesProcessed;
  DateTime? get lastPdfCreated => _lastPdfCreated;
  int get totalPdfSize => _totalPdfSize;
  Map<String, int> get qualityUsage => Map.unmodifiable(_qualityUsage);
  bool get isLoaded => _isLoaded;

  Future<void> loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _totalPdfsCreated = prefs.getInt(_keyTotalPdfs) ?? 0;
      _totalImagesProcessed = prefs.getInt(_keyTotalImages) ?? 0;
      _totalPdfSize = prefs.getInt(_keyTotalSize) ?? 0;

      final lastCreatedTimestamp = prefs.getInt(_keyLastCreated);
      if (lastCreatedTimestamp != null) {
        _lastPdfCreated = DateTime.fromMillisecondsSinceEpoch(lastCreatedTimestamp);
      }

      _qualityUsage = {
        'low': prefs.getInt('quality_low') ?? 0,
        'medium': prefs.getInt('quality_medium') ?? 0,
        'high': prefs.getInt('quality_high') ?? 0,
      };

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در بارگذاری آمار: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> recordPdfCreation({
    required int imageCount,
    required int fileSize,
    required String quality,
  }) async {
    try {
      _totalPdfsCreated++;
      _totalImagesProcessed += imageCount;
      _totalPdfSize += fileSize;
      _lastPdfCreated = DateTime.now();

      final normalizedQuality = quality.toLowerCase();
      if (_qualityUsage.containsKey(normalizedQuality)) {
        _qualityUsage[normalizedQuality] = (_qualityUsage[normalizedQuality] ?? 0) + 1;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyTotalPdfs, _totalPdfsCreated);
      await prefs.setInt(_keyTotalImages, _totalImagesProcessed);
      await prefs.setInt(_keyTotalSize, _totalPdfSize);
      await prefs.setInt(_keyLastCreated, _lastPdfCreated!.millisecondsSinceEpoch);

      await prefs.setInt('quality_low', _qualityUsage['low'] ?? 0);
      await prefs.setInt('quality_medium', _qualityUsage['medium'] ?? 0);
      await prefs.setInt('quality_high', _qualityUsage['high'] ?? 0);

      notifyListeners();
    } catch (e) {
      debugPrint('خطا در ثبت آمار: $e');
    }
  }

  Future<void> resetStatistics() async {
    try {
      _totalPdfsCreated = 0;
      _totalImagesProcessed = 0;
      _totalPdfSize = 0;
      _lastPdfCreated = null;
      _qualityUsage = {'low': 0, 'medium': 0, 'high': 0};

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyTotalPdfs);
      await prefs.remove(_keyTotalImages);
      await prefs.remove(_keyTotalSize);
      await prefs.remove(_keyLastCreated);
      await prefs.remove('quality_low');
      await prefs.remove('quality_medium');
      await prefs.remove('quality_high');

      notifyListeners();
    } catch (e) {
      debugPrint('خطا در ریست آمار: $e');
    }
  }

  double get averageImagesPerPdf {
    if (_totalPdfsCreated == 0) return 0;
    return _totalImagesProcessed / _totalPdfsCreated;
  }

  double get averagePdfSize {
    if (_totalPdfsCreated == 0) return 0;
    return _totalPdfSize / _totalPdfsCreated;
  }

  String get mostUsedQuality {
    if (_qualityUsage.isEmpty || _qualityUsage.values.every((v) => v == 0)) {
      return 'medium';
    }

    String mostUsed = 'medium';
    int maxCount = 0;

    _qualityUsage.forEach((quality, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsed = quality;
      }
    });

    return mostUsed;
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  Map<String, dynamic> getFullReport() {
    return {
      'totalPdfs': _totalPdfsCreated,
      'totalImages': _totalImagesProcessed,
      'totalSize': formatFileSize(_totalPdfSize),
      'averageImages': averageImagesPerPdf.toStringAsFixed(1),
      'averageSize': formatFileSize(averagePdfSize.toInt()),
      'mostUsedQuality': mostUsedQuality,
      'lastCreated': _lastPdfCreated?.toString() ?? 'هیچ',
      'qualityBreakdown': _qualityUsage,
    };
  }
}