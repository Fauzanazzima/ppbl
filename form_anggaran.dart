import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class FormAnggaran extends StatefulWidget {
  final Map<String, dynamic>? budget;

  const FormAnggaran({super.key, this.budget});

  @override
  State<FormAnggaran> createState() => _FormAnggaranState();
}

class _FormAnggaranState extends State<FormAnggaran> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _db = DatabaseHelper(); // FIX: satu helper saja

  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  final NumberFormat _numberFormat =
      NumberFormat.decimalPattern('id_ID');

  @override
  void initState() {
    super.initState();

    if (widget.budget != null) {
      _categoryController.text = widget.budget!['category'] ?? '';
      _amountController.text =
          _numberFormat.format(widget.budget!['limit_amount'] ?? 0);

      // FIX: aman dari null
      if (widget.budget!['start_date'] != null) {
        _startDate = DateTime.parse(widget.budget!['start_date']);
      }
      if (widget.budget!['end_date'] != null) {
        _endDate = DateTime.parse(widget.budget!['end_date']);
      }
    }
  }

  // =========================
  // PICK DATE
  // =========================
  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // =========================
  // SAVE (INI YANG SEBELUMNYA RUSAK)
  // =========================
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // FIX: cegah crash
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal wajib diisi')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal akhir tidak boleh sebelum tanggal mulai'),
        ),
      );
      return;
    }

    final int amount =
        int.parse(_amountController.text.replaceAll('.', ''));

    final data = {
      'category': _categoryController.text.trim(),
      'limit_amount': amount,
      'spent_amount': widget.budget?['spent_amount'] ?? 0,
      'start_date': _startDate!.toIso8601String(),
      'end_date': _endDate!.toIso8601String(),
    };

    try {
      if (widget.budget == null) {
        await _db.insertBudget(data); // FIX: helper benar
      } else {
        await _db.updateBudget(widget.budget!['id'], data);
      }

      if (!mounted) return;
      Navigator.pop(context, true); // FIX: trigger refresh
    } catch (e) {
      debugPrint('ERROR SIMPAN ANGGARAN: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan anggaran')),
      );
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.budget == null ? 'Tambah Anggaran' : 'Edit Anggaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// KATEGORI
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategori Anggaran',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Kategori wajib diisi'
                        : null,
              ),

              const SizedBox(height: 16),

              /// NOMINAL
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Anggaran (Rp)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final raw = value.replaceAll('.', '');
                  if (raw.isEmpty) return;

                  final formatted =
                      _numberFormat.format(int.parse(raw));

                  _amountController.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                },
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Nominal wajib diisi';
                  }
                  final n = int.tryParse(v.replaceAll('.', ''));
                  if (n == null || n <= 0) {
                    return 'Nominal tidak valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// TANGGAL MULAI
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal Mulai Anggaran'),
                subtitle: Text(
                  _startDate == null
                      ? 'Pilih tanggal'
                      : DateFormat('dd MMM yyyy').format(_startDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(true),
              ),

              /// TANGGAL AKHIR
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal Berakhir Anggaran'),
                subtitle: Text(
                  _endDate == null
                      ? 'Pilih tanggal'
                      : DateFormat('dd MMM yyyy').format(_endDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(false),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}