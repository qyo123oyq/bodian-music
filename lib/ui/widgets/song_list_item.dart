import 'package:flutter/material.dart';
import '../../models/music_models.dart';
import 'artwork.dart';

/// 歌曲列表项
class SongListItem extends StatelessWidget {
  final Song song;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool showIndex;
  final bool isPlaying;
  final bool showArtist;

  const SongListItem({
    super.key,
    required this.song,
    this.index = 0,
    this.onTap,
    this.onMoreTap,
    this.showIndex = true,
    this.isPlaying = false,
    this.showArtist = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: showIndex
          ? SizedBox(
              width: 32,
              child: Center(
                child: isPlaying
                    ? Icon(
                        Icons.volume_up,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
              ),
            )
          : ArtworkWidget(
              url: song.albumPicUrl,
              size: 48,
              borderRadius: 6,
            ),
      title: Text(
        song.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isPlaying
              ? Theme.of(context).colorScheme.primary
              : null,
          fontWeight: isPlaying ? FontWeight.w600 : null,
        ),
      ),
      subtitle: showArtist
          ? Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (song.isVip)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'VIP',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (song.duration > 0) ...[
            const SizedBox(width: 8),
            Text(
              song.formatDuration(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          IconButton(
            onPressed: onMoreTap,
            icon: const Icon(Icons.more_vert),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

/// 歌单卡片
class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const PlaylistCard({
    super.key,
    required this.playlist,
    this.onTap,
    this.width = 140,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ArtworkWidget(
                  url: playlist.cover,
                  size: width,
                  borderRadius: 12,
                ),
                if (playlist.playCount > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_arrow,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _formatCount(playlist.playCount),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              playlist.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 100000000) {
      return '${(count / 100000000).toStringAsFixed(1)}亿';
    } else if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }
}
