import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';
import 'tabungan.dart';
import 'transaksi.dart';
import 'anggaran.dart';
import 'settings.dart';
import 'profile.dart';
import 'db_tabungan.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _bottomIndex = 0;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _totalTabungan = 0;
  int _totalAllocated = 0;
  int _totalSpent = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _loading = true);

    try {
      // Tabungan
      final tabunganData = await DBTabungan().getSavings();
      final totalTab = tabunganData.fold<int>(
          0, (sum, item) => sum + (item['currentAmount'] as int));

      // Anggaran
      final totalAllocated = await _dbHelper.getTotalDialokasikan();
      final totalSpent = await _dbHelper.getTotalTerpakai();

      if (!mounted) return;
      setState(() {
        _totalTabungan = totalTab;
        _totalAllocated = totalAllocated;
        _totalSpent = totalSpent;
      });
    } catch (e) {
      debugPrint("ERROR FETCH DASHBOARD DATA: $e");
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final remainingBudget = _totalAllocated - _totalSpent;
    final progressBudget =
        _totalAllocated == 0 ? 0.0 : _totalSpent / _totalAllocated;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(context),appBar: AppBar(
      backgroundColor: const Color(0xFF1D6F50), // ✅ HIJAU
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text(
        "Dashboard",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Colors.white, // ✅ teks putih
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundImage:
              NetworkImage('https://i.pravatar.cc/150?img=5'),
            ),
          ),
        ),
      ],
    ),

      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRingkasanTransaksiCard(context),
                    const SizedBox(height: 14),
                    _buildTabunganCard(context, currencyFormatter),
                    const SizedBox(height: 14),
                    _buildAnggaranCard(
                        context, currencyFormatter, remainingBudget, progressBudget),
                    const SizedBox(height: 92),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1D6F50),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bottomNavItem(
                icon: Icons.home_outlined,
                label: "Beranda",
                selected: _bottomIndex == 0,
                onTap: () => setState(() => _bottomIndex = 0),
              ),
              _bottomNavItem(
                icon: Icons.settings_outlined,
                label: "Pengaturan",
                selected: _bottomIndex == 1,
                onTap: () {
                  setState(() => _bottomIndex = 1);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? const Color(0xFF1D6F50) : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? const Color(0xFF1D6F50) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanTransaksiCard(BuildContext context) {
    const pink = Color(0xFFEFB8B4);
    const blue = Color(0xFF8DA9C4);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ringkasan Transaksi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            "Perbandingan pendapatan dan pengeluaran.",
            style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 13),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 156,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          const labels = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun"];
                          final idx = value.toInt();
                          if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                          return Text(
                            labels[idx],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9E9E9E),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 5,
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 2.5),
                        FlSpot(1, 5.0),
                        FlSpot(2, 6.0),
                        FlSpot(3, 5.4),
                        FlSpot(4, 6.8),
                        FlSpot(5, 6.2),
                      ],
                      isCurved: true,
                      color: blue,
                      barWidth: 2.6,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: blue.withOpacity(0.55),
                      ),
                    ),
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1.6),
                        FlSpot(1, 5.6),
                        FlSpot(2, 6.6),
                        FlSpot(3, 6.0),
                        FlSpot(4, 6.9),
                        FlSpot(5, 7.5),
                      ],
                      isCurved: true,
                      color: pink,
                      barWidth: 2.6,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: pink.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabunganCard(BuildContext context, NumberFormat currencyFormatter) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3EA),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tabungan Saya",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "3 target aktif",
                      style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.savings_outlined,
                  color: Color(0xFF1D6F50), size: 32),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currencyFormatter.format(_totalTabungan),
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.0,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            "Uang yang Anda kumpulkan sejauh ini.",
            style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 13),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TabunganScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Lihat Detail Tabungan",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnggaranCard(
      BuildContext context,
      NumberFormat currencyFormatter,
      int remaining,
      double progress) {
    const greenMain = Color(0xFF1D6F50);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Anggaran Bulanan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.wallet, size: 20, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Tersisa ${currencyFormatter.format(remaining)}",
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            currencyFormatter.format(_totalAllocated),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    minHeight: 12,
                    value: progress,
                    backgroundColor: const Color(0xFFEBEBEB),
                    valueColor: const AlwaysStoppedAnimation(greenMain),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BudgetPage()),
                  );
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: greenMain,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BudgetPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: greenMain),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Kelola Anggaran", style: TextStyle(color: greenMain)),
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF1D6F50),
        padding: const EdgeInsets.only(left: 18, top: 38, bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
            ),
            const SizedBox(height: 12),
            const Text("Stephen Heel",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 24),
            _drawerItem(
              icon: Icons.savings_outlined,
              label: "Tabungan",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TabunganScreen()));
              },
            ),
            const SizedBox(height: 12),
            _drawerItem(
              icon: Icons.swap_horiz,
              label: "Transaksi",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TransaksiPage()));
              },
            ),
            const SizedBox(height: 12),
            _drawerItem(
              icon: Icons.wallet_travel_outlined,
              label: "Anggaran",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BudgetPage()));
              },
            ),
            const Spacer(),
            _drawerItem(icon: Icons.info_outline, label: "Tentang Aplikasi", onTap: () {}),
            const SizedBox(height: 12),
            _drawerItem(icon: Icons.exit_to_app, label: "Keluar", onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }
}