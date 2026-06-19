import 'dart:async';
import 'dart:math' as math;
import 'package:bite_smart/features/home/data/repositories/engagement_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeaderboardUser {
  final String name;
  final String badge;
  final int xp;
  final int rank;
  final Color avatarColor;
  final String initials;
  final int streakDays;

  const LeaderboardUser({
    required this.name,
    required this.badge,
    required this.xp,
    required this.rank,
    required this.avatarColor,
    required this.initials,
    required this.streakDays,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool _isLoading = true;
  LeaderboardData? _data;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final repo = context.read<IEngagementRepository>();
      final data = await repo.getLeaderboard();
      setState(() {
        _data = data;
        _isLoading = false;
      });
      _startSimulation();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted || _data == null) return;

      final rnd = math.Random();
      
      // 1. Simulate Global/Podium Players
      final allGlobal = [..._data!.podium, ..._data!.globalList];
      if (allGlobal.isNotEmpty) {
        final numToUpdate = rnd.nextInt(2) + 1; // 1 or 2 players
        for (int i = 0; i < numToUpdate; i++) {
          final idx = rnd.nextInt(allGlobal.length);
          final player = allGlobal[idx];
          final increment = rnd.nextInt(60) + 15; // 15 to 75 XP
          allGlobal[idx] = player.copyWith(xp: player.xp + increment);
        }
        
        // Re-sort global players by XP descending
        allGlobal.sort((a, b) => b.xp.compareTo(a.xp));
        
        // Re-assign ranks
        for (int i = 0; i < allGlobal.length; i++) {
          allGlobal[i] = allGlobal[i].copyWith(rank: i + 1);
        }
        
        // Re-split into podium (first 3) and globalList (the rest)
        final newPodium = allGlobal.take(3).toList();
        final newGlobalList = allGlobal.skip(3).toList();
        
        // Locate current user in this list to sync userRank and userXp
        int newCurrentUserRank = _data!.userRank;
        int newCurrentUserXp = _data!.userXp;
        final currentUserIndex = allGlobal.indexWhere((p) => p.isCurrentUser || p.name == _data!.userName);
        if (currentUserIndex != -1) {
          newCurrentUserRank = allGlobal[currentUserIndex].rank;
          newCurrentUserXp = allGlobal[currentUserIndex].xp;
        }

        setState(() {
          _data = _data!.copyWith(
            podium: newPodium,
            globalList: newGlobalList,
            userRank: newCurrentUserRank,
            userXp: newCurrentUserXp,
          );
        });
      }
      
      // 2. Simulate Friends Players
      final friends = [..._data!.friends];
      if (friends.isNotEmpty) {
        final idx = rnd.nextInt(friends.length);
        final player = friends[idx];
        final increment = rnd.nextInt(50) + 10; // 10 to 60 XP
        friends[idx] = player.copyWith(xp: player.xp + increment);
        
        // Re-sort friends by XP descending
        friends.sort((a, b) => b.xp.compareTo(a.xp));
        
        // Re-assign ranks
        for (int i = 0; i < friends.length; i++) {
          friends[i] = friends[i].copyWith(rank: i + 1);
        }
        
        setState(() {
          _data = _data!.copyWith(friends: friends);
        });
      }
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Color _getRandomColor(String name) {
    final colors = [
      const Color(0xFF4A7C59),
      const Color(0xFF8B6F5E),
      const Color(0xFFC4956A),
      const Color(0xFF6B8E6B),
      const Color(0xFF7B6B8E),
      const Color(0xFF5E7B8E),
      const Color(0xFF8E7B5E)
    ];
    return colors[name.hashCode % colors.length];
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  List<LeaderboardUser> _getTopThree() {
    if (_data == null) return [];
    final list = _selectedTab == 0 ? _data!.podium : _data!.friends;
    if (list.length < 3) return [];

    // Map to LeaderboardUser
    final mapped = list.map((p) => LeaderboardUser(
      name: p.name,
      badge: p.role,
      xp: p.xp,
      rank: p.rank,
      avatarColor: _getRandomColor(p.name),
      initials: _getInitials(p.name),
      streakDays: p.rank * 3, // Mock streak based on rank for premium UI feel
    )).toList();

    // order: 2nd (left), 1st (center), 3rd (right)
    // Mapped is [rank 1, rank 2, rank 3]
    return [mapped[1], mapped[0], mapped[2]];
  }

  List<LeaderboardUser> _getRest() {
    if (_data == null) return [];
    final list = _selectedTab == 0 ? _data!.globalList : _data!.friends.skip(3).toList();
    return list.map((p) => LeaderboardUser(
      name: p.name,
      badge: p.role,
      xp: p.xp,
      rank: p.rank,
      avatarColor: _getRandomColor(p.name),
      initials: _getInitials(p.name),
      streakDays: p.rank % 7,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F0),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4A7C59)),
        ),
      );
    }

    final topThree = _getTopThree();
    final rest = _getRest();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabs(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await _fetchLeaderboard();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        if (topThree.length >= 3) _buildPodium(topThree),
                        _buildRankList(rest),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildMyRankBar(),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _iconBtn(Icons.arrow_back_ios_new_rounded),
          const Expanded(
            child: Text(
              'Leaderboard',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8E8E3), width: 0.5),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1A1A1A)),
      ),
    );
  }

  // ── Tabs ───────────────────────────────────────────────────────────────────

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFEBEBE6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: ['Global', 'Friends'].asMap().entries.map((entry) {
            final selected = entry.key == _selectedTab;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = entry.key);
                  _animController.forward(from: 0);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            )
                          ]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF888888),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Podium ─────────────────────────────────────────────────────────────────

  Widget _buildPodium(List<LeaderboardUser> topThree) {
    // topThree order: 2nd (left), 1st (center), 3rd (right)
    final heights = [80.0, 100.0, 60.0];
    final avatarSizes = [50.0, 60.0, 40.0];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E3), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (i) {
              final user = topThree[i];
              final isFirst = user.rank == 1;
              return Expanded(
                child: Column(
                  children: [
                    if (isFirst)
                      const Text('👑', style: TextStyle(fontSize: 18))
                    else
                      const SizedBox(height: 20),
                    const SizedBox(height: 4),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: avatarSizes[i],
                          height: avatarSizes[i],
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: user.avatarColor,
                            border: Border.all(
                              color: isFirst
                                  ? const Color(0xFFFFD700)
                                  : Colors.white,
                              width: isFirst ? 3 : 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user.initials,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isFirst ? 16 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isFirst
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFFE8E8E3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${user.rank}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isFirst ? Colors.black : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.badge,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: heights[i],
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isFirst
                            ? const Color(0xFFF3FAF6)
                            : const Color(0xFFF5F5F0),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${user.xp}',
                            style: TextStyle(
                              fontSize: isFirst ? 16 : 14,
                              fontWeight: FontWeight.w800,
                              color: isFirst
                                  ? const Color(0xFF4A7C59)
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const Text(
                            'XP',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Rank List ──────────────────────────────────────────────────────────────

  Widget _buildRankList(List<LeaderboardUser> rest) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E3), width: 0.5),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rest.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          color: Color(0xFFEEEEEE),
          indent: 64,
        ),
        itemBuilder: (context, index) {
          final user = rest[index];
          return ListTile(
            leading: SizedBox(
              width: 80,
              child: Row(
                children: [
                  Text(
                    '${user.rank}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: user.avatarColor,
                    radius: 20,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            subtitle: Text(
              user.badge,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            trailing: Text(
              '${user.xp} XP',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Bottom Sheet Rank Bar ──────────────────────────────────────────────────

  Widget _buildMyRankBar() {
    if (_data == null) return const SizedBox.shrink();

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '#${_data!.userRank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                backgroundColor: const Color(0xFF2d7a4f),
                radius: 20,
                child: Text(
                  _getInitials(_data!.userName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _data!.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Top ${_data!.userPercentile}% players',
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '${_data!.userXp} XP',
            style: const TextStyle(
              color: Color(0xFF9FE1CB),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}