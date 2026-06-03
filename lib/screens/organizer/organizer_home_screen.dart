import 'package:flutter/material.dart';
import 'package:eventoria/models/user_model.dart';
import 'package:eventoria/models/event_model.dart';
import 'package:eventoria/services/auth_service.dart';
import 'package:eventoria/services/api_service.dart';
import 'package:eventoria/screens/organizer/create_event_screen.dart';
import 'package:eventoria/screens/auth/login_screen.dart';

class OrganizerHomeScreen extends StatefulWidget {
  const OrganizerHomeScreen({super.key});

  @override
  State<OrganizerHomeScreen> createState() => _OrganizerHomeScreenState();
}

class _OrganizerHomeScreenState extends State<OrganizerHomeScreen> {
  int _currentIndex = 0;
  UserModel? _currentUser;
  List<EventModel> _myEvents = [];
  bool _loadingEvents = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadMyEvents();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) setState(() => _currentUser = user);
  }

  Future<void> _loadMyEvents() async {
    setState(() => _loadingEvents = true);
    try {
      final data = await ApiService.getMyEvents();
      setState(() {
        _myEvents = data.map((e) => EventModel.fromJson(e)).toList();
        _loadingEvents = false;
      });
    } catch (e) {
      setState(() => _loadingEvents = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun organizer?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildMyEventsTab(),
          _buildCreateTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Event Saya'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Buat Event'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  // ─── Tab 1: Daftar event milik organizer ───────────────────────────────────
  Widget _buildMyEventsTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Dashboard Organizer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3B37C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMyEvents),
            IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          ],
        ),
        SliverToBoxAdapter(child: _buildStatsSummary()),
        if (_loadingEvents)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_myEvents.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Belum ada event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Tap "Buat Event" untuk mulai', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildEventCard(_myEvents[i]),
                childCount: _myEvents.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsSummary() {
    // ✅ Pakai field EventModel langsung, bukan Map
    final totalSold = _myEvents.fold<int>(0, (sum, e) => sum + e.ticketsSold);
    final totalRevenue = _myEvents.fold<int>(0, (sum, e) => sum + (e.ticketsSold * e.price));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9C8FFF)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _statItem('Total Event', '${_myEvents.length}', Icons.event),
          _divider(),
          _statItem('Tiket Terjual', '$totalSold', Icons.confirmation_num),
          _divider(),
          _statItem('Pendapatan', 'Rp${_formatNumber(totalRevenue)}', Icons.payments),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 40, color: Colors.white24);

  // ✅ Parameter sekarang EventModel, bukan Map
  Widget _buildEventCard(EventModel event) {
    final isDraft = event.status == 'draft';
    // Warna poster: pakai posterColor dari model, fallback ke warna default
    final cardColor = _parseColor(event.posterColor) ?? const Color(0xFF6C63FF);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: [
          // Poster
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.image_outlined, color: Colors.white38, size: 40)),
                if (isDraft)
                  Positioned(
                    top: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                      child: const Text('Draft', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(event.eventDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 12),
                  const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(event.location,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis),
                  ),
                ]),
                const SizedBox(height: 10),
                // Progress tiket — pakai getter dari EventModel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${event.ticketsSold} / ${event.totalTickets} tiket terjual',
                      style: const TextStyle(fontSize: 12)),
                    Text('${(event.salesProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: event.salesProgress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(cardColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(event.formattedPrice,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openEditEvent(event),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _viewAttendees(event),
                        icon: const Icon(Icons.people_outline, size: 16),
                        label: const Text('Peserta'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openEditEvent(EventModel event) {
    // Konversi EventModel ke Map untuk dikirim ke CreateEventScreen
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => CreateEventScreen(existingEvent: {
        'id': event.id,
        'title': event.title,
        'description': event.description ?? '',
        'location': event.location,
        'event_date': event.eventDate,
        'total_tickets': event.totalTickets,
        'price': event.price,
        'category': event.category,
        'status': event.status,
      }),
    )).then((_) => _loadMyEvents()); // refresh setelah edit
  }

  void _viewAttendees(EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        builder: (_, controller) => Column(
          children: [
            Container(width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Text('Peserta: ${event.title}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('${event.ticketsSold} orang terdaftar',
              style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: event.ticketsSold,
                itemBuilder: (_, i) => ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text('Peserta ${i + 1}'),
                  subtitle: Text('peserta${i + 1}@email.com'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tab 2: Buat event baru ────────────────────────────────────────────────
  Widget _buildCreateTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          const Text('Buat Event Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Isi detail event, tiket, dan upload poster', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateEventScreen()),
            ).then((_) => _loadMyEvents()), // refresh setelah buat event baru
            icon: const Icon(Icons.add),
            label: const Text('Mulai Buat Event'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
          ),
        ],
      ),
    );
  }

  // ─── Tab 3: Profil organizer ───────────────────────────────────────────────
  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  (_currentUser?.name.isNotEmpty == true) ? _currentUser!.name[0].toUpperCase() : 'O',
                  style: TextStyle(fontSize: 32, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(_currentUser?.name ?? 'Organizer', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Organizer', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w600, fontSize: 12)),
              ),
              const SizedBox(height: 6),
              Text(_currentUser?.email ?? '', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _profileMenuItem(Icons.event, 'Event Saya', () => setState(() => _currentIndex = 0)),
        _profileMenuItem(Icons.bar_chart, 'Statistik', () {}),
        _profileMenuItem(Icons.account_circle_outlined, 'Edit Profil', () {}),
        _profileMenuItem(Icons.settings_outlined, 'Pengaturan', () {}),
        const Divider(height: 32),
        _profileMenuItem(Icons.logout, 'Logout', _logout, isDestructive: true),
      ],
    );
  }

  Widget _profileMenuItem(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : null),
      title: Text(label, style: TextStyle(color: isDestructive ? Colors.red : null)),
      trailing: isDestructive ? null : const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // Helper: parse hex color string dari backend (misal: "0xFF6C63FF" atau "#6C63FF")
  Color? _parseColor(String? colorStr) {
    if (colorStr == null) return null;
    try {
      final hex = colorStr.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return null;
    }
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}jt';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}rb';
    return '$n';
  }
}