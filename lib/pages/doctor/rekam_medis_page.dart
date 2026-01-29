import 'package:flutter/material.dart';

class RekamMedisPage extends StatefulWidget {
  const RekamMedisPage({super.key});

  @override
  State<RekamMedisPage> createState() => _RekamMedisPageState();
}

class _RekamMedisPageState extends State<RekamMedisPage> {
  // Controller untuk menangkap input dokter
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _resepController = TextEditingController();

  @override
  Widget build(BuildContext context) { 
    // Menangkap data dari Navigator arguments
    final dynamic args = ModalRoute.of(context)!.settings.arguments;
    
    // Konversi ke Map agar aman
    final Map<String, dynamic> patientData = (args as Map<String, dynamic>?) ?? {
      'nama_pasien': 'Pasien Umum',
      'keluhan': '-',
      'status': 'Lama',
      'tanggal': 'Hari ini'
    };
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // Background konsisten
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Row(
            children: [
              SizedBox(width: 16),
              Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
              SizedBox(width: 8),
              Text("Back", style: TextStyle(color: Colors.black, fontSize: 16)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Kartu Informasi Pasien (Sesuai Gambar Kamu)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Gunakan warna abu-abu yang sangat terang (F8FAFF atau F9FAFB)
                color: const Color(0xFFF9FAFB), 
                borderRadius: BorderRadius.circular(20),
                // Hilangkan border solid, gunakan border tipis yang hampir transparan
                border: Border.all(color: Colors.black.withOpacity(0.03)),
                // Tambahkan shadow halus agar kartu terlihat "mengambang"
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
                  Text(patientData['nama_pasien'] ?? "Pasien 1", 
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Umur: 26 tahun", style: TextStyle(color: Colors.grey, fontSize: 14)), // Dummy umur
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(patientData['tanggal'] ?? "Hari ini", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Box Keluhan (Sesuai Gambar)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5FF).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Keluhan:", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(patientData['keluhan'] ?? "Demam", 
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 2. Bagian Input Rekam Medis
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Gunakan warna abu-abu yang sangat terang (F8FAFF atau F9FAFB)
                color: const Color(0xFFF9FAFB), 
                borderRadius: BorderRadius.circular(20),
                // Hilangkan border solid, gunakan border tipis yang hampir transparan
                border: Border.all(color: Colors.black.withOpacity(0.03)),
                // Tambahkan shadow halus agar kartu terlihat "mengambang"
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
                  const Text("Rekam Medis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Diagnosis
                  const Text("Diagnosis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),
                  _buildInputField(_diagnosisController, "Detail diagnosis...."),

                  const SizedBox(height: 20),

                  // Resep Obat
                  const Text("Resep Obat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),
                  _buildInputField(
                    _resepController, 
                    "Medication name, dosage, duration\nExample: Paracetamol 500mg, 2 tablets twice daily, 5 days",
                    maxLines: 5
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 3. Tombol Input (Sesuai warna Hijau di gambar kamu)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _saveToFirebase(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ecc71), // Hijau sesuai gambar
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Input Rekam Medis", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, {int maxLines = 3}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.all(15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF3F6DF6)),
        ),
      ),
    );
  }

  void _saveToFirebase() {
    // Simulasi simpan data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(backgroundColor: Colors.green, content: Text("Data Rekam Medis Berhasil Disimpan")),
    );
    Navigator.pop(context);
  }
}