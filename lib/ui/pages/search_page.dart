import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/player_controller.dart';
import '../../services/music_api.dart';
import '../../models/music_models.dart';
import '../widgets/song_list_item.dart';

/// 搜索页
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final MusicApiService _api = MusicApiService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Song> _searchResults = [];
  List<String> _searchHistory = [];
  List<String> _hotSearches = [
    '周杰伦',
    '林俊杰',
    '陈奕迅',
    '薛之谦',
    '邓紫棋',
    '林俊杰',
    'Taylor Swift',
  ];
  bool _isSearching = false;
  bool _hasSearched = false;
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    // 从本地存储加载搜索历史
    // 这里简化处理
    setState(() {
      _searchHistory = [];
    });
  }

  Future<void> _saveSearchHistory(String keyword) async {
    if (!_searchHistory.contains(keyword)) {
      setState(() {
        _searchHistory.insert(0, keyword);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      });
    }
  }

  Future<void> _doSearch(String keyword) async {
    if (keyword.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _currentPage = 1;
    });

    _saveSearchHistory(keyword);

    try {
      final results = await _api.searchSongs(keyword, page: 1);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final results = await _api.searchSongs(
        _searchController.text,
        page: _currentPage,
      );
      setState(() {
        _searchResults.addAll(results);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          onSubmitted: _doSearch,
          decoration: InputDecoration(
            hintText: '搜索歌曲、歌手、专辑',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _hasSearched = false;
                        _searchResults = [];
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ],
    ),
    body: _hasSearched ? _buildSearchResults() : _buildSearchSuggestions(),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索历史
          if (_searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '搜索历史',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _searchHistory.clear());
                  },
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 20,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory
                  .map((keyword) => GestureDetector(
                        onTap: () {
                          _searchController.text = keyword;
                          _doSearch(keyword);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(keyword),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
          // 热门搜索
          Text(
            '热门搜索',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _hotSearches
                .asMap()
                .entries
                .map((entry) => GestureDetector(
                      onTap: () {
                        _searchController.text = entry.value;
                        _doSearch(entry.value);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: entry.key < 3
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: entry.key < 3
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : null,
                            fontWeight: entry.key < 3
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '未找到相关结果',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return Consumer<PlayerController>(
      builder: (context, player, child) {
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!_isLoadingMore &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              _loadMore();
            }
            return true;
          },
          child: ListView.builder(
            itemCount: _searchResults.length + 1,
            itemBuilder: (context, index) {
              if (index == _searchResults.length) {
                return _isLoadingMore
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox.shrink();
              }

              final song = _searchResults[index];
              return SongListItem(
                song: song,
                index: index,
                onTap: () {
                  player.playSong(song, queue: _searchResults);
                },
              );
            },
          ),
        );
      },
    );
  }
}
