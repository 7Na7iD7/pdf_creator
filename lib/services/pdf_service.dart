import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/core_constants.dart';

enum PdfQuality { low, medium, high }
enum PdfPageSize { a4, a5, letter }
enum PdfOrientation { portrait, landscape }

class PdfSettings {
  final PdfQuality quality;
  final PdfPageSize pageSize;
  final PdfOrientation orientation;
  final String fileName;
  final bool addWatermark;
  final bool addPageNumbers;

  const PdfSettings({
    this.quality = PdfQuality.medium,
    this.pageSize = PdfPageSize.a4,
    this.orientation = PdfOrientation.portrait,
    this.fileName = 'my_pdf',
    this.addWatermark = false,
    this.addPageNumbers = false,
  });

  PdfSettings copyWith({
    PdfQuality? quality,
    PdfPageSize? pageSize,
    PdfOrientation? orientation,
    String? fileName,
    bool? addWatermark,
    bool? addPageNumbers,
  }) {
    return PdfSettings(
      quality: quality ?? this.quality,
      pageSize: pageSize ?? this.pageSize,
      orientation: orientation ?? this.orientation,
      fileName: fileName ?? this.fileName,
      addWatermark: addWatermark ?? this.addWatermark,
      addPageNumbers: addPageNumbers ?? this.addPageNumbers,
    );
  }
}

class PdfService extends ChangeNotifier {
  List<File> _selectedImages = [];
  PdfSettings _settings = const PdfSettings();
  bool _isGenerating = false;
  double _progress = 0.0;
  String _currentProcessingFile = '';
  bool _isCancelled = false;

  List<File> get selectedImages => _selectedImages;
  PdfSettings get settings => _settings;
  bool get isGenerating => _isGenerating;
  double get progress => _progress;
  String get currentProcessingFile => _currentProcessingFile;

