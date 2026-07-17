import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'controllers/player_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/auth_controller.dart';
import 'services/music_api.dart';
import 'services/cache_service.dart';
import 'services/download_service.dart';
import 'ui/pages/app_shell.dart';
import 'ui/pages/player_page.dart';
import 'ui/pages/search_page.dart';
import 'ui/pages/playlist_detail_page.dart';
import 'ui/pages/settings_page.dart';
import 'models/music_models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => PlayerController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        Provider<MusicApiService>(create: (_) => MusicApiService()),
        Provider<CacheService>(create: (_) => CacheService()),
        Provider<DownloadService>(create: (_) => DownloadService()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, child) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: theme.lightTheme,
            darkTheme: theme.darkTheme,
            themeMode: theme.themeMode,
            home: const AppShell(),
            routes: {
              '/search': (context) => const SearchPage(),
              '/settings': (context) => const SettingsPage(),
              '/player': (context) => const PlayerPage(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/playlist') {
                final playlist = settings.arguments as Playlist;
                return MaterialPageRoute(
                  builder: (context) =>
                      PlaylistDetailPage(playlist: playlist),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
