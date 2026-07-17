import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/cache_service.dart';

/// 设置页
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _cacheSize = 0;

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    final size = await PlaybackCacheManager().getCurrentCacheSize();
    setState(() {
      _cacheSize = size / (1024 * 1024); // MB
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 外观设置
          _buildSectionTitle('外观'),
          Consumer<ThemeController>(
            builder: (context, theme, child) {
              return Card(
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dark_mode),
                      title: const Text('深色模式'),
                      trailing: DropdownButton<ThemeMode>(
                        value: theme.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            theme.setThemeMode(value);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('跟随系统'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('浅色'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('深色'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('主题色'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: ThemeController.presetColors.take(4).map((c) {
                          final isSelected = theme.seedColor == c['color'];
                          return GestureDetector(
                            onTap: () => theme.setSeedColor(c['color']),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Color(c['color']),
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Color(c['color'])
                                              .withOpacity(0.5),
                                          blurRadius: 4,
                                        )
                                      ]
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      onTap: () => _showColorPicker(context),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.directions_car),
                      title: const Text('车机模式'),
                      subtitle: const Text('放大字体，简化界面'),
                      value: theme.carMode,
                      onChanged: (value) => theme.toggleCarMode(),
                    ),
                  ],
                ),
              );
            },
          ),

          // 播放设置
          _buildSectionTitle('播放'),
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.high_quality),
                  title: Text('默认音质'),
                  trailing: Text('高品质 320K'),
                ),
                Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(Icons.network_cell),
                  title: Text('允许移动网络播放'),
                  value: true,
                  onChanged: null,
                ),
                Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(Icons.playlist_play),
                  title: Text('自动播放下一首'),
                  value: true,
                  onChanged: null,
                ),
              ],
            ),
          ),

          // 下载设置
          _buildSectionTitle('下载与缓存'),
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('播放缓存'),
                  subtitle: Text('${_cacheSize.toStringAsFixed(1)} MB'),
                  trailing: TextButton(
                    onPressed: () async {
                      await PlaybackCacheManager().clearAllCache();
                      _loadCacheSize();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('缓存已清除')),
                        );
                      }
                    },
                    child: const Text('清除'),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.download),
                  title: Text('下载目录'),
                  trailing: Text('BodianMusic'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.numbers),
                  title: Text('同时下载数量'),
                  trailing: Text('3个'),
                ),
              ],
            ),
          ),

          // 关于
          _buildSectionTitle('关于'),
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('版本'),
                  trailing: Text('1.0.0'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.code),
                  title: Text('开源许可'),
                  trailing: Icon(Icons.chevron_right),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: Text('隐私政策'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final theme = context.read<ThemeController>();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择主题色',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: ThemeController.presetColors.map((c) {
                  final isSelected = theme.seedColor == c['color'];
                  return GestureDetector(
                    onTap: () {
                      theme.setSeedColor(c['color']);
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(c['color']),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c['name'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
