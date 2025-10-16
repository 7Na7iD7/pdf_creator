import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'PDF Creator Pro';
  static const String appNamePersian = 'سازنده PDF حرفه‌ای';
  static const String appTitle = 'تبدیل عکس به PDF';
  static const String appVersion = '2.0.0';
  static const String appBuildNumber = '1';
  static const String appDescription = 'تبدیل عکس به PDF با امکانات پیشرفته';
  static const String developerName = 'Flutter Team';
  static const String developerEmail = 'info@pdfcreator.app';

  static const String githubUrl = 'https://github.com/yourapp/pdf-creator';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.yourapp.pdfcreator';
  static const String appStoreUrl = 'https://apps.apple.com/app/pdf-creator-pro/id123456789';
  static const String websiteUrl = 'https://pdfcreator.app';
  static const String supportEmail = 'support@pdfcreator.app';
  static const String privacyPolicyUrl = 'https://pdfcreator.app/privacy';
  static const String termsOfServiceUrl = 'https://pdfcreator.app/terms';
  static const String helpUrl = 'https://pdfcreator.app/help';
  static const String feedbackUrl = 'https://pdfcreator.app/feedback';

  static const String fontVazirmatn = 'Vazirmatn';

  static const String soundSuccess = 'assets/sounds/success.mp3';
  static const String soundError = 'assets/sounds/error.mp3';
  static const String soundClick = 'assets/sounds/click.mp3';

  static const String logoPath = 'assets/images/logo.png';
  static const String splashPath = 'assets/images/splash.png';
  static const String emptyStatePath = 'assets/images/empty_state.svg';

  static const String documentsFolder = 'PDF_Creator';
  static const String tempFolder = 'temp';
  static const String cacheFolder = 'cache';
  static const String defaultFileName = 'my_pdf';
  static const String backupFolder = 'backups';

  static const int maxImagesCount = 100;
  static const int minImagesCount = 1;
  static const int defaultImagePickerQuality = 85;
  static const int imageResizeBaseWidth = 1024;
  static const int thumbnailSize = 200;

  static const int maxImageSize = 10 * 1024 * 1024; // 10 MB
  static const int maxPdfSize = 50 * 1024 * 1024; // 50 MB

  static const Map<String, double> compressionQualities = {
    'low': 0.3,
    'medium': 0.6,
    'high': 1.0,
  };


  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration veryLongAnimation = Duration(milliseconds: 800);

  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration toastDuration = Duration(seconds: 2);
  static const Duration splashDuration = Duration(seconds: 3);

  // border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusCircle = 100.0;

  // padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // iconSize
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // fonts
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeading = 28.0;

  // elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;

  // SharedPreferences Keys
  static const String prefKeyPdfQuality = 'pdf_quality';
  static const String prefKeyPdfPageSize = 'pdf_page_size';
  static const String prefKeyPdfOrientation = 'pdf_orientation';
  static const String prefKeyPdfFileName = 'pdf_file_name';
  static const String prefKeyTheme = 'app_theme';
  static const String prefKeyLanguage = 'app_language';
  static const String prefKeyFirstRun = 'is_first_run';
  static const String prefKeyOnboardingCompleted = 'onboarding_completed';
  static const String prefKeyNotificationsEnabled = 'notifications_enabled';
  static const String prefKeyAutoBackup = 'auto_backup';
  static const String prefKeyAnimationsEnabled = 'animations_enabled';

  // Hero Tags
  static const String heroTagImagePrefix = 'image_';
  static const String heroTagLogo = 'logo';
  static const String heroTagFab = 'fab';

  // Route Names
  static const String routeHome = '/home';
  static const String routeSettings = '/settings';
  static const String routePreview = '/preview';
  static const String routeStatistics = '/statistics';
  static const String routeAbout = '/about';
  static const String routeHelp = '/help';

  static const List<Locale> supportedLocales = [
    Locale('fa', 'IR'),
    Locale('en', 'US'),
    Locale('ar', 'SA'),
  ];

  static const Locale defaultLocale = Locale('fa', 'IR');

  static const List<String> requiredPermissions = [
    'photos',
    'storage',
    'camera',
  ];

  static const int maxStatisticsHistory = 100;
  static const int statisticsRetentionDays = 365;

  static const String notificationChannelId = 'pdf_creator_channel';
  static const String notificationChannelName = 'PDF Creator Notifications';
  static const String notificationChannelDescription = 'Notifications for PDF generation';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  static const int cacheMaxSize = 100 * 1024 * 1024; // 100 MB
  static const Duration cacheDuration = Duration(days: 7);

  static const Map<String, int> achievements = {
    'first_pdf': 1,
    'pdf_master_10': 10,
    'pdf_master_50': 50,
    'pdf_master_100': 100,
    'quality_explorer': 3,
    'batch_processor': 20,
  };

  static const double minScreenWidth = 320.0;
  static const double minScreenHeight = 568.0;
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1024.0;

  static const bool useMaterial3 = true;
  static const bool useSystemTheme = false;

  static const bool enableDebugMode = kDebugMode;
  static const bool enableLogging = kDebugMode;
  static const bool enableAnalytics = !kDebugMode;
  static const bool enableCrashReporting = !kDebugMode;

  static const String errorGeneric = 'خطایی رخ داده است';
  static const String errorNetwork = 'خطا در اتصال به اینترنت';
  static const String errorPermission = 'مجوز لازم داده نشده است';
  static const String errorFileNotFound = 'فایل یافت نشد';
  static const String errorInvalidFile = 'فایل نامعتبر است';
  static const String errorMaxImages = 'تعداد عکس‌ها بیش از حد مجاز است';
  static const String errorNoImages = 'هیچ عکسی انتخاب نشده است';

  static const String successPdfCreated = 'PDF با موفقیت ایجاد شد';
  static const String successImageAdded = 'عکس اضافه شد';
  static const String successImageRemoved = 'عکس حذف شد';
  static const String successSettingsSaved = 'تنظیمات ذخیره شد';

  static const List<String> tips = [
    'برای بهترین کیفیت، از تصاویر با وضوح بالا استفاده کنید',
    'می‌توانید ترتیب عکس‌ها را با کشیدن و رها کردن تغییر دهید',
    'برای ذخیره فضا، از کیفیت متوسط استفاده کنید',
    'می‌توانید شماره صفحه و واترمارک اضافه کنید',
    'تنظیمات شما به طور خودکار ذخیره می‌شوند',
  ];

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static bool isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < minScreenWidth || size.height < minScreenHeight;
  }

  static double getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) return paddingXLarge;
    if (isTablet(context)) return paddingLarge;
    return paddingMedium;
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) return baseSize * 1.2;
    if (isTablet(context)) return baseSize * 1.1;
    return baseSize;
  }

  static String formatPersianDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  static String formatPersianTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String getRandomTip() {
    return tips[DateTime.now().millisecond % tips.length];
  }
}