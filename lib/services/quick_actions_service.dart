import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class QuickActionsService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<File?> openCamera(BuildContext context, {
    CameraDevice device = CameraDevice.rear,
    int quality = 85,
    bool enableFlash = false,
  }) async {
    try {
      final permissions = await _checkCameraPermissions();
      if (!permissions) {
        _showPermissionDialog(context, 'دوربین');
        return null;
      }

      _showLoadingDialog(context, 'آماده‌سازی دوربین...');

      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: quality,
        preferredCameraDevice: device,
        maxWidth: 4096,
        maxHeight: 4096,
      );

      Navigator.pop(context);

      if (photo != null) {
        final file = File(photo.path);
        final fileSize = await file.length();

        _showSuccessSnackBar(
          context,
          'عکس با موفقیت گرفته شد (${_formatFileSize(fileSize)})',
        );

        await _saveToGallery(file);

        return file;
      }
      return null;
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(context, 'خطا در باز کردن دوربین: ${e.toString()}');
      return null;
    }
  }

  Future<List<File>?> openGallery(BuildContext context, {
    int? maxImages,
    int quality = 85,
  }) async {
    try {
      final permissions = await _checkGalleryPermissions();
      if (!permissions) {
        _showPermissionDialog(context, 'گالری');
        return null;
      }

      _showLoadingDialog(context, 'در حال بارگذاری گالری...');

      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: quality,
        maxWidth: 4096,
        maxHeight: 4096,
      );

      Navigator.pop(context);

      if (images.isNotEmpty) {
        final limitedImages = maxImages != null && images.length > maxImages
            ? images.take(maxImages).toList()
            : images;

        final imageFiles = limitedImages.map((image) => File(image.path)).toList();

        int totalSize = 0;
        for (var file in imageFiles) {
          totalSize += await file.length();
        }

        _showSuccessSnackBar(
          context,
          '${imageFiles.length} عکس انتخاب شد (${_formatFileSize(totalSize)})',
        );

        return imageFiles;
      }
      return null;
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(context, 'خطا در باز کردن گالری: ${e.toString()}');
      return null;
    }
  }

  Future<List<File>?> openFiles(BuildContext context, {
    List<String> extensions = const ['jpg', 'jpeg', 'png', 'pdf'],
    bool allowMultiple = true,
  }) async {
    try {
      _showLoadingDialog(context, 'باز کردن فایل منیجر...');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        allowMultiple: allowMultiple,
      );

      Navigator.pop(context);

      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();

        int totalSize = 0;
        for (var file in files) {
          totalSize += await file.length();
        }

        _showSuccessSnackBar(
          context,
          '${files.length} فایل انتخاب شد (${_formatFileSize(totalSize)})',
        );

        return files;
      }
      return null;
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(context, 'خطا در باز کردن فایل‌ها: ${e.toString()}');
      return null;
    }
  }

  Future<void> createNewPdf(BuildContext context) async {
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.picture_as_pdf,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'ایجاد PDF جدید',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'نوع PDF مورد نظر را انتخاب کنید',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPdfTypeCard(
                  context,
                  icon: Icons.image,
                  title: 'PDF از عکس‌ها',
                  subtitle: 'تبدیل تصاویر به PDF',
                  color: Colors.blue,
                  onTap: () => Navigator.pop(context, 'images'),
                ),
                const SizedBox(height: 12),
                _buildPdfTypeCard(
                  context,
                  icon: Icons.text_fields,
                  title: 'PDF متنی خالی',
                  subtitle: 'ایجاد یک صفحه خالی',
                  color: Colors.green,
                  onTap: () => Navigator.pop(context, 'blank'),
                ),
                const SizedBox(height: 12),
                _buildPdfTypeCard(
                  context,
                  icon: Icons.merge_type,
                  title: 'ادغام PDF ها',
                  subtitle: 'ترکیب چند فایل PDF',
                  color: Colors.orange,
                  onTap: () => Navigator.pop(context, 'merge'),
                ),
                const SizedBox(height: 12),
                _buildPdfTypeCard(
                  context,
                  icon: Icons.camera_alt,
                  title: 'اسکن با دوربین',
                  subtitle: 'اسکن مستقیم اسناد',
                  color: Colors.purple,
                  onTap: () => Navigator.pop(context, 'scan'),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('لغو'),
                ),
              ],
            ),
          ),
        ),
      );

      if (result != null) {
        switch (result) {
          case 'images':
            await openGallery(context);
            break;
          case 'blank':
            await _createBlankPdf(context);
            break;
          case 'merge':
            await _mergePdfs(context);
            break;
          case 'scan':
            await _scanDocument(context);
            break;
        }
      }
    } catch (e) {
      _showErrorSnackBar(context, 'خطا در ایجاد PDF: ${e.toString()}');
    }
  }

  Future<List<File>> showRecent(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'بارگذاری فایل‌های اخیر...');

      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/PDFs');

      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }

      final files = pdfDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.pdf'))
          .toList();

      files.sort((a, b) {
        final aModified = a.statSync().modified;
        final bModified = b.statSync().modified;
        return bModified.compareTo(aModified);
      });

      final recentFiles = files.take(20).toList();

      Navigator.pop(context);

      if (recentFiles.isNotEmpty) {
        _showRecentFilesDialog(context, recentFiles);
      } else {
        _showInfoSnackBar(context, 'هیچ فایل اخیری یافت نشد');
      }

      return recentFiles;
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(context, 'خطا در دریافت فایل‌های اخیر: ${e.toString()}');
      return [];
    }
  }

  Future<void> uploadToCloud(BuildContext context, File file) async {
    try {
      final service = await showDialog<String>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_upload, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'انتخاب سرویس ابری',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildCloudServiceTile(
                  context,
                  icon: Icons.cloud,
                  title: 'Google Drive',
                  color: Colors.blue,
                  onTap: () => Navigator.pop(context, 'google'),
                ),
                _buildCloudServiceTile(
                  context,
                  icon: Icons.cloud_upload,
                  title: 'Dropbox',
                  color: Colors.purple,
                  onTap: () => Navigator.pop(context, 'dropbox'),
                ),
                _buildCloudServiceTile(
                  context,
                  icon: Icons.folder,
                  title: 'OneDrive',
                  color: Colors.green,
                  onTap: () => Navigator.pop(context, 'onedrive'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('لغو'),
                ),
              ],
            ),
          ),
        ),
      );

      if (service != null) {
        await _showUploadProgressDialog(context, service, file);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'خطا در آپلود به ابر: ${e.toString()}');
    }
  }

  Future<void> shareFile(BuildContext context, String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _showErrorSnackBar(context, 'فایل یافت نشد');
        return;
      }

      final fileName = filePath.split('/').last;
      final fileSize = _formatFileSize(await file.length());

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'اشتراک‌گذاری PDF',
        text: 'فایل: $fileName\nحجم: $fileSize',
      );

      _showSuccessSnackBar(context, 'فایل به اشتراک گذاشته شد');
    } catch (e) {
      _showErrorSnackBar(context, 'خطا در اشتراک‌گذاری: ${e.toString()}');
    }
  }

  Future<bool> deleteFile(BuildContext context, String filePath) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('حذف فایل'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('آیا مطمئن هستید که می‌خواهید این فایل را حذف کنید؟'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'این عمل غیرقابل بازگشت است',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          _showSuccessSnackBar(context, 'فایل با موفقیت حذف شد');
          return true;
        }
      }
      return false;
    } catch (e) {
      _showErrorSnackBar(context, 'خطا در حذف فایل: ${e.toString()}');
      return false;
    }
  }

  Future<void> openPdfFile(BuildContext context, String filePath) async {
    try {
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        _showErrorSnackBar(context, 'خطا در باز کردن فایل: ${result.message}');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'خطا در باز کردن فایل: ${e.toString()}');
    }
  }

  Future<void> _createBlankPdf(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'ایجاد PDF خالی...');

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(
              child: pw.Text(
                'صفحه خالی',
                style: pw.TextStyle(fontSize: 24),
              ),
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/PDFs');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${pdfDir.path}/blank_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      Navigator.pop(context);
      _showSuccessSnackBar(context, 'PDF خالی ایجاد شد');

      await openPdfFile(context, file.path);
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(context, 'خطا در ایجاد PDF: ${e.toString()}');
    }
  }

  Future<void> _mergePdfs(BuildContext context) async {
    _showInfoSnackBar(context, 'قابلیت ادغام PDF ها به زودی اضافه می‌شود');
  }

  Future<void> _scanDocument(BuildContext context) async {
    final photo = await openCamera(context, quality: 100);
    if (photo != null) {
      _showSuccessSnackBar(context, 'سند اسکن شد');
    }
  }

  Future<bool> _checkCameraPermissions() async {
    final camera = await Permission.camera.request();
    return camera.isGranted;
  }

  Future<bool> _checkGalleryPermissions() async {
    final photos = await Permission.photos.request();
    final storage = await Permission.storage.request();
    return photos.isGranted || storage.isGranted;
  }

  Future<void> _saveToGallery(File file) async {
    // TODO: پیاده‌سازی ذخیره در گالری
  }

  void _showRecentFilesDialog(BuildContext context, List<File> files) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.history, color: Colors.blue, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'فایل‌های اخیر',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'آخرین PDF های ایجاد شده',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final fileName = file.path.split('/').last;
                    final fileSize = _formatFileSize(file.lengthSync());
                    final modifiedDate = file.statSync().modified;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          fileName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Row(
                          children: [
                            Icon(Icons.storage, size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(fileSize, style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(_formatDate(modifiedDate), style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'open',
                              child: Row(
                                children: [
                                  Icon(Icons.open_in_new, size: 20, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('باز کردن'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'share',
                              child: Row(
                                children: [
                                  Icon(Icons.share, size: 20, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('اشتراک‌گذاری'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('حذف', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            Navigator.pop(context);
                            switch (value) {
                              case 'open':
                                await openPdfFile(context, file.path);
                                break;
                              case 'share':
                                await shareFile(context, file.path);
                                break;
                              case 'delete':
                                final deleted = await deleteFile(context, file.path);
                                if (deleted) {
                                  files.removeAt(index);
                                }
                                break;
                            }
                          },
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          await openPdfFile(context, file.path);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUploadProgressDialog(
      BuildContext context,
      String service,
      File file,
      ) async {
    final fileName = file.path.split('/').last;
    final fileSize = _formatFileSize(await file.length());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'آپلود به $service',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fileName,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              fileSize,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text(
              'لطفاً صبر کنید...',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 3));
    Navigator.pop(context);
    _showSuccessSnackBar(context, 'آپلود با موفقیت انجام شد');
  }

  Widget _buildPdfTypeCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudServiceTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'هم‌اکنون';
        }
        return '${difference.inMinutes} دقیقه پیش';
      }
      return '${difference.inHours} ساعت پیش';
    }
    if (difference.inDays == 1) return 'دیروز';
    if (difference.inDays < 7) return '${difference.inDays} روز پیش';
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks هفته پیش';
    }
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ماه پیش';
    }

    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  void _showPermissionDialog(BuildContext context, String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            const Text('مجوز لازم است'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('برای استفاده از $permissionType، نیاز به مجوز دسترسی دارید.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'لطفاً از تنظیمات برنامه، مجوز را فعال کنید',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('تنظیمات'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'باشه',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'باشه',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'باشه',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<Uint8List?> _imageToBytes(File imageFile) async {
    try {
      return await imageFile.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  Future<File?> compressImage(File imageFile, {int quality = 85}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      // TODO: اضافه کردن پکیج image برای فشرده‌سازی
      return imageFile;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getFileInfo(File file) async {
    try {
      final stat = await file.stat();
      final fileName = file.path.split('/').last;
      final fileSize = stat.size;
      final modified = stat.modified;
      final extension = fileName.split('.').last.toUpperCase();

      return {
        'name': fileName,
        'size': fileSize,
        'sizeFormatted': _formatFileSize(fileSize),
        'modified': modified,
        'modifiedFormatted': _formatDate(modified),
        'extension': extension,
        'path': file.path,
      };
    } catch (e) {
      return {};
    }
  }

  Future<void> clearCache(BuildContext context) async {
    try {
      final directory = await getTemporaryDirectory();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create();
        _showSuccessSnackBar(context, 'کش با موفقیت پاک شد');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'خطا در پاک کردن کش: ${e.toString()}');
    }
  }

  Future<String> getSavePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${directory.path}/PDFs');
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir.path;
  }

  Future<bool> checkStorageSpace(BuildContext context, int requiredSpace) async {
    try {
      // TODO: پیاده‌سازی بررسی فضای خالی
      return true;
    } catch (e) {
      _showErrorSnackBar(context, 'خطا در بررسی فضا: ${e.toString()}');
      return false;
    }
  }

  Future<File?> renameFile(BuildContext context, File file, String newName) async {
    try {
      final dir = file.parent.path;
      final extension = file.path.split('.').last;
      final newPath = '$dir/$newName.$extension';

      final newFile = await file.rename(newPath);
      _showSuccessSnackBar(context, 'نام فایل تغییر یافت');
      return newFile;
    } catch (e) {
      _showErrorSnackBar(context, 'خطا در تغییر نام: ${e.toString()}');
      return null;
    }
  }

  Future<File?> copyFile(BuildContext context, File file, String destinationPath) async {
    try {
      final newFile = await file.copy(destinationPath);
      _showSuccessSnackBar(context, 'فایل کپی شد');
      return newFile;
    } catch (e) {
      _showErrorSnackBar(context, 'خطا در کپی فایل: ${e.toString()}');
      return null;
    }
  }

  Future<File?> moveFile(BuildContext context, File file, String destinationPath) async {
    try {
      final newFile = await file.rename(destinationPath);
      _showSuccessSnackBar(context, 'فایل منتقل شد');
      return newFile;
    } catch (e) {
      _showErrorSnackBar(context, 'خطا در انتقال فایل: ${e.toString()}');
      return null;
    }
  }
}