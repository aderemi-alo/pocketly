import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class ScaffoldWithNestedNavigation extends StatefulWidget {
  const ScaffoldWithNestedNavigation({Key? key, required this.navigationShell})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNestedNavigation'));

  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNestedNavigation> createState() =>
      _ScaffoldWithNestedNavigationState();
}

class _ScaffoldWithNestedNavigationState
    extends State<ScaffoldWithNestedNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _currentPageAnimation;
  late Animation<Offset> _nextPageAnimation;
  int _currentIndex = 0;
  int _nextIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.navigationShell.currentIndex;
    _nextIndex = widget.navigationShell.currentIndex;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _setupAnimations();
  }

  void _setupAnimations() {
    final isMovingRight = _nextIndex > _currentIndex;

    // Current page slides out completely
    _currentPageAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: isMovingRight ? const Offset(-1.5, 0.0) : const Offset(1.5, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    // Next page slides in from completely off-screen
    _nextPageAnimation =
        Tween<Offset>(
          begin: isMovingRight
              ? const Offset(1.5, 0.0)
              : const Offset(-1.5, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _goBranch(int index) {
    if (_isAnimating || index == widget.navigationShell.currentIndex) return;

    setState(() {
      _isAnimating = true;
      _currentIndex = widget.navigationShell.currentIndex;
      _nextIndex = index;
    });

    _setupAnimations();

    // Start the carousel animation
    _animationController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _currentIndex = index;
        });
        _animationController.reset();
      }
    });

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Widget _buildCarouselBody() {
    if (_isAnimating) {
      return Stack(
        children: [
          // Current page sliding out
          SlideTransition(
            position: _currentPageAnimation,
            child: _buildPageContent(_currentIndex),
          ),
          // Next page sliding in
          SlideTransition(
            position: _nextPageAnimation,
            child: _buildPageContent(_nextIndex),
          ),
        ],
      );
    }

    return widget.navigationShell;
  }

  Widget _buildAnimatedTitle(TextTheme textTheme) {
    return _buildTitleText(widget.navigationShell.currentIndex, textTheme);
  }

  Widget _buildTitleText(int index, TextTheme textTheme) {
    final title = _getPageTitle(index);
    return Text(title, style: textTheme.titleLarge);
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Expenses';
      case 2:
        return 'Settings';
      default:
        return 'Pocketly';
    }
  }

  Widget _buildPageContent(int index) {
    // Create individual page content for each tab without app bars
    switch (index) {
      case 0:
        return const DashboardView();
      case 1:
        return const ExpensesView();
      case 2:
        return const SettingsView();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // appBar: _buildAnimatedAppBar(),
      appBar: AppBar(title: _buildAnimatedTitle(Theme.of(context).textTheme)),
      body: _buildCarouselBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _goBranch,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutDashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.receipt),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
