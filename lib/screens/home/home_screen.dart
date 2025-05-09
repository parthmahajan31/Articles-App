import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../details/article_details_screen.dart';
import 'home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(ApiService())..loadPosts(),
      child: const _HomeScreenBody(),
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Articles"),
          centerTitle: true,
          bottom: TabBar(
            onTap: (index) => vm.toggleTab(index == 1),
            tabs: const [Tab(text: "All"), Tab(text: "Favorites")],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onChanged: vm.applySearch,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: vm.refresh,
                child: Builder(
                  builder: (context) {
                    if (vm.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (vm.errorMessage != null) {
                      return Center(child: Text(vm.errorMessage!));
                    }
                    if (vm.posts.isEmpty) {
                      return const Center(child: Text("No articles found."));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: vm.posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final post = vm.posts[index];
                        final isFav = vm.isFavorite(post);
                        final preview =
                            post.body.length > 100
                                ? '${post.body.substring(0, 100)}…'
                                : post.body;

                        return InkWell(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ArticleDetailScreen(post: post),
                                ),
                              ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.title,
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(preview),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFav ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () => vm.toggleFavorite(post),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
