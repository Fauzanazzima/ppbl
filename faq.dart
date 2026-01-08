import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bantuan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildContactButton(label: 'Email', icon: Icons.email_outlined, color: Colors.red),
            const SizedBox(height: 12),
            _buildContactButton(label: 'Phone', icon: Icons.phone_outlined, color: Colors.blue),
            const SizedBox(height: 12),
            _buildContactButton(label: 'WhatsApp', icon: Icons.chat_bubble_outline, color: Colors.green),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: 'Temukan Pertanyaan Berbeda',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pertanyaan Populer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildQuestionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({required String label, required IconData icon, required Color color}) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: OutlinedButton.icon(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        icon: Icon(icon, color: color, size: 20),
        label: Text(label, style: TextStyle(color: color, fontSize: 14)),
      ),
    );
  }

  Widget _buildQuestionList() {
    final List<String> questions = [
      'Bagaimana cara mengatur anggaran bulanan?',
      'Bagaimana cara menggunakan fitur "Investasi"?',
      'Bagaimana cara menggunakan fitur "Tabungan"?',
      'Bagaimana cara mengatur pemasukan bulanan?',
      'Apakah data keuangan saya aman?',
    ];
    return Column(children: questions.map((q) => _buildQuestionItem(q)).toList());
  }

  Widget _buildQuestionItem(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2)))),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}