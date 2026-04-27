import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';

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
    'All', 'Catholic', 'Protestant', 'Anglican',
    'Mormon', 'Muslim', 'Orthodox', 'Adventist',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
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
                    // Denomination filter chips
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
                    // Posts / Events tabs
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
              _PostsTab(),
              _EventsTab(),
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
            _SheetOption(icon: Icons.edit_outlined,       label: 'New Post',    onTap: () { Get.back(); Get.toNamed('/create-post'); }),
            _SheetOption(icon: Icons.event_outlined,      label: 'New Event',   onTap: () { Get.back(); Get.toNamed('/create-event'); }),
            _SheetOption(icon: Icons.play_circle_outline, label: 'Go Live',     onTap: () { Get.back(); Get.toNamed('/live-events'); }),
            _SheetOption(icon: Icons.volunteer_activism,  label: 'Fundraiser',  onTap: () { Get.back(); Get.toNamed('/donations'); }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PostsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CommunityPostCard(index: i),
    );
  }
}

class _EventsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _EventCard(index: i),
    );
  }
}

class _CommunityPostCard extends StatefulWidget {
  final int index;
  const _CommunityPostCard({required this.index});
  @override
  State<_CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<_CommunityPostCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  'U',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Community member', style: Theme.of(context).textTheme.titleSmall),
                    Text('${widget.index + 1}h ago', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, size: 18, color: ReliqTheme.text3(context)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Sharing a reflection from today\'s reading. Faith grows in community.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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
                    Text('${12 + widget.index}', style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Icon(Icons.chat_bubble_outline, size: 16, color: ReliqTheme.text3(context)),
              const SizedBox(width: 4),
              Text('${3 + widget.index}', style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              Icon(Icons.share_outlined, size: 16, color: ReliqTheme.text3(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final int index;
  const _EventCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(
                  '${15 + index}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'APR',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sunday Service', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text('10:00 AM · Kigali', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('RSVP', style: Theme.of(context).textTheme.labelMedium),
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetOption({required this.icon, required this.label, required this.onTap});

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
