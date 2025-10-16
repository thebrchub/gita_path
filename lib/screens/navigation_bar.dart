import 'package:flutter/material.dart';
import 'dart:math';
import 'homescreen.dart';
import 'chapterlistscreen.dart';
import 'askkrishnascreen.dart';
import 'donationscreen.dart';
import '../widgets/app_drawer.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List of screens for bottom navigation
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const ChapterListScreen(),
      const AskKrishnaScreen(),
      const DonationScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      // 🔥 ENABLE DRAWER SWIPE GESTURE with wide edge area
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: min(MediaQuery.of(context).size.width * 0.7, 360),
      
      // 🔥 APP BAR with menu button (only on Home screen)
      appBar: _currentIndex == 0 
          ? PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 0,
              ),
            )
          : null,
      
      body: Stack(
        children: [
          // Main content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          
          // 🔥 MENU BUTTON overlay (only on home screen)
          if (_currentIndex == 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 12,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.menu,
                      color: Colors.deepOrange.shade700,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      
      // 🔥 BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              const Color(0xFFFFF5E6).withOpacity(0.97),
              const Color(0xFFFFE4CC).withOpacity(0.97),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.shade200.withOpacity(0.22),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            // slightly smaller height so items fit on narrow screens
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Study',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.psychology_rounded,
                  label: 'Ask Krishna',
                  index: 2,
                  isPremium: true,
                ),
                _buildNavItem(
                  icon: Icons.volunteer_activism_rounded,
                  label: 'Donate',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool isPremium = false,
  }) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.white.withOpacity(0.8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(
                    color: Colors.white.withOpacity(0.6),
                    width: 1.5,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.orange.shade200.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? Colors.deepOrange.shade700
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                  if (isPremium && !isSelected)
                    Positioned(
                      right: -4,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.deepOrange.shade700
                      : Colors.grey.shade600,
                  letterSpacing: 0.15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}