import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/player_controller.dart';
import '../../controllers/theme_controller.dart';
import '../widgets/mini_player.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'library_page.dart';
import 'player_page.dart';

/// 应用外壳（底部导航 + 迷你播放器）
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    LibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeController, PlayerController>(
      builder: (context, theme, player, child) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _pages[0],
              _pages[1],
              _pages[2],
            ],
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 迷你播放器
              if (player.hasSong)
                MiniPlayer(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlayerPage(),
                      ),
                    );
                  },
                ),
              // 底部导航
              BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: '首页',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    activeIcon: Icon(Icons.search),
                    label: '搜索',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: '我的',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
