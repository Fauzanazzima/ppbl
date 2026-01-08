import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model_tabungan.dart';
import 'db_tabungan.dart';
import 'form_tabungan.dart';

class TabunganScreen extends StatefulWidget {
  const TabunganScreen({super.key});

  @override
  State<TabunganScreen> createState() => _TabunganScreenState();
}

class _TabunganScreenState extends State<TabunganScreen> {
  final NumberFormat fmt =
  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  List<SavingsModel> items = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final data = await DBTabungan().getSavings();
    setState(() => items = data.map((e) => SavingsModel.fromMap(e)).toList());
  }

  Future<void> _onAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormTabungan()),
    );
    if (result != null && result is SavingsModel) {
      await DBTabungan().insertSavings(result.toMap());
      _refresh();
    }
  }

  Future<void> _onEdit(SavingsModel s) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormTabungan(editing: s)),
    );
    if (result != null && result is SavingsModel) {
      await DBTabungan().updateSavings(s.id!, result.toMap());
      _refresh();
    }
  }

  Future<void> _onDelete(int id) async {
    await DBTabungan().deleteSavings(id);
    _refresh();
  }

  double _progress(SavingsModel s) {
    if (s.targetAmount <= 0) return 0;
    return (s.currentAmount / s.targetAmount).clamp(0, 1);
  }

  Map<String, int> _categorySummary() {
    final map = <String, int>{};
    for (var s in items) {
      map[s.category] = (map[s.category] ?? 0) + s.currentAmount;
    }
    return map;
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case "Pendidikan":
        return Icons.school;
      case "Gadget":
        return Icons.devices_other;
      case "Liburan":
        return Icons.beach_access;
      case "Rumah":
        return Icons.home_filled;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primary = theme.primaryColor;
    final catSum = _categorySummary();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tabungan"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...items.map((s) => _savingCard(context, s)).toList(),
          const SizedBox(height: 22),
          Text(
            "Rangkuman Kategori Tabungan",
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3 / 2.3,
            children: [
              _summaryCard(context, "Pendidikan", catSum["Pendidikan"] ?? 0),
              _summaryCard(context, "Liburan", catSum["Liburan"] ?? 0),
              _summaryCard(context, "Gadget", catSum["Gadget"] ?? 0),
              _summaryCard(context, "Rumah", catSum["Rumah"] ?? 0),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: const Icon(Icons.add),
      ),
    );
  }

  // SAVING CARD

  Widget _savingCard(BuildContext context, SavingsModel s) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primary = theme.primaryColor;
    final prog = _progress(s);

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: primary.withOpacity(0.15),
                  child: Icon(_categoryIcon(s.category), color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s.title,
                    style: textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == "edit") _onEdit(s);
                    if (v == "delete") _onDelete(s.id!);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "edit", child: Text("Edit")),
                    PopupMenuItem(value: "delete", child: Text("Hapus")),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "${s.startDate} - ${s.endDate}",
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: prog,
              minHeight: 9,
              backgroundColor: primary.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(primary),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fmt.format(s.currentAmount),
                  style: textTheme.titleMedium?.copyWith(color: primary),
                ),
                Text(
                  fmt.format(s.targetAmount),
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "${(prog * 100).toStringAsFixed(0)}% tercapai",
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  //SUMMARY CARD

  Widget _summaryCard(BuildContext context, String title, int amount) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primary = theme.primaryColor;

    return Card(
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: primary.withOpacity(0.15),
              child: Icon(_categoryIcon(title), color: primary),
            ),
            const SizedBox(height: 8),
            Text(title, style: textTheme.titleMedium),
            Text(
              fmt.format(amount),
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
