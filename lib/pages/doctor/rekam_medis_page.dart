import 'package:flutter/material.dart';
import '../../model/medical_record_model.dart';
import '../../services/doctor_service.dart';
import 'package:intl/intl.dart';

class RekamMedisPage extends StatefulWidget {
  const RekamMedisPage({super.key});

  @override
  State<RekamMedisPage> createState() => _RekamMedisPageState();
}

class _RekamMedisPageState extends State<RekamMedisPage> {
  final DoctorService _doctorService = DoctorService();

  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _resepController = TextEditingController();

  final TextEditingController _biayaKonsultasiController =
      TextEditingController(text: "0");
  final TextEditingController _biayaObatController = TextEditingController(
    text: "0",
  );

  int _totalHarga = 0;
  bool _isLoading = false;

  void _calculateTotal() {
    int konsultasi = int.tryParse(_biayaKonsultasiController.text) ?? 0;
    int obat = int.tryParse(_biayaObatController.text) ?? 0;
    setState(() {
      _totalHarga = konsultasi + obat;
    });
  }

  Future<void> _handleSave(String bId, String pId, String dId) async {
    if (_diagnosisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Diagnosa tidak boleh kosong!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final record = MedicalRecordModel(
        bookingId: bId,
        patientId: pId,
        doctorId: dId,
        date: DateFormat('d MMM yyyy').format(DateTime.now()),
        diagnosa: _diagnosisController.text,
        resepObat: _resepController.text,
        biayaKonsultasi: int.tryParse(_biayaKonsultasiController.text) ?? 0,
        biayaObat: int.tryParse(_biayaObatController.text) ?? 0,
        totalBayar: _totalHarga,
        createdAt: DateTime.now(),
      );

      await _doctorService.submitMedicalRecord(bookingId: bId, record: record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Pemeriksaan Selesai!"),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Jika data kosong, tampilkan loading agar tidak crash
    if (args == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String bookingId = args['bookingId'] ?? '';
    final String patientId = args['userId'] ?? '';
    final String doctorId = args['doctorId'] ?? '';
    final String namaPasien = args['nama_pasien'] ?? 'Pasien';
    final String keluhanPasien = args['keluhan'] ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          "Input Pemeriksaan",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientInfoCard(namaPasien, args['date'] ?? '-'),

                  const SizedBox(height: 20),

                  // 🔥 1. Tampilkan Keluhan Pasien sebagai referensi Dokter
                  _buildSectionCard(
                    title: "Keluhan Pasien",
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade100),
                      ),
                      child: Text(
                        keluhanPasien,
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  _buildSectionCard(
                    title: "Hasil Diagnosa",
                    child: _buildInputField(
                      _diagnosisController,
                      "Tulis diagnosa dokter di sini...",
                      maxLines: 4,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _buildSectionCard(
                    title: "Resep Obat",
                    child: _buildInputField(
                      _resepController,
                      "Nama obat, dosis, frekuensi...",
                      maxLines: 4,
                    ),
                  ),

                  const SizedBox(height: 25),

                  _buildSectionCard(
                    title: "Rincian Biaya (Rp)",
                    child: Column(
                      children: [
                        _buildNumberField(
                          _biayaKonsultasiController,
                          "Biaya Konsultasi",
                          Icons.medical_services,
                        ),
                        const SizedBox(height: 12),
                        _buildNumberField(
                          _biayaObatController,
                          "Biaya Obat-obatan",
                          Icons.medication,
                        ),
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Tagihan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'id',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(_totalHarga),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF2ecc71),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () =>
                          _handleSave(bookingId, patientId, doctorId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ecc71),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Simpan & Selesai Periksa",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget Helper tetap sama...
  Widget _buildPatientInfoCard(String nama, String tanggal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nama,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                tanggal,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) => _calculateTotal(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
