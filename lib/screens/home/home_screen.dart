import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../providers/bible_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BibleProvider>(context, listen: false).loadDailyVerse();
      Provider.of<StreakProvider>(context, listen: false).loadStreak();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final firstName = user?.name.split(' ').first ?? 'Friend';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App bar ──────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              titleSpacing: 20,
              title: Text(
                'Reliq',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              actions: [
                // Chat icon — one tap away
                _IconBtn(
                  icon: Icons.chat_bubble_outline,
                  onTap: () => Get.toNamed('/chat-list'),
                ),
                // Notifications
                _IconBtn(
                  icon: Icons.notifications_outlined,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Greeting ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good to see you,',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ReliqTheme.text2(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          firstName,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Daily verse ───────────────────────
                  _DailyVerseCard(),

                  const SizedBox(height: 16),

                  // ── Streak ────────────────────────────
                  _StreakCard(),

                  const SizedBox(height: 24),

                  // ── Quick access ──────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Quick access',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ReliqTheme.text2(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickAccessRow(),

                  const SizedBox(height: 24),

                  // ── Community feed preview ────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'From your community',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: ReliqTheme.text2(context),
                          ),
                        ),
                        _TextBtn(
                          label: 'See all',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _PostCard(
                    name: 'Sarah M.',
                    time: '2h ago',
                    content: 'Grateful for today\'s sermon on forgiveness. It really touched my heart.',
                    likes: '45',
                    comments: '12',
                  ),
                  const _PostCard(
                    name: 'David K.',
                    time: '4h ago',
                    content: 'Just finished reading the book of Psalms. What a journey of faith and trust.',
                    likes: '28',
                    comments: '7',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Daily verse card ──────────────────────────────────────────────────────────
class _DailyVerseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(
      builder: (context, bible, _) {
        final verse = bible.dailyVerse;
        return _PressableCard(
          onTap: () => Get.toNamed('/daily-verse'),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_stories_outlined, size: 16, color: ReliqTheme.text2(context)),
                    const SizedBox(width: 6),
                    Text(
                      'Verse of the day',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward, size: 14, color: ReliqTheme.text3(context)),
                  ],
                ),
                const SizedBox(height: 12),
                if (bible.isLoading)
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ReliqTheme.surface2(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                else if (verse != null) ...[
                  Text(
                    '"${verse.verse.text}"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    verse.verse.reference,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ] else
                  Text(
                    'Tap to load today\'s verse',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ReliqTheme.text2(context),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Streak card ───────────────────────────────────────────────────────────────
class _StreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StreakProvider>(
      builder: (context, streak, _) {
        return _PressableCard(
          onTap: () => Get.toNamed('/streaks'),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ReliqTheme.surface2(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.local_fire_department_outlined,
                    size: 20,
                    color: ReliqTheme.ink(context),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${streak.currentStreak} day streak',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        streak.todayCompleted
                            ? 'Completed for today'
                            : 'Complete today\'s activity',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, size: 14, color: ReliqTheme.text3(context)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Quick access row ──────────────────────────────────────────────────────────
class _QuickAccessRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.shopping_bag_outlined, 'Shop',    '/marketplace'),
      (Icons.volunteer_activism,    'Give',    '/donations'),
      (Icons.play_circle_outline,   'Live',    '/live-events'),
      (Icons.quiz_outlined,         'Quiz',    '/quiz'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: item == items.last ? 0 : 10,
              ),
              child: _PressableCard(
                onTap: () => Get.toNamed(item.$3),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: [
                      Icon(item.$1, size: 20, color: ReliqTheme.ink(context)),
                      const SizedBox(height: 6),
                      Text(
                        item.$2,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ReliqTheme.text2(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Post card ─────────────────────────────────────────────────────────────────
class _PostCard extends StatefulWidget {
  final String name;
  final String time;
  final String content;
  final String likes;
  final String comments;

  const _PostCard({
    required this.name,
    required this.time,
    required this.content,
    required this.likes,
    required this.comments,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
                  widget.name[0],
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name, style: Theme.of(context).textTheme.titleSmall),
                    Text(widget.time, style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, size: 18, color: ReliqTheme.text3(context)),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.content, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              // Like button with micro interaction
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _liked = !_liked);
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    key: ValueKey(_liked),
                    children: [
                      Icon(
                        _liked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: _liked ? ReliqTheme.ink(context) : ReliqTheme.text3(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.likes,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Icon(Icons.chat_bubble_outline, size: 16, color: ReliqTheme.text3(context)),
              const SizedBox(width: 4),
              Text(widget.comments, style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              Icon(Icons.share_outlined, size: 16, color: ReliqTheme.text3(context)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Reusable pressable card ───────────────────────────────────────────────────
// Scales down slightly on press — subtle micro interaction
class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsets? margin;

  const _PressableCard({
    required this.child,
    required this.onTap,
    this.margin,
  });

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.02,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          margin: widget.margin,
          decoration: BoxDecoration(
            color: ReliqTheme.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ReliqTheme.border(context)),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22),
      onPressed: onTap,
      splashRadius: 20,
    );
  }
}

class _TextBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TextBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: ReliqTheme.ink(context),
        ),
      ),
    );
  }
}
