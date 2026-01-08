import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'form_transaksi.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NumberFormat fmt =
  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _dbHelper.getTransactions();
    setState(() => _transactions = data);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Transaksi"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormTransaksi()),
          );
          if (refresh == true) _load();
        },
        child: const Icon(Icons.add),
      ),
      body: _transactions.isEmpty
          ? Center(
        child: Text(
          "Belum ada transaksi",
          style: theme.textTheme.bodyMedium,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (_, i) {
          final t = _transactions[i];
          final isExpense = t['type'] == 'expense';
          final color =
          isExpense ? Colors.red : theme.colorScheme.primary;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(
                  isExpense ? Icons.south_west : Icons.north_east,
                  color: color,
                ),
              ),
              title: Text(
                t['title'],
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                DateFormat('dd MMM yyyy')
                    .format(DateTime.parse(t['created_at'])),
              ),
              trailing: Text(
                "${isExpense ? '-' : '+'} ${fmt.format(t['amount'])}",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
