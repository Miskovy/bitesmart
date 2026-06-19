import 'package:bite_smart/features/home/data/repositories/engagement_repository.dart';
import 'package:bite_smart/features/home/screens/leadeerBoard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeaturedChallenge {
  final String badge;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const FeaturedChallenge({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

class CommunityChallengesScreen extends StatefulWidget {
  const CommunityChallengesScreen({super.key});

  @override
  State<CommunityChallengesScreen> createState() =>
      _CommunityChallengesScreenState();
}

class _CommunityChallengesScreenState extends State<CommunityChallengesScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All Active', 'My Challenges', 'Starting'];

  bool _isLoading = true;
  List<CommunityChallenge> _allChallenges = [];
  final Set<String> _locallyJoinedIds = {};

  final List<FeaturedChallenge> _featured = const [
    FeaturedChallenge(
      badge: '🔥 TRENDING',
      title: '7-Day Sugar-Free',
      subtitle: 'Reset your insulin levels and...',
      gradient: [Color(0xFF2d7a4f), Color(0xFF1a5c38)],
    ),
    FeaturedChallenge(
      badge: '✨ NEW',
      title: 'Walk 10k Steps',
      subtitle: 'Walk 10,000 steps daily to...',
      gradient: [Color(0xFF534AB7), Color(0xFF3C3489)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
  }

  Future<void> _fetchChallenges() async {
    try {
      final repo = context.read<IEngagementRepository>();
      final list = await repo.getChallenges();
      setState(() {
        _allChallenges = list.map((c) {
          if (_locallyJoinedIds.contains(c.id)) {
            return c.copyWith(isJoined: true);
          }
          return c;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleJoinLeave(CommunityChallenge c) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final repo = context.read<IEngagementRepository>();
      if (c.isJoined) {
        await repo.leaveChallenge(c.id);
        _locallyJoinedIds.remove(c.id);
      } else {
        await repo.joinChallenge(c.id);
        _locallyJoinedIds.add(c.id);
      }
      await _fetchChallenges();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<CommunityChallenge> get _filteredChallenges {
    if (_selectedTab == 1) {
      return _allChallenges.where((c) => c.isJoined).toList();
    } else if (_selectedTab == 2) {
      return _allChallenges.where((c) => c.durationDays >= 7).toList();
    }
    return _allChallenges;
  }

  String _getEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'diet':
        return '🥗';
      case 'hydration':
        return '💧';
      case 'activity':
        return '🏋️';
      default:
        return '🏆';
    }
  }

  Color _getIconBg(String category) {
    switch (category.toLowerCase()) {
      case 'diet':
        return const Color(0xFFFFF4E8);
      case 'hydration':
        return const Color(0xFFE8F4FF);
      case 'activity':
        return const Color(0xFFEEEEFE);
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  Color _getProgressColor(String category) {
    switch (category.toLowerCase()) {
      case 'diet':
        return const Color(0xFFE87040);
      case 'hydration':
        return const Color(0xFF378ADD);
      case 'activity':
        return const Color(0xFF534AB7);
      default:
        return const Color(0xFF2d7a4f);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2d7a4f)),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await _fetchChallenges();
                },
                color: const Color(0xFF2d7a4f),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildFeaturedSection(),
                      _buildTabs(),
                      _buildOngoingSection(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Community Challenges',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Push your limits together.',
                style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Featured ──────────────────────────────────────────────────────────────

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LeaderboardScreen(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Leaderboard'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _featured.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _buildFeaturedCard(_featured[index]),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildFeaturedCard(FeaturedChallenge c) {
    final matchIndex = _allChallenges.indexWhere(
      (ch) => ch.title.toLowerCase() == c.title.toLowerCase()
    );
    final isJoined = matchIndex != -1 ? _allChallenges[matchIndex].isJoined : false;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: c.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    c.badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  c.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  c.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    if (matchIndex != -1) {
                      _toggleJoinLeave(_allChallenges[matchIndex]);
                    } else if (_allChallenges.isNotEmpty) {
                      _toggleJoinLeave(_allChallenges.first);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      isJoined ? '✓ Joined' : 'Join Challenge',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────

  Widget _buildTabs() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBE6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final selected = i == _selectedTab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : [],
                      ),
                      margin: const EdgeInsets.all(3),
                      alignment: Alignment.center,
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFF888888),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  // ── Ongoing Challenges ────────────────────────────────────────────────────

  Widget _buildOngoingSection() {
    final list = _filteredChallenges;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Text(
            'Ongoing Challenges',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No challenges found in this section.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          )
        else
          ...(list
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  child: _buildChallengeCard(c),
                ),
              )
              .toList()),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildChallengeCard(CommunityChallenge c) {
    final double progressVal = c.targetValue > 0
        ? (c.currentProgress / c.targetValue).clamp(0.0, 1.0)
        : 0.0;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E3), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _getIconBg(c.category),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(_getEmoji(c.category),
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 10),
              // Name & meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      c.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${c.category} · ${c.durationDays} days left · Goal: ${c.targetValue} ${c.unit}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Action button
              _buildActionButton(c),
            ],
          ),
          const SizedBox(height: 10),
          // Footer row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    '${c.participantsCount > 0 ? c.participantsCount : 120} participants',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
              Text(
                c.isJoined
                    ? 'Your Progress: ${(progressVal * 100).toInt()}%'
                    : 'Global Goal',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressVal,
              minHeight: 5,
              backgroundColor: const Color(0xFFF0F0EC),
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(c.category)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(CommunityChallenge c) {
    if (c.isJoined) {
      return OutlinedButton(
        onPressed: () => _toggleJoinLeave(c),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2d7a4f),
          side: const BorderSide(color: Color(0xFF2d7a4f), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          '✓ Joined',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: () => _toggleJoinLeave(c),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Join',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );
    }
  }
}
