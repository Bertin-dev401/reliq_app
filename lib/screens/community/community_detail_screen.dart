import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../models/community.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';

class CommunityDetailScreen extends StatefulWidget {
  const CommunityDetailScreen({super.key});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  late final String _communityId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _communityId = args?['communityId'] ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CommunityProvider>(context, listen: false);
      provider.loadCommunities();
      if (_communityId.isNotEmpty) provider.loadPosts(_communityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, provider, _) {
        final community = provider.findCommunity(_communityId);
        if (_communityId.isEmpty) {
          return const Scaffold(body: Center(child: Text('Community not found.')));
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(community?.name ?? 'Community'),
                  background: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Icon(
                      Icons.people,
                      size: 72,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(community?.description ?? 'Community details are loading.'),
                      const SizedBox(height: 12),
                      Text('${community?.memberCount ?? 0} members'),
                      const SizedBox(height: 16),
                      if (community != null) _JoinButton(community: community),
                      const SizedBox(height: 24),
                      const Text(
                        'Posts',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.isLoading && provider.posts.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.error != null && provider.posts.isEmpty)
                SliverFillRemaining(
                  child: _StateMessage(
                    text: provider.error!,
                    onRetry: () => provider.loadPosts(_communityId),
                  ),
                )
              else if (provider.posts.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No posts in this community yet.')),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: _PostTile(post: provider.posts[index]),
                      );
                    },
                    childCount: provider.posts.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
          floatingActionButton: community == null
              ? null
              : FloatingActionButton(
                  onPressed: () => Get.toNamed(
                    '/create-post',
                    arguments: {'communityId': community.id},
                  ),
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }
}

class _JoinButton extends StatelessWidget {
  final Community community;

  const _JoinButton({required this.community});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return const SizedBox.shrink();

    final communities = Provider.of<CommunityProvider>(context, listen: false);
    return StreamBuilder<bool>(
      stream: communities.watchMembership(community.id, user.id),
      builder: (context, snapshot) {
        final joined = snapshot.data ?? false;
        return ElevatedButton(
          onPressed: () {
            if (joined) {
              communities.leaveCommunity(community.id, user.id);
            } else {
              communities.joinCommunity(community.id, user.id);
            }
          },
          child: Text(joined ? 'Leave Community' : 'Join Community'),
        );
      },
    );
  }
}

class _PostTile extends StatelessWidget {
  final Post post;

  const _PostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(post.content),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.favorite_border, size: 16),
                const SizedBox(width: 4),
                Text('${post.likesCount}'),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, size: 16),
                const SizedBox(width: 4),
                Text('${post.commentsCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;

  const _StateMessage({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
