import 'package:flutter/material.dart';

class QueueInfoPage extends StatelessWidget {
  const QueueInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// BOTTOM NAV
      bottomNavigationBar: _bottomNav(),

      appBar: AppBar(
        title: const Text('Informasi Antrean'),
        leading: BackButton(),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _queueCard(),
            const SizedBox(height: 16),
            _noteCard(),
            const Spacer(),
            _cancelButton(context),
          ],
        ),
      ),
    );
  }

  // ================= MAIN CARD =================

  Widget _queueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF3F6DF6)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Dr. Floyd Miles, Poli Gigi',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Gedung A, Ruangan 201',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          /// COUNTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _queueCircle('14', 'Antrean sekarang'),
              _queueCircle('20', 'Antrean anda'),
            ],
          ),

          const SizedBox(height: 20),

          /// PROGRESS
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: 0.7,
                minHeight: 6,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF3F6DF6)),
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Mulai', style: TextStyle(fontSize: 12)),
                  Text('Sisa 6 antrean', style: TextStyle(fontSize: 12)),
                  Text('Anda', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// ESTIMASI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.access_time, size: 18),
                SizedBox(width: 8),
                Text('Estimasi menunggu: 30 menit'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _queueCircle(String value, String label) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF8EA6FF),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _noteCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Note: Please arrive 10 minutes before your estimated time. '
        'You\'ll receive a notification when it\'s your turn.',
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _cancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          _showCancelConfirmation(context);
        },
        child: const Text(
          'Batalkan Antrean',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Icon(Icons.home_outlined, color: Color(0xFF3F6DF6)),
            Icon(Icons.person_outline, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

void _showCancelConfirmation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Antrean?'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan antrean ini? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // tutup dialog
              _cancelQueue(context);
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      );
    },
  );
}

void _cancelQueue(BuildContext context) {
  // TODO: call API batalkan antrean

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Antrean berhasil dibatalkan'),
      backgroundColor: Colors.green,
    ),
  );

  Navigator.pop(context); // kembali ke dashboard pasien
}