  void addImages(List<File> images) {
    _selectedImages.addAll(images);
    notifyListeners();
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  void clearImages() {
    _selectedImages.clear();
    notifyListeners();
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final File item = _selectedImages.removeAt(oldIndex);
    _selectedImages.insert(newIndex, item);
    notifyListeners();
  }

  void updateSettings(PdfSettings newSettings) {
    _settings = newSettings;
    _saveSettings();
    notifyListeners();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final quality = PdfQuality.values[
      prefs.getInt(AppConstants.prefKeyPdfQuality) ?? PdfQuality.medium.index
      ];
      final pageSize = PdfPageSize.values[
      prefs.getInt(AppConstants.prefKeyPdfPageSize) ?? PdfPageSize.a4.index
      ];
      final orientation = PdfOrientation.values[
      prefs.getInt(AppConstants.prefKeyPdfOrientation) ?? PdfOrientation.portrait.index
      ];
      final fileName = prefs.getString(AppConstants.prefKeyPdfFileName) ??
          AppConstants.defaultFileName;
      final addWatermark = prefs.getBool('add_watermark') ?? false;
      final addPageNumbers = prefs.getBool('add_page_numbers') ?? false;

      _settings = PdfSettings(
        quality: quality,
        pageSize: pageSize,
        orientation: orientation,
        fileName: fileName,
        addWatermark: addWatermark,
        addPageNumbers: addPageNumbers,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('خطا در بارگذاری تنظیمات: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.prefKeyPdfQuality, _settings.quality.index);
      await prefs.setInt(AppConstants.prefKeyPdfPageSize, _settings.pageSize.index);
      await prefs.setInt(AppConstants.prefKeyPdfOrientation, _settings.orientation.index);
      await prefs.setString(AppConstants.prefKeyPdfFileName, _settings.fileName);
      await prefs.setBool('add_watermark', _settings.addWatermark);
      await prefs.setBool('add_page_numbers', _settings.addPageNumbers);
    } catch (e) {
      debugPrint('خطا در ذخیره تنظیمات: $e');
    }
  }

  Future<String?> generatePdf() async {
    if (_selectedImages.isEmpty) {
      throw Exception('هیچ عکسی انتخاب نشده است');
    }

    _isGenerating = true;
    _isCancelled = false;
    _progress = 0.0;
    notifyListeners();

    try {
      final pdf = pw.Document();
      final pageFormat = _getPageFormat();

      for (int i = 0; i < _selectedImages.length; i++) {
        if (_isCancelled) {
          _resetGenerationState();
          return null;
        }

        final image = _selectedImages[i];
        _currentProcessingFile = image.path.split('/').last;
        _progress = (i + 1) / _selectedImages.length;
        notifyListeners();

        final imageBytes = await _compressImage(image);
        final pdfImage = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            build: (pw.Context context) {
              return pw.Stack(
                children: [
                  pw.Center(
                    child: pw.Image(
                      pdfImage,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                  if (_settings.addPageNumbers)
                    pw.Positioned(
                      bottom: 10,
                      right: 10,
                      child: pw.Text(
                        'صفحه ${i + 1} از ${_selectedImages.length}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                    ),
                  if (_settings.addWatermark)
                    pw.Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: pw.Center(
                        child: pw.Opacity(
                          opacity: 0.3,
                          child: pw.Text(
                            AppConstants.appNamePersian,
                            style: pw.TextStyle(
                              fontSize: 20,
                              color: PdfColors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );

        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (_isCancelled) {
        _resetGenerationState();
        return null;
      }

      final output = await _getOutputFile();
      final pdfBytes = await pdf.save();
      await output.writeAsBytes(pdfBytes);

      _resetGenerationState();
      return output.path;
    } catch (e) {
      debugPrint('خطا در تولید PDF: $e');
      _resetGenerationState();
      rethrow;
    }
  }

  void _resetGenerationState() {
    _isGenerating = false;
    _progress = 0.0;
    _currentProcessingFile = '';
    _isCancelled = false;
    notifyListeners();
  }

  Future<Uint8List> _compressImage(File image) async {
    try {
      final bytes = await image.readAsBytes();

      switch (_settings.quality) {
        case PdfQuality.low:
          return await _resizeImage(bytes, 0.3);
        case PdfQuality.medium:
          return await _resizeImage(bytes, 0.6);
        case PdfQuality.high:
          return bytes;
      }
    } catch (e) {
      debugPrint('خطا در فشرده‌سازی تصویر: $e');
      return await image.readAsBytes();
    }
  }

  Future<Uint8List> _resizeImage(Uint8List bytes, double quality) async {
    try {
      final targetWidth = (AppConstants.imageResizeBaseWidth * quality).round();

      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidth,
      );
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return data!.buffer.asUint8List();
    } catch (e) {
      debugPrint('خطا در تغییر اندازه تصویر: $e');
      return bytes;
    }
  }

  PdfPageFormat _getPageFormat() {
    PdfPageFormat baseFormat;

    switch (_settings.pageSize) {
      case PdfPageSize.a4:
        baseFormat = PdfPageFormat.a4;
        break;
      case PdfPageSize.a5:
        baseFormat = PdfPageFormat.a5;
        break;
      case PdfPageSize.letter:
        baseFormat = PdfPageFormat.letter;
        break;
    }

    if (_settings.orientation == PdfOrientation.landscape) {
      return baseFormat.landscape;
    }

    return baseFormat;
  }

  Future<File> _getOutputFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${_settings.fileName}_$timestamp.pdf';
    return File('${directory.path}/$fileName');
  }

  void cancelGeneration() {
    _isCancelled = true;
    _resetGenerationState();
  }

  Future<int> estimatePdfSize() async {
    if (_selectedImages.isEmpty) return 0;

    int totalSize = 0;
    for (final image in _selectedImages) {
      try {
        final compressed = await _compressImage(image);
        totalSize += compressed.length;
      } catch (e) {
        debugPrint('خطا در محاسبه حجم: $e');
      }
    }
    return totalSize;
  }

  Future<Uint8List?> generateThumbnail(int index) async {
    if (index < 0 || index >= _selectedImages.length) return null;

    try {
      final image = _selectedImages[index];
      final bytes = await image.readAsBytes();
      return await _resizeImage(bytes, 0.2);
    } catch (e) {
      debugPrint('خطا در تولید thumbnail: $e');
      return null;
    }
  }

  Future<List<int>> validateImages() async {
    List<int> invalidIndices = [];

    for (int i = 0; i < _selectedImages.length; i++) {
      try {
        final exists = await _selectedImages[i].exists();
        if (!exists) {
          invalidIndices.add(i);
        }
      } catch (e) {
        invalidIndices.add(i);
      }
    }

    return invalidIndices;
  }

  Future<void> removeInvalidImages() async {
    final invalidIndices = await validateImages();
    for (int i = invalidIndices.length - 1; i >= 0; i--) {
      removeImage(invalidIndices[i]);
    }
  }
}

extension PdfQualityExtension on PdfQuality {
  String get displayName {
    switch (this) {
      case PdfQuality.low:
        return 'کیفیت پایین';
      case PdfQuality.medium:
        return 'کیفیت متوسط';
      case PdfQuality.high:
        return 'کیفیت بالا';
    }
  }

  String get description {
    switch (this) {
      case PdfQuality.low:
        return 'فایل کوچک‌تر، کیفیت پایین‌تر';
      case PdfQuality.medium:
        return 'تعادل بین کیفیت و حجم';
      case PdfQuality.high:
        return 'بهترین کیفیت، حجم بیشتر';
    }
  }
}

extension PdfPageSizeExtension on PdfPageSize {
  String get displayName {
    switch (this) {
      case PdfPageSize.a4:
        return 'A4';
      case PdfPageSize.a5:
        return 'A5';
      case PdfPageSize.letter:
        return 'Letter';
    }
  }

  String get dimensions {
    switch (this) {
      case PdfPageSize.a4:
        return '210 × 297 میلی‌متر';
      case PdfPageSize.a5:
        return '148 × 210 میلی‌متر';
      case PdfPageSize.letter:
        return '8.5 × 11 اینچ';
    }
  }
}

extension PdfOrientationExtension on PdfOrientation {
  String get displayName {
    switch (this) {
      case PdfOrientation.portrait:
        return 'عمودی';
      case PdfOrientation.landscape:
        return 'افقی';
    }
  }

  String get description {
    switch (this) {
      case PdfOrientation.portrait:
        return 'مناسب برای عکس‌های عمودی';
      case PdfOrientation.landscape:
        return 'مناسب برای عکس‌های افقی';
    }
  }
}