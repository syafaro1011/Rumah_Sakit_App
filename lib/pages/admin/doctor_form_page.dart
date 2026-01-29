import 'package:flutter/material.dart';
import '/model/doctor_model.dart';
import 'package:rumahsakitapp/services/admin_service.dart';

class DoctorFormPage extends StatefulWidget {
  final DoctorModel? initialDoctor;

  const DoctorFormPage({super.key, this.initialDoctor});

  @override
  State<DoctorFormPage> createState() => _DoctorFormPageState();
}

class _DoctorFormPageState extends State<DoctorFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input teks
  late TextEditingController nameController;
  late TextEditingController experienceController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController sipController;
  late TextEditingController phoneController;
  late TextEditingController
  photoUrlController; // Controller baru untuk link gambar

  String? selectedSpecialist;
  late List<DoctorSchedule> schedules;

  final List<String> specialists = [
    'Poli Umum',
    'Poli Gigi',
    'Poli Saraf',
    'Poli Anak',
    'Poli Mata',
    'Poli THT',
  ];

  final List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  bool get isEdit => widget.initialDoctor != null;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDoctor;

    nameController = TextEditingController(text: d?.nama);
    experienceController = TextEditingController(text: d?.experience);
    emailController = TextEditingController(text: d?.email);
    passwordController = TextEditingController(text: d?.password);
    sipController = TextEditingController(text: d?.sip);
    phoneController = TextEditingController(text: d?.phone);
    photoUrlController = TextEditingController(
      text: d?.photoUrl,
    ); // Inisialisasi URL

    selectedSpecialist = d?.poli;
    schedules = d != null ? List.from(d.schedules) : [];
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final adminService = AdminService();

      if (isEdit) {
        String uid = widget.initialDoctor!.id;

        // 1. Update data langsung ke Firestore (Menggunakan link dari controller)
        await adminService.updateDoctor(uid, {
          'nama': nameController.text,
          'poli': selectedSpecialist,
          'experience': experienceController.text,
          'no_hp': phoneController.text,
          'no_SIP': sipController.text,
          'photoUrl': photoUrlController.text,
        });

        // 2. Update Jadwal
        await adminService.deleteAllJadwal(uid);
        for (var s in schedules) {
          await adminService.createJadwalDokter(
            dokterId: uid,
            hari: s.day,
            jamMulai:
                '${s.start.hour.toString().padLeft(2, '0')}:${s.start.minute.toString().padLeft(2, '0')}',
            jamSelesai:
                '${s.end.hour.toString().padLeft(2, '0')}:${s.end.minute.toString().padLeft(2, '0')}',
          );
        }
      } else {
        // Logika TAMBAH BARU
        final newDoctor = DoctorModel(
          id: '',
          nama: nameController.text,
          poli: selectedSpecialist!,
          sip: sipController.text,
          email: emailController.text,
          password: passwordController.text,
          phone: phoneController.text,
          experience: experienceController.text,
          isActive: true,
          schedules: schedules,
          photoUrl: photoUrlController.text, // Mengambil link dari input
        );

        await adminService.createDoctor(
          newDoctor,
        ); // Sekarang hanya butuh 1 parameter
      }

      if (mounted) {
        Navigator.pop(context); // Tutup Loading
        Navigator.pop(context, true); // Kembali ke list
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Dokter' : 'Tambah Dokter'),
        backgroundColor: const Color(0xFF3F6DF6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(),
              const SizedBox(height: 20),
              _imagePreviewWidget(), // Preview Gambar
              _field('Nama Lengkap *', nameController),
              _dropdown(),
              _field('Pengalaman', experienceController, hint: '10 Tahun'),
              _field('Email *', emailController),
              _passwordField(),
              _field('SIP *', sipController),
              _field('Nomor Telepon *', phoneController),
              _field(
                'Link Foto (URL)',
                photoUrlController,
                hint: 'https://link-gambar.com/foto.jpg',
              ),

              const SizedBox(height: 24),
              _scheduleHeader(),
              ..._scheduleList(),

              const SizedBox(height: 32),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _imagePreviewWidget() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF3F6DF6), width: 3),
        ),
        child: ClipOval(
          child: ValueListenableBuilder(
            valueListenable: photoUrlController,
            builder: (context, value, child) {
              final url = photoUrlController.text;
              if (url.isEmpty) {
                return const Icon(
                  Icons.person,
                  size: 60,
                  color: Color(0xFF3F6DF6),
                );
              }
              return Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50, color: Colors.red),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        validator: (v) => (label.contains('*') && (v == null || v.isEmpty))
            ? 'Wajib diisi'
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onChanged: (v) {
          if (c == photoUrlController)
            setState(() {}); // Refresh preview khusus untuk URL
        },
      ),
    );
  }

  Widget _passwordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: passwordController,
        obscureText: true,
        validator: (v) =>
            (!isEdit && (v == null || v.isEmpty)) ? 'Wajib diisi' : null,
        decoration: InputDecoration(
          labelText: isEdit ? 'Password Baru (Opsional)' : 'Password *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ... (Widget _title, _dropdown, _scheduleHeader, _scheduleList, _time, _submitButton, _addSchedule tetap sama dengan sebelumnya)
  // [Kode di bawah ini disingkat untuk efisiensi, gunakan implementasi sebelumnya]

  Widget _title() => Text(
    isEdit ? 'Edit Data Dokter' : 'Input Data Dokter',
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  );

  Widget _dropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: selectedSpecialist,
        items: specialists
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => selectedSpecialist = v),
        validator: (v) => v == null ? 'Wajib dipilih' : null,
        decoration: InputDecoration(
          labelText: 'Spesialis',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _scheduleHeader() {
    return Row(
      children: [
        const Text(
          'Jadwal Praktik',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: _addSchedule,
          icon: const Icon(Icons.add),
          label: const Text('Tambah'),
        ),
      ],
    );
  }

  List<Widget> _scheduleList() {
    return List.generate(schedules.length, (i) {
      final s = schedules[i];
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: s.day,
                isExpanded: true,
                items: days
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => s.day = v!),
              ),
            ),
            _time(s.start, (t) => setState(() => s.start = t)),
            const Text(' - '),
            _time(s.end, (t) => setState(() => s.end = t)),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => setState(() => schedules.removeAt(i)),
            ),
          ],
        ),
      );
    });
  }

  Widget _time(TimeOfDay t, Function(TimeOfDay) onPick) {
    return InkWell(
      onTap: () async {
        final r = await showTimePicker(context: context, initialTime: t);
        if (r != null) onPick(r);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(t.format(context)),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3F6DF6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _submit,
        child: Text(
          isEdit ? 'Simpan Perubahan' : 'Tambah Dokter',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  void _addSchedule() {
    setState(() {
      schedules.add(
        DoctorSchedule(
          day: days.first,
          start: const TimeOfDay(hour: 8, minute: 0),
          end: const TimeOfDay(hour: 13, minute: 0),
        ),
      );
    });
  }
}
