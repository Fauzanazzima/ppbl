import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'form_anggaran.dart';

class FormTransaksi extends StatefulWidget {
  final Map<String, dynamic>? transaksi;

  const FormTransaksi({super.key, this.transaksi});

  @override
  State<FormTransaksi> createState() => _FormTransaksiPageState();
}

class _FormTransaksiPageState extends State<FormTransaksi> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  int? _selectedBudgetId;
  String _selectedType = "expense";
  List<Map<String, dynamic>> _budgets = [];

  @override
  void initState() {
    super.initState();
    _loadBudgets();

    if (widget.transaksi != null) {
      _titleController.text = widget.transaksi!["title"] ?? "";
      _amountController.text =
          widget.transaksi!["amount"]?.toString() ?? "";
      _selectedBudgetId = widget.transaksi!["budget_id"];
      _selectedType = widget.transaksi!["type"] ?? "expense";
    }
  }

  Future<void> _loadBudgets() async {
    final data = await DatabaseHelper().getBudgets();
    setState(() => _budgets = data);
  }

  Future<void> _saveTransaksi() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "title": _titleController.text.trim(),
      "amount": int.parse(_amountController.text.trim()),
      "type": _selectedType,
      "budget_id": _selectedBudgetId,
      "created_at": DateTime.now().toIso8601String(),
    };

    final db = DatabaseHelper();

    if (widget.transaksi == null) {
      await db.insertTransaction(data);
      if (_selectedType == "expense") {
        await db.updateBudgetSpent(_selectedBudgetId!, data["amount"] as int);
      }
    } else {
      await db.updateTransaction(widget.transaksi!["id"], data);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _tambahKategoriBaru() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormAnggaran()),
    );
    if (res == true) _loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.transaksi == null ? "Tambah Transaksi" : "Edit Transaksi",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Informasi Transaksi"),
              const SizedBox(height: 20),

              _inputLabel("Nama Transaksi"),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration(
                  context,
                  "Misal: Makan Siang",
                  Icons.edit_note,
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Wajib diisi" : null,
              ),

              const SizedBox(height: 20),

              _inputLabel("Nominal (Rp)"),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration:
                _inputDecoration(context, "0", Icons.payments_outlined),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Wajib diisi";
                  if (int.tryParse(v) == null) return "Masukkan angka valid";
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _inputLabel("Jenis Transaksi"),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration:
                _inputDecoration(context, "", Icons.swap_vert_circle),
                items: const [
                  DropdownMenuItem(
                      value: "income", child: Text("Pemasukan")),
                  DropdownMenuItem(
                      value: "expense", child: Text("Pengeluaran")),
                ],
                onChanged: (v) => setState(() => _selectedType = v!),
              ),

              const SizedBox(height: 20),

              _inputLabel("Kategori Anggaran"),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedBudgetId,
                      decoration: _inputDecoration(
                          context, "Pilih kategori", Icons.pie_chart),
                      items: _budgets.map((b) {
                        return DropdownMenuItem<int>(
                          value: b["id"],
                          child: Text(b["category"]),
                        );
                      }).toList(),
                      validator: (v) =>
                      v == null ? "Kategori wajib dipilih" : null,
                      onChanged: (v) =>
                          setState(() => _selectedBudgetId = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _tambahKategoriBaru,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border:
                        Border.all(color: primary.withOpacity(0.4)),
                      ),
                      child: Icon(Icons.add, color: primary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveTransaksi,
                  child: const Text(
                    "SIMPAN TRANSAKSI",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =======================
  // COMPONENT KECIL
  // =======================

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _inputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _inputDecoration(
      BuildContext context, String hint, IconData icon) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      prefixIcon:
      Icon(icon, color: theme.colorScheme.primary),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
