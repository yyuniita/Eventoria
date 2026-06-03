import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CreateEventScreen extends StatefulWidget {
  final Map<String, dynamic>? existingEvent;
  const CreateEventScreen({super.key, this.existingEvent});

  bool get isEditing => existingEvent != null;

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Controllers
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _maxCapacityCtrl = TextEditingController();

  // State
  File? _posterFile;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _category = 'Konser';
  bool _isSaving = false;
  bool _isPublishing = false;

  // Tiket (bisa lebih dari satu jenis)
  final List<Map<String, dynamic>> _ticketTypes = [
    {'name': 'Regular', 'price': TextEditingController(), 'quota': TextEditingController()},
  ];

  final List<String> _categories = ['Konser', 'Seminar', 'Festival', 'Workshop', 'Olahraga', 'Pameran', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final e = widget.existingEvent!;
      _titleCtrl.text = e['title'] ?? '';
      _locationCtrl.text = e['location'] ?? '';
      _ticketTypes[0]['price'].text = '${e['price'] ?? 0}';
      _maxCapacityCtrl.text = '${e['totalTickets'] ?? ''}';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _maxCapacityCtrl.dispose();
    for (final t in _ticketTypes) {
      (t['price'] as TextEditingController).dispose();
      (t['quota'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  // ─── Upload poster ─────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() => _posterFile = File(picked.path));
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              const Text('Upload Poster', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Kamera'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeri'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
              ),
              if (_posterFile != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Hapus Poster', style: TextStyle(color: Colors.red)),
                  onTap: () { Navigator.pop(context); setState(() => _posterFile = null); },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Pilih tanggal & waktu ─────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ─── Kelola tiket ──────────────────────────────────────────────────────────
  void _addTicketType() {
    setState(() {
      _ticketTypes.add({
        'name': 'VIP',
        'price': TextEditingController(),
        'quota': TextEditingController(),
      });
    });
  }

  void _removeTicketType(int index) {
    if (_ticketTypes.length <= 1) return;
    final t = _ticketTypes.removeAt(index);
    (t['price'] as TextEditingController).dispose();
    (t['quota'] as TextEditingController).dispose();
    setState(() {});
  }

  // ─── Simpan / Publish ──────────────────────────────────────────────────────
  Future<void> _save({bool publish = false}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => publish ? _isPublishing = true : _isSaving = true);

    // TODO: Ganti dengan panggilan API sungguhan
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() { _isSaving = false; _isPublishing = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(publish ? 'Event berhasil dipublish!' : 'Draft tersimpan'),
          backgroundColor: publish ? Colors.green : Colors.grey.shade700,
        ),
      );
      if (publish) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Event' : 'Buat Event Baru'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => _save(),
            child: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Simpan Draft'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPosterSection(),
            const SizedBox(height: 20),
            _buildSectionTitle('Informasi Event'),
            _buildTextField(_titleCtrl, 'Nama Event', Icons.title, isRequired: true),
            const SizedBox(height: 12),
            _buildCategoryDropdown(),
            const SizedBox(height: 12),
            _buildTextField(_descCtrl, 'Deskripsi event...', Icons.description, maxLines: 4),
            const SizedBox(height: 20),
            _buildSectionTitle('Waktu & Lokasi'),
            _buildDateTimePicker(),
            const SizedBox(height: 12),
            _buildTextField(_locationCtrl, 'Lokasi / Venue', Icons.location_on_outlined, isRequired: true),
            const SizedBox(height: 12),
            _buildTextField(_maxCapacityCtrl, 'Kapasitas Total', Icons.people_outline,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
            const SizedBox(height: 20),
            _buildSectionTitle('Tiket & Harga', action: TextButton.icon(
              onPressed: _addTicketType,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Tambah Jenis'),
            )),
            ..._ticketTypes.asMap().entries.map((e) => _buildTicketCard(e.key, e.value)),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _isPublishing ? null : () => _save(publish: true),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: _isPublishing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    widget.isEditing ? 'Simpan Perubahan' : 'Publish Event',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  // ─── Widgets builder ───────────────────────────────────────────────────────

  Widget _buildPosterSection() {
    return GestureDetector(
      onTap: _showImagePickerSheet,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          image: _posterFile != null
              ? DecorationImage(image: FileImage(_posterFile!), fit: BoxFit.cover)
              : null,
        ),
        child: _posterFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 44, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text('Upload Poster Event', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('Tap untuk memilih foto', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: FilledButton.tonal(
                    onPressed: _showImagePickerSheet,
                    style: FilledButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                    child: const Text('Ganti', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: isRequired
          ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null
          : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) => setState(() => _category = v!),
    );
  }

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(
              _selectedDate == null
                  ? 'Pilih Tanggal'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              style: TextStyle(color: _selectedDate == null ? Colors.grey : null),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.access_time_outlined, size: 18),
            label: Text(
              _selectedTime == null ? 'Pilih Waktu' : _selectedTime!.format(context),
              style: TextStyle(color: _selectedTime == null ? Colors.grey : null),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketCard(int index, Map<String, dynamic> ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.confirmation_num_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Jenis Tiket ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_ticketTypes.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _removeTicketType(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: ticket['name'],
              decoration: InputDecoration(
                hintText: 'Nama jenis tiket (misal: VIP, Regular)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
              onChanged: (v) => ticket['name'] = v,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: ticket['price'] as TextEditingController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Harga (0 = Gratis)',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: ticket['quota'] as TextEditingController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Kuota',
                      suffixText: 'tiket',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
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
}