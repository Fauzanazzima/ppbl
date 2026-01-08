import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model_tabungan.dart';

class FormTabungan extends StatefulWidget {
  final SavingsModel? editing;
  const FormTabungan({super.key, this.editing});

  @override
  State<FormTabungan> createState() => _FormTabunganState();
}

class _FormTabunganState extends State<FormTabungan> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _currentCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();

  String _category = "Pendidikan";
  final dateFormat = DateFormat("yyyy-MM-dd");

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      final s = widget.editing!;
      _titleCtrl.text = s.title;
      _currentCtrl.text = NumberFormat.decimalPattern('id').format(s.currentAmount);
      _targetCtrl.text = NumberFormat.decimalPattern('id').format(s.targetAmount);
      _startDateCtrl.text = s.startDate;
      _endDateCtrl.text = s.endDate;
      _category = s.category;
    }
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(ctrl.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      ctrl.text = dateFormat.format(selected);
    }
  }

  int _cleanNumber(String text) {
    return int.tryParse(text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.editing == null ? "Tambah Tabungan" : "Edit Tabungan"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Informasi Tabungan"),

              _label("Nama Tabungan"),
              TextFormField(
                controller: _titleCtrl,
                decoration: _inputDecoration(
                  context,
                  "Misal: Tabungan Liburan",
                  Icons.savings_outlined,
                ),
                validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
              ),

              const SizedBox(height: 20),
              _label("Target (Rp)"),
              TextFormField(
                controller: _targetCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  context,
                  "0",
                  Icons.flag_outlined,
                ),
                onChanged: _formatCurrency(_targetCtrl),
                validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
              ),

              const SizedBox(height: 20),
              _label("Jumlah Saat Ini (Rp)"),
              TextFormField(
                controller: _currentCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  context,
                  "0",
                  Icons.account_balance_wallet_outlined,
                ),
                onChanged: _formatCurrency(_currentCtrl),
                validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
              ),

              const SizedBox(height: 20),
              _label("Periode Tabungan"),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateCtrl,
                      readOnly: true,
                      decoration: _inputDecoration(
                        context,
                        "Mulai",
                        Icons.calendar_month_outlined,
                      ),
                      onTap: () => _pickDate(_startDateCtrl),
                      validator: (v) => v == null || v.isEmpty ? "Wajib dipilih" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _endDateCtrl,
                      readOnly: true,
                      decoration: _inputDecoration(
                        context,
                        "Berakhir",
                        Icons.event_outlined,
                      ),
                      onTap: () => _pickDate(_endDateCtrl),
                      validator: (v) => v == null || v.isEmpty ? "Wajib dipilih" : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _label("Kategori"),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: _inputDecoration(
                  context,
                  "Pilih kategori",
                  Icons.category_outlined,
                ),
                items: const [
                  DropdownMenuItem(value: "Pendidikan", child: Text("Pendidikan")),
                  DropdownMenuItem(value: "Gadget", child: Text("Gadget")),
                  DropdownMenuItem(value: "Liburan", child: Text("Liburan")),
                  DropdownMenuItem(value: "Rumah", child: Text("Rumah")),
                ],
                onChanged: (v) => setState(() => _category = v!),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    final model = SavingsModel(
                      id: widget.editing?.id,
                      title: _titleCtrl.text.trim(),
                      currentAmount: _cleanNumber(_currentCtrl.text),
                      targetAmount: _cleanNumber(_targetCtrl.text),
                      category: _category,
                      startDate: _startDateCtrl.text,
                      endDate: _endDateCtrl.text,
                    );

                    Navigator.pop(context, model);
                  },
                  child: Text(
                    widget.editing == null
                        ? "SIMPAN TABUNGAN"
                        : "UPDATE TABUNGAN",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // COMPONENT

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _label(String text) {
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
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Function(String) _formatCurrency(TextEditingController ctrl) {
    return (value) {
      final cleaned = value.replaceAll('.', '').replaceAll(',', '');
      if (cleaned.isEmpty) return;
      final formatted =
      NumberFormat.decimalPattern('id').format(int.parse(cleaned));
      ctrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    };
  }
}
