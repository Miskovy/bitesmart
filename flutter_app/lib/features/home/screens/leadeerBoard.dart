import 'package:flutter/material.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

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

  final List<LeaderboardUser> _topThree = const [
    LeaderboardUser(
      name: 'Sarah M.',
      badge: 'Sugar Slayer',
      xp: 11200,
      rank: 2,
      avatarColor: Color(0xFF8B6F5E),
      initials: 'SM',
      streakDays: 14,
    ),
    LeaderboardUser(
      name: 'David K.',
      badge: 'Keto King',
      xp: 12500,
      rank: 1,
      avatarColor: Color(0xFF4A7C59),
      initials: 'DK',
      streakDays: 21,
    ),
    LeaderboardUser(
      name: 'Elena R.',
      badge: 'Gym Pro',
      xp: 10800,
      rank: 3,
      avatarColor: Color(0xFFC4956A),
      initials: 'ER',
      streakDays: 10,
    ),
  ];

  final List<LeaderboardUser> _rest = const [
    LeaderboardUser(
      name: 'Marcus Chen',
      badge: 'Keto King',
      xp: 9240,
      rank: 4,
      avatarColor: Color(0xFF6B8E6B),
      initials: 'MC',
      streakDays: 12,
    ),
    LeaderboardUser(
      name: 'Lisa Wong',
      badge: 'Gym Rat',
      xp: 8950,
      rank: 5,
      avatarColor: Color(0xFF7B6B8E),
      initials: 'LW',
      streakDays: 8,
    ),
    LeaderboardUser(
      name: 'James Wilson',
      badge: 'Vegan Pro',
      xp: 8100,
      rank: 6,
      avatarColor: Color(0xFF5E7B8E),
      initials: 'JW',
      streakDays: 0,
    ),
    LeaderboardUser(
      name: 'Alex T.',
      badge: 'Starter',
      xp: 7820,
      rank: 7,
      avatarColor: Color(0xFF8E7B5E),
      initials: 'AT',
      streakDays: 3,
    ),
  ];

  // Current user
  static const _myRank = 42;
  static const _myXp = 5400;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPodium(),
                      _buildRankList(),
                      const SizedBox(height: 80),
                    ],
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
          _iconBtn(Icons.search_rounded),
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

  Widget _buildPodium() {
    // order: 2nd (left), 1st (center), 3rd (right)
    final ordered = [_topThree[0], _topThree[1], _topThree[2]];
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
              final user = ordered[i];
              final isFirst = user.rank == 1;
              return Expanded(
                child: Column(
                  children: [
                    // Crown for 1st
                    if (isFirst)
                      const Text('👑', style: TextStyle(fontSize: 18))
                    else
                      const SizedBox(height: 20),
                    const SizedBox(height: 4),
                    // Avatar
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
                                  ? const Color(0xFFFFCC00)
                                  : Colors.white,
                              width: isFirst ? 3 : 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user.initials,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: avatarSizes[i] * 0.28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        // Rank badge
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _rankColor(user.rank),
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                '${user.rank}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Name
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    // XP
                    Text(
                      '${_formatXp(user.xp)} XP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isFirst
                            ? const Color(0xFF2d7a4f)
                            : const Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Podium block
                    Container(
                      height: heights[i],
                      decoration: BoxDecoration(
                        color: isFirst
                            ? const Color(0xFFE8F5EE)
                            : const Color(0xFFF0F0EC),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: isFirst
                          ? const Center(
                              child: Text('🔥', style: TextStyle(fontSize: 20)),
                            )
                          : null,
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

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFCC00);
      case 2:
        return const Color(0xFFAAAAAA);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF2d7a4f);
    }
  }

  // ── Rank List ──────────────────────────────────────────────────────────────

  Widget _buildRankList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _rest.map((user) => _buildRankRow(user)).toList(),
      ),
    );
  }

  Widget _buildRankRow(LeaderboardUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E3), width: 0.5),
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 24,
            child: Text(
              '${user.rank}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888888),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: user.avatarColor,
            ),
            child: Center(
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name & badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 3),
                    Text(
                      user.badge,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // XP & streak
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatXp(user.xp),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 2),
                  Text(
                    '${user.streakDays}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE87040),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── My Rank Bar ────────────────────────────────────────────────────────────

  Widget _buildMyRankBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(color: const Color(0xFFE8E8E3), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Rank number
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2d7a4f),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  '$_myRank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4A7C59),
              ),
              child: const Center(
                child: Text(
                  'Y',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + progress bar
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'You',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.6,
                      minHeight: 4,
                      backgroundColor: const Color(0xFFF0F0EC),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2d7a4f)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // XP + top %
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatXp(_myXp),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Top 15%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2d7a4f),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatXp(int xp) {
    if (xp >= 1000) {
      final k = xp / 1000;
      return k == k.truncateToDouble()
          ? '${k.toInt()},${(xp % 1000).toString().padLeft(3, '0')}'
          : xp.toString();
    }
    return xp.toString();
  }
}