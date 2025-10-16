import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/core_constants.dart';
import '../providers/theme_provider.dart';
import '../services/pdf_service.dart';
import '../services/statistics_service.dart';
import '../services/quick_actions_service.dart';
import 'home_page.dart';
import 'statistics_page.dart';
import 'settings_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late AnimationController _bottomNavAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _bottomNavSlideAnimation;

  final QuickActionsService _quickActionsService = QuickActionsService();

  final List<Widget> _pages = const [
    HomePage(),
    StatisticsPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _initAnimations();
    _loadServices();
  }

  void _loadServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsService>().loadStatistics();
    });
  }

  void _initAnimations() {
    _fabAnimationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _bottomNavAnimationController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _bottomNavSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _bottomNavAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _fabAnimationController.forward();
    _bottomNavAnimationController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _fabAnimationController.dispose();
    _bottomNavAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fabAnimationController.forward(from: 0);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _fabAnimationController.forward(from: 0);
    HapticFeedback.lightImpact();
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: AppConstants.mediumAnimation,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBottomNavigationBar() {
    return SlideTransition(
      position: _bottomNavSlideAnimation,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: AppColors.primary.withOpacity(0.1),
          elevation: 0,
          destinations: [
            _buildNavDestination(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'خانه',
            ),
            _buildNavDestination(
              icon: Icons.bar_chart_outlined,
              selectedIcon: Icons.bar_chart,
              label: 'آمار',
            ),
            _buildNavDestination(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              label: 'تنظیمات',
            ),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon, color: AppColors.primary),
      label: label,
    );
  }

  Widget _buildFloatingActionButton() {
    if (_currentIndex != 0) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: () => _showQuickActions(context),
            backgroundColor: AppColors.primary,
            elevation: 8,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'عملیات سریع',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuickActionsSheet(
        quickActionsService: _quickActionsService,
      ),
    );
  }
}

class QuickActionsSheet extends StatelessWidget {
  final QuickActionsService quickActionsService;

  const QuickActionsSheet({
    super.key,
    required this.quickActionsService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXLarge),
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'عملیات سریع',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildQuickActionButton(
                  context,
                  icon: Icons.camera_alt,
                  label: 'دوربین',
                  gradient: AppColors.primaryGradient,
                  onTap: () async {
                    Navigator.pop(context);
                    final photo = await quickActionsService.openCamera(context);
                    if (photo != null && context.mounted) {
                      context.read<PdfService>().addImages([photo]);
                    }
                  },
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.photo_library,
                  label: 'گالری',
                  gradient: AppColors.successGradient,
                  onTap: () async {
                    Navigator.pop(context);
                    final images = await quickActionsService.openGallery(context);
                    if (images != null && images.isNotEmpty && context.mounted) {
                      context.read<PdfService>().addImages(images);
                    }
                  },
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.insert_drive_file,
                  label: 'فایل‌ها',
                  gradient: AppColors.sunsetGradient,
                  onTap: () async {
                    Navigator.pop(context);
                    await quickActionsService.openFiles(context);
                  },
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.picture_as_pdf,
                  label: 'PDF جدید',
                  gradient: AppColors.oceanGradient,
                  onTap: () async {
                    Navigator.pop(context);
                    await quickActionsService.createNewPdf(context);
                  },
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.history,
                  label: 'اخیر',
                  gradient: AppColors.fireGradient,
                  onTap: () async {
                    Navigator.pop(context);
                    await quickActionsService.showRecent(context);
                  },
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.cleaning_services,
                  label: 'پاک کردن',
                  gradient: AppColors.galaxyGradient,
                  onTap: () async {
                    Navigator.pop(context);
                    final confirmed = await _showClearConfirmDialog(context);
                    if (confirmed == true && context.mounted) {
                      context.read<PdfService>().clearImages();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('لیست عکس‌ها پاک شد'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Gradient gradient,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showClearConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 12),
            Text('پاک کردن لیست'),
          ],
        ),
        content: const Text('آیا مطمئن هستید که می‌خواهید تمام عکس‌های انتخاب شده را پاک کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('پاک کردن'),
          ),
        ],
      ),
    );
  }
}