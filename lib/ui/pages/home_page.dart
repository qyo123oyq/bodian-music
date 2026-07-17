import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/player_controller.dart';
import '../../services/music_api.dart';
import '../../models/music_models.dart';
import '../widgets/song_list_item.dart';
import '../widgets/artwork.dart';

/// 首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final MusicApiService _api = MusicApiService();

  List<Playlist> _recommendPlaylists = [];
  List<Song> _hotSongs = [];
  List<Map<String, dynamic>> _banners = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final data = await _api.getHomeData();
      setState(() {
        _recommendPlaylists = data['recommendPlaylists'] ?? <Playlist>[];
        _hotSongs = data['hotSongs'] ?? <Song>[];
        _banners = List<Map<String, dynamic>>.from(data['banners'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('波点音乐'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner轮播
                    if (_banners.isNotEmpty) _buildBanner(),
                    const SizedBox(height: 24),
                    // 快捷入口
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    // 推荐歌单
                    _buildSectionTitle('推荐歌单'),
                    _buildPlaylistGrid(),
                    const SizedBox(height: 24),
                    // 热门歌曲
                    _buildSectionTitle('热门歌曲'),
                    _buildHotSongs(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 160,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              '波点音乐',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '沉浸式听歌体验',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(Icons.favorite, '我喜欢', () {}),
          _buildActionItem(Icons.history, '最近播放', () {}),
          _buildActionItem(Icons.download, '下载管理', () {}),
          _buildActionItem(Icons.cloud, '本地音乐', () {}),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildPlaylistGrid() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _recommendPlaylists.length,
        itemBuilder: (context, index) {
          final playlist = _recommendPlaylists[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: PlaylistCard(
              playlist: playlist,
              onTap: () => _openPlaylist(playlist),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHotSongs() {
    return Consumer<PlayerController>(
      builder: (context, player, child) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _hotSongs.length > 10 ? 10 : _hotSongs.length,
          itemBuilder: (context, index) {
            final song = _hotSongs[index];
            return SongListItem(
              song: song,
              index: index,
              onTap: () {
                player.playSong(song, queue: _hotSongs);
              },
            );
          },
        );
      },
    );
  }

  void _openPlaylist(Playlist playlist) {
    Navigator.pushNamed(
      context,
      '/playlist',
      arguments: playlist,
    );
  }
}
