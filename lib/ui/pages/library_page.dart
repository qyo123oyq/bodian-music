import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../widgets/artwork.dart';

/// 我的页面
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<AuthController>(
      builder: (context, auth, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('我的'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: ListView(
            children: [
              // 用户信息卡片
              _buildUserCard(context, auth),
              const SizedBox(height: 16),
              // 功能入口
              _buildSectionTitle('我的音乐'),
              _buildFunctionList(),
              const SizedBox(height: 16),
              // 创建的歌单
              _buildSectionTitle('我的歌单'),
              _buildPlaylistList(),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, AuthController auth) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (!auth.isLoggedIn) {
                  _showLoginDialog(context);
                }
              },
              child: CircleAvatar(
                radius: 32,
                backgroundImage: auth.user?.avatar.isNotEmpty == true
                    ? NetworkImage(auth.user!.avatar)
                    : null,
                child: auth.user?.avatar.isNotEmpty == true
                    ? null
                    : const Icon(Icons.person, size: 32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.isLoggedIn
                        ? auth.user?.nickname ?? '用户'
                        : '点击登录',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  if (auth.isLoggedIn)
                    Row(
                      children: [
                        if (auth.user?.isVip == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber,
                                  Colors.orange,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'VIP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          'Lv.${auth.user?.level ?? 0}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    )
                  else
                    Text(
                      '登录后享受更多功能',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
            if (auth.isLoggedIn)
              IconButton(
                onPressed: () => _showLoginDialog(context),
                icon: const Icon(Icons.logout),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildFunctionList() {
    final items = [
      {'icon': Icons.favorite, 'title': '我喜欢', 'count': '0首'},
      {'icon': Icons.history, 'title': '最近播放', 'count': ''},
      {'icon': Icons.download_done, 'title': '下载管理', 'count': ''},
      {'icon': Icons.library_music, 'title': '本地音乐', 'count': ''},
      {'icon': Icons.cloud, 'title': '我的云盘', 'count': ''},
      {'icon': Icons.radio, 'title': '我的电台', 'count': ''},
    ];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(height: 1),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(item['icon'] as IconData),
                  title: Text(item['title'] as String),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if ((item['count'] as String).isNotEmpty)
                        Text(
                          item['count'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                  onTap: () {},
                ),
                if (entry.key != items.length - 1) const Divider(height: 1),
              ],
            );
          }),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildPlaylistList() {
    final playlists = [
      {'name': '我喜欢的音乐', 'count': 0, 'cover': ''},
      {'name': '最近添加', 'count': 0, 'cover': ''},
    ];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...playlists.map((playlist) {
            return ListTile(
              leading: ArtworkWidget(
                url: playlist['cover'] as String,
                size: 48,
                borderRadius: 8,
              ),
              title: Text(playlist['name'] as String),
              subtitle: Text('${playlist['count']}首'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            );
          }),
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add),
            ),
            title: const Text('新建歌单'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    final auth = context.read<AuthController>();
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(auth.isLoggedIn ? '退出登录' : '登录'),
          content: auth.isLoggedIn
              ? const Text('确定要退出登录吗？')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('请输入波点音乐用户ID'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: '用户ID (UID)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (auth.isLoggedIn) {
                  await auth.logout();
                } else {
                  final success =
                      await auth.loginWithUid(controller.text.trim());
                  if (success) {
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('登录失败，请检查UID')),
                    );
                  }
                }
              },
              child: Text(auth.isLoggedIn ? '退出' : '登录'),
            ),
          ],
        );
      },
    );
  }
}
