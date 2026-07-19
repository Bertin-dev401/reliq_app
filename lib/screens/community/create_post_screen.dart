import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../models/community.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentCtrl = TextEditingController();
  String? _communityId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _communityId = args?['communityId'];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityProvider>(context, listen: false).loadCommunities();
    });
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final communityProvider =
        Provider.of<CommunityProvider>(context, listen: false);
    final user = auth.currentUser;
    final community = _selectedCommunity(communityProvider.communities);
    final content = _contentCtrl.text.trim();

    if (user == null || community == null || content.isEmpty) return;

    setState(() => _saving = true);
    final success = await communityProvider.createPost(
      community: community,
      user: user,
      content: content,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      Get.back();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(communityProvider.error ?? 'Could not post.')),
      );
    }
  }

  Community? _selectedCommunity(List<Community> communities) {
    if (_communityId == null && communities.isNotEmpty) {
      _communityId = communities.first.id;
    }
    for (final community in communities) {
      if (community.id == _communityId) return community;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, communityProvider, _) {
        final communities = communityProvider.communities;
        final canPost = !_saving &&
            _contentCtrl.text.trim().isNotEmpty &&
            _selectedCommunity(communities) != null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Create Post'),
            actions: [
              TextButton(
                onPressed: canPost ? _save : null,
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post'),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: communityProvider.isLoading && communities.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : communities.isEmpty
                    ? const Center(child: Text('No communities available yet.'))
                    : Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedCommunity(communities)?.id,
                            decoration: const InputDecoration(
                              labelText: 'Community',
                              border: OutlineInputBorder(),
                            ),
                            items: communities
                                .map(
                                  (community) => DropdownMenuItem(
                                    value: community.id,
                                    child: Text(community.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _communityId = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _contentCtrl,
                            maxLines: 10,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Share your thoughts...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.image),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.videocam),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
          ),
        );
      },
    );
  }
}
