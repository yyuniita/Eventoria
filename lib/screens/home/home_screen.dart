import 'package:flutter/material.dart';
import 'package:eventoria/core/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  int _selectedNav = 0;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Semua', 'icon': Icons.grid_view_rounded},
    {'label': 'Musik', 'icon': Icons.music_note_rounded},
    {'label': 'Pameran', 'icon': Icons.palette_rounded},
    {'label': 'Olahraga', 'icon': Icons.directions_run_rounded},
    {'label': 'Wahana', 'icon': Icons.attractions_rounded},
  ];

  final List<Map<String, dynamic>> _events = [
    {
      'title': 'Konser Indie Makassar 2025',
      'category': 'Musik',
      'date': '15 Jun 2025',
      'price': 'Rp 150.000',
      'icon': Icons.music_note_rounded,
      'color': Color(0xFF6C63FF),
    },
    {
      'title': 'Art Exhibition Sulawesi',
      'category': 'Pameran',
      'date': '20 Jun 2025',
      'price': 'Rp 75.000',
      'icon': Icons.palette_rounded,
      'color': Color(0xFF03DAC6),
    },
    {
      'title': 'Fun Run Losari 5K',
      'category': 'Olahraga',
      'date': '1 Jul 2025',
      'price': 'Rp 50.000',
      'icon': Icons.directions_run_rounded,
      'color': Color(0xFFFF6384),
    },
    {
      'title': 'Wahana Anak Makassar',
      'category': 'Wahana',
      'date': '10 Jul 2025',
      'price': 'Rp 35.000',
      'icon': Icons.attractions_rounded,
      'color': Color(0xFFFFA500),
    },
  ];

  final List<String> _regions = [
    'Sulawesi', 'Jabodetabek', 'Jawa Barat',
    'Jawa Timur', 'Sumatera', 'Kalimantan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    _buildBanner(),
                    _buildCategories(),
                    _buildSectionHeader('Event Populer', 'Lihat semua'),
                    _buildEventCards(),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Jelajah per Wilayah', 'Lihat semua'),
                    _buildRegions(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: const Color(0xFF0D0D14),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'EVENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    TextSpan(
                      text: 'ORIA',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 12, color: Color(0xFF6C63FF)),
                  const SizedBox(width: 3),
                  Text(
                    'Makassar, Sulawesi',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Stack(
            children: [
              _iconBtn(Icons.notifications_none_rounded),
              Positioned(
                top: 6, right: 6,
                child: Container(
                  width: 7, height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary, width: 1.5),
              color: AppTheme.primary.withOpacity(0.2),
            ),
            child: const Icon(Icons.person_outline_rounded,
                color: Color(0xFF6C63FF), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      color: const Color(0xFF16161F),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 18),
  );

  // ── SEARCH BAR ───────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF16161F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded,
                color: Colors.white.withOpacity(0.3), size: 20),
            const SizedBox(width: 10),
            Text(
              'Cari event, konser, pameran...',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 13),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: Color(0xFF6C63FF), size: 16),
            ),
          ],
        ),
      ),
    );
  }

  // ── BANNER ───────────────────────────────────────────
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Event Pilihan',
                    style: TextStyle(
                        color: Color(0xFF9d97ff), fontSize: 10)),
                ),
                const SizedBox(height: 8),
                const Text('Temukan Event\nSeru di Kotamu!',
                  style: TextStyle(
                    color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w700, height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Konser, pameran, olahraga & lebih banyak lagi',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 12)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.explore_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('Jelajah Sekarang',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF0D0D14),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _bannerPill(Icons.music_note_rounded, 'Musik', AppTheme.primary),
                _bannerPill(Icons.palette_rounded, 'Pameran', AppTheme.secondary),
                _bannerPill(Icons.directions_run_rounded, 'Olahraga',
                    const Color(0xFFFF6384)),
                _bannerPill(Icons.attractions_rounded, 'Wahana',
                    const Color(0xFFFFA500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerPill(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11,
            fontWeight: FontWeight.w500)),
      ],
    ),
  );

  // ── CATEGORIES ───────────────────────────────────────
  Widget _buildCategories() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isActive = _selectedCategory == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primary
                    : const Color(0xFF16161F),
                borderRadius: BorderRadius.circular(20),
                border: isActive
                    ? null
                    : Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Icon(_categories[i]['icon'] as IconData,
                      size: 14,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.4)),
                  const SizedBox(width: 5),
                  Text(_categories[i]['label'] as String,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── SECTION HEADER ───────────────────────────────────
  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Text(title,
            style: const TextStyle(
                color: Colors.white, fontSize: 15,
                fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(action,
            style: const TextStyle(
                color: Color(0xFF6C63FF), fontSize: 12)),
        ],
      ),
    );
  }

  // ── EVENT CARDS ──────────────────────────────────────
  Widget _buildEventCards() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _events.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final e = _events[i];
          final color = e['color'] as Color;
          return Container(
            width: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF16161F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Icon(e['icon'] as IconData,
                        color: color, size: 38),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(e['category'] as String,
                          style: TextStyle(
                              color: color, fontSize: 10,
                              fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 5),
                      Text(e['title'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12,
                            fontWeight: FontWeight.w600, height: 1.3)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 10,
                              color: Colors.white.withOpacity(0.4)),
                          const SizedBox(width: 3),
                          Text(e['date'] as String,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(e['price'] as String,
                        style: const TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── REGIONS ──────────────────────────────────────────
  Widget _buildRegions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _regions.map((r) => Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF16161F),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 14, color: Color(0xFF6C63FF)),
              const SizedBox(width: 5),
              Text(r,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // ── BOTTOM NAV ───────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Beranda'},
      {'icon': Icons.explore_rounded, 'label': 'Jelajah'},
      {'icon': Icons.confirmation_number_rounded, 'label': 'Tiket'},
      {'icon': Icons.person_rounded, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        border: Border(top: BorderSide(
            color: Colors.white.withOpacity(0.08), width: 0.5)),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isActive = _selectedNav == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedNav = i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[i]['icon'] as IconData,
                  size: 24,
                  color: isActive
                      ? AppTheme.primary
                      : Colors.white.withOpacity(0.3)),
                const SizedBox(height: 3),
                Text(items[i]['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive
                        ? AppTheme.primary
                        : Colors.white.withOpacity(0.3),
                  )),
              ],
            ),
          );
        }),
      ),
    );
  }
}