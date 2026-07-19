import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/community.dart';
import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/event_provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _selectedDenomination = 'All';

  static const List<String> _denominations = [
    'All',
    'Catholic',
    'Protestant',
    'Anglican',
    'Mormon',
    'Muslim',
    'Orthodox',
    'Adventist',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final communities =
          Provider.of<CommunityProvider>(context, listen: false);
      final events = Provider.of<EventProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      communities.loadCommunities();
      communities.loadFeedPosts();
      events.loadEvents();
      if (user != null) events.loadRsvps(user.id);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              floating: true,
              snap: true,
              titleSpacing: 20,
              title: Text('Community', style: Theme.of(context).textTheme.titleLarge),
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                const SizedBox(width: 4),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(88),
                child: Column(
                  children: [
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _denominations.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final d = _denominations[i];
                          final selected = _selectedDenomination == d;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedDenomination = d);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? ReliqTheme.ink(context)
                                    : ReliqTheme.surface2(context),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected
                                      ? ReliqTheme.ink(context)
                                      : ReliqTheme.border(context),
                                ),
                              ),
                              child: Text(
                                d,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: selected
                                      ? ReliqTheme.inkInverse(context)
                                      : ReliqTheme.text2(context),
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    TabBar(
                      controller: _tabs,
                      labelColor: ReliqTheme.ink(context),
                      unselectedLabelColor: ReliqTheme.text3(context),
                      indicatorColor: ReliqTheme.ink(context),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 1.5,
                      labelStyle: Theme.of(context).textTheme.labelLarge,
                      unselectedLabelStyle: Theme.of(context).textTheme.labelMedium,
                      tabs: const [
                        Tab(text: 'Posts'),
                        Tab(text: 'Events'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabs,
            children: [
              _PostsTab(denomination: _selectedDenomination),
              _EventsTab(denomination: _selectedDenomination),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showCreateSheet(context);
        },
        backgroundColor: ReliqTheme.ink(context),
        foregroundColor: ReliqTheme.inkInverse(context),
        elevation: 0,
        child: const Icon(Icons.add, size: 22),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ReliqTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            _SheetOption(
              icon: Icons.edit_outlined,
              label: 'New Post',
              onTap: () {
                Get.back();
                Get.toNamed('/create-post');
              },
            ),
            _SheetOption(
              icon: Icons.event_outlined,
              label: 'New Event',
              onTap: () {
                Get.back();
                Get.toNamed('/create-event');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PostsTab extends StatelessWidget {
  final String denomination;

  const _PostsTab({required this.denomination});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, community, _) {
        if (community.error != null && community.feedPosts.isEmpty) {
          return _StateMessage(
            icon: Icons.wifi_off,
            text: community.error!,
            actionLabel: 'Retry',
            onAction: community.loadFeedPosts,
          );
        }

        final posts = community.feedPosts.where((post) {
          return denomination == 'All' ||
              post.communityDenomination == denomination;
        }).toList();

        if (posts.isEmpty) {
          return const _StateMessage(
            icon: Icons.forum_outlined,
            text: 'No community posts yet.',
          );
        }

        return RefreshIndicator(
          onRefresh: community.loadFeedPosts,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _CommunityPostCard(post: posts[i]),
          ),
        );
      },
    );
  }
}

class _EventsTab extends StatelessWidget {
  final String denomination;

  const _EventsTab({required this.denomination});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, events, _) {
        if (events.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (events.error != null && events.events.isEmpty) {
          return _StateMessage(
            icon: Icons.wifi_off,
            text: events.error!,
            actionLabel: 'Retry',
            onAction: events.loadEvents,
          );
        }

        final list = events.events.where((event) {
          return denomination == 'All' || event.denomination == denomination;
        }).toList();

        if (list.isEmpty) {
          return const _StateMessage(
            icon: Icons.event_busy_outlined,
            text: 'No events yet.',
          );
        }

        return RefreshIndicator(
          onRefresh: events.loadEvents,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _EventCard(event: list[i]),
          ),
        );
      },
    );
  }
}

class _CommunityPostCard extends StatefulWidget {
  final Post post;

  const _CommunityPostCard({required this.post});

  @override
  State<_CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<_CommunityPostCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return GestureDetector(
      onTap: () => Get.toNamed(
        '/community-detail',
        arguments: {'communityId': post.communityId},
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ReliqTheme.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ReliqTheme.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: ReliqTheme.surface2(context),
                  child: Text(
                    post.userName.isNotEmpty ? post.userName[0].toUpperCase() : 'R',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.userName, style: Theme.of(context).textTheme.titleSmall),
                      Text(
                        post.communityName ?? _timeAgo(post.createdAt),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, size: 18, color: ReliqTheme.text3(context)),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 14),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _liked = !_liked);
                  },
                  child: Row(
                    children: [
                      Icon(
                        _liked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: _liked ? ReliqTheme.ink(context) : ReliqTheme.text3(context),
                      ),
                      const SizedBox(width: 4),
                      Text('${post.likesCount}', style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Icon(Icons.chat_bubble_outline, size: 16, color: ReliqTheme.text3(context)),
                const SizedBox(width: 4),
                Text('${post.commentsCount}', style: Theme.of(context).textTheme.labelMedium),
                const Spacer(),
                Icon(Icons.share_outlined, size: 16, color: ReliqTheme.text3(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final FaithEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/event-detail', arguments: event),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ReliqTheme.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ReliqTheme.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ReliqTheme.surface2(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${event.startDate.day}', style: Theme.of(context).textTheme.titleMedium),
                  Text(_month(event.startDate.month), style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    '${_time(event.startDate)} - ${event.location}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => Get.toNamed('/event-detail', arguments: event),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('View', style: Theme.of(context).textTheme.labelMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StateMessage({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: ReliqTheme.text3(context)),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20, color: ReliqTheme.ink(context)),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      onTap: onTap,
    );
  }
}

String _month(int month) {
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  return months[month - 1];
}

String _time(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
