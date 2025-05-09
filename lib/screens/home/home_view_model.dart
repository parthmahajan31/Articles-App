import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/post_data.dart';
import '../../services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService;

  HomeViewModel(this._apiService);

  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _showFavorites = false;

  List<Post> get posts {
    final source =
        _showFavorites
            ? _filteredPosts.where((p) => _favoriteIds.contains(p.id)).toList()
            : _filteredPosts;
    return source;
  }

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool isFavorite(Post post) => _favoriteIds.contains(post.id);

  bool get showFavorites => _showFavorites;

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allPosts = await _apiService.fetchPosts();
      _filteredPosts = [..._allPosts];
      await _loadFavorites();
      applySearch(_searchQuery);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void applySearch(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredPosts = [..._allPosts];
    } else {
      _filteredPosts =
          _allPosts.where((post) {
            final q = query.toLowerCase();
            return post.title.toLowerCase().contains(q) ||
                post.body.toLowerCase().contains(q);
          }).toList();
    }
    notifyListeners();
  }

  void toggleFavorite(Post post) {
    if (_favoriteIds.contains(post.id)) {
      _favoriteIds.remove(post.id);
    } else {
      _favoriteIds.add(post.id);
    }
    _saveFavorites();
    notifyListeners();
  }

  void toggleTab(bool showFavoritesTab) {
    _showFavorites = showFavoritesTab;
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_ids') ?? [];
    _favoriteIds = ids.map(int.parse).toSet();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorite_ids',
      _favoriteIds.map((e) => e.toString()).toList(),
    );
  }

  Future<void> refresh() async {
    await loadPosts();
  }
}
