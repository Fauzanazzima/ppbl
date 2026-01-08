import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'custom_widget.dart';
import 'form_anggaran.dart';
import 'form_transaksi.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> _budgets = [];
  int _totalAllocated = 0;
  int _totalSpent = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      await _refreshBudgets();
      await _refreshTotals();
    } catch (e) {
      debugPrint('ERROR LOAD DATA: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshBudgets() async {
    final data = await _dbHelper.getBudgets();
    final List<Map<String, dynamic>> result = [];

    for (final item in data) {
      final int allocated = (item['limit_amount'] as num).toInt();
      final int spent =
      await _dbHelper.getTotalSpentByBudgetId(item['id']);

      result.add({
        'id': item['id'],
        'category': item['category'],
        'allocated': allocated,
        'spent': spent,
        'remaining': allocated - spent,
      });
    }

    _budgets = result;
  }

  Future<void> _refreshTotals() async {
    _totalAllocated = await _dbHelper.getTotalDialokasikan();
    _totalSpent = await _dbHelper.getTotalTerpakai();
  }

  Future<void> _openFormAnggaran({Map<String, dynamic>? item}) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormAnggaran(
          budget: item == null
              ? null
              : {
            'id': item['id'],
            'category': item['category'],
            'limit_amount': item['allocated'],
          },
        ),
      ),
    );

    if (res == true) _loadData();
  }

  Future<void> _openFormTransaksi() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormTransaksi()),
    );
    if (res == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _totalAllocated - _totalSpent;
    final progress =
    _totalAllocated == 0 ? 0.0 : _totalSpent / _totalAllocated;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggaran'),
        centerTitle: true,
        backgroundColor:  theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openFormAnggaran(),
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //  Row Info Cards
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Gesture: show snack bar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Sisa Anggaran: ${currencyFormatter.format(remaining)}'),
                      ),
                    );
                  },
                  child: InfoCard(
                    title: 'Sisa Anggaran',
                    value: currencyFormatter.format(remaining),
                    progress: progress,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Jumlah Anggaran: ${currencyFormatter.format(_totalAllocated)}'),
                      ),
                    );
                  },
                  child: InfoCard(
                    title: 'Jumlah Anggaran',
                    value: currencyFormatter.format(_totalAllocated),
                    progress: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          //  List Budget
          ..._budgets.map(
                (b) => CustomCard(
              title: b['category'],
              subtitle:
              'Dialokasikan: ${currencyFormatter.format(b['allocated'])}\n'
                  'Terpakai: ${currencyFormatter.format(b['spent'])}\n'
                  'Sisa: ${currencyFormatter.format(b['remaining'])}',
              icon: Icons.pie_chart,
              onEdit: () => _openFormAnggaran(item: b),
              onDelete: () async {
                await _dbHelper.deleteBudget(b['id']);
                _loadData();
              },
            ),
          ),
        ],
      ),
    );
  }
}

//  CUSTOM WIDGET
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final double progress;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(value,
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: primary,
              backgroundColor: primary.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}