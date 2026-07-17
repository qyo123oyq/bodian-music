import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 封面图组件
class ArtworkWidget extends StatelessWidget {
  final String? url;
  final double size;
  final double borderRadius;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ArtworkWidget({
    super.key,
    this.url,
    this.size = 60,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = url == null || url!.isEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: isEmpty
            ? _buildPlaceholder(context)
            : CachedNetworkImage(
                imageUrl: url!,
                fit: fit,
                placeholder: (context, url) => _buildPlaceholder(context),
                errorWidget: (context, url, error) =>
                    _buildErrorWidget(context),
              ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return placeholder ??
        Container(
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Icon(
            Icons.music_note,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: size * 0.4,
          ),
        );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return errorWidget ??
        Container(
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Icon(
            Icons.broken_image,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: size * 0.4,
          ),
        );
  }
}

/// 圆形封面图
class CircularArtwork extends StatelessWidget {
  final String? url;
  final double size;

  const CircularArtwork({
    super.key,
    this.url,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: ArtworkWidget(
        url: url,
        size: size,
        borderRadius: 0,
      ),
    );
  }
}
