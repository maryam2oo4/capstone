import 'package:flutter/material.dart';
import '../core/network/api_client.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  bool loading = true;
  String error = '';
  int xp = 0;
  List<dynamic> products = const [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final dio = await ApiClient.instance.dio();
      final res = await dio.get('/donor/rewards/shop');
      setState(() {
        xp = (res.data['current_xp'] ?? 0) as int;
        products = (res.data['products'] as List?) ?? [];
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load rewards. Please login first.';
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards Store'),
        elevation: 6,
        shadowColor: Colors.black45,
        actions: [
          IconButton(onPressed: _fetch, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : error.isNotEmpty
              ? Center(child: Text(error, style: const TextStyle(color: Colors.red)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF111827), Color(0xFFB71C1C)],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your XP',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$xp XP',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Products',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...products.map((p) {
                      final title = (p['title'] ?? 'Product').toString();
                      final cost = (p['cost_xp'] ?? 0).toString();
                      final desc = (p['description'] ?? '').toString();
                      final enabled = (p['cost_xp'] ?? 0) <= xp;
                      return Card(
                        elevation: 1.5,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text(desc.isEmpty ? '—' : desc),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$cost XP', style: const TextStyle(fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(enabled ? 'Available' : 'Locked',
                                  style: TextStyle(color: enabled ? Colors.green : Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
    );
  }
}
