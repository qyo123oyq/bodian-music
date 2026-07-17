import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/player_controller.dart';
import '../../services/music_api.dart';
import '../../models/music_models.dart';
import '../widgets/artwork.dart';
import '../widgets/song_list_item.dart';

/// 歌单详情页
class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final MusicApiService _api = MusicApiService();

  List<Song> _songs = [];
  bool _isLoading = true;
  Playlist? _playlistDetail;

  @override
  void initState() {
    super.initState();
    _loadPlaylistDetail();
  }

  Future<void> _loadPlaylistDetail() async {
    setState(() => _isLoading = true);

    try {
      // 尝试获取歌单详情
      final detail = await _api.getPlaylistDetail(widget.playlist.id);
      if (detail != null) {
        _playlistDetail = detail;
      }

      // 获取歌单歌曲
      final songs = await _api.getPlaylistSongs(widget.playlist.id);
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlist = _playlistDetail ?? widget.playlist;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(playlist.name),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 模糊背景（简化版）
                  Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  // 歌单信息
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ArtworkWidget(
                            url: playlist.cover,
                            size: 140,
                            borderRadius: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            playlist.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (playlist.creator.isNotEmpty)
                          Center(
                            child: Text(
                              'by ${playlist.creator}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // 操作栏
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _playAll,
                          icon: const Icon(Icons.play_arrow),
                          label: Text('播放全部 (${_songs.length})'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('收藏'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          ),
          // 歌曲列表
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = _songs[index];
                      return Consumer<PlayerController>(
                        builder: (context, player, child) {
                          return SongListItem(
                            song: song,
                            index: index,
                            onTap: () {
                              player.playSong(song, queue: _songs);
                            },
                          );
                        },
                      );
                    },
                    childCount: _songs.length,
                  ),
                ),
        ],
      ),
    );
  }

  void _playAll() {
    if (_songs.isNotEmpty) {
      final player = context.read<PlayerController>();
      player.playSong(_songs.first, queue: _songs);
    }
  }
}
