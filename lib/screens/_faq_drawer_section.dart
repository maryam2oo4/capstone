import 'package:flutter/material.dart';
import '../core/network/faq_service.dart';
import '_faq_list.dart';

class FaqDrawerSection extends StatefulWidget {
  @override
  State<FaqDrawerSection> createState() => FaqDrawerSectionState();
}

class FaqDrawerSectionState extends State<FaqDrawerSection> {
  List<String> categories = ['All'];
  List<Map<String, dynamic>> faqs = [];
  int selectedIndex = 0;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await FaqService.getFaqs();
      if (!mounted) return;
      final list = data['faqs'];
      final raw = list is List ? list : <dynamic>[];
      final List<Map<String, dynamic>> parsed = raw
          .map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
          .toList();
      final cats = data['categories'];
      final catList = cats is List ? cats.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList() : <String>[];
      setState(() {
        faqs = parsed;
        categories = ['All', ...catList];
        if (categories.length == 1) {
          categories = ['All', 'Blood Donation', 'Organ Donation', 'Appointments', 'Account'];
        }
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
        categories = ['All', 'Blood Donation', 'Organ Donation', 'Appointments', 'Account'];
      });
    }
  }

  List<Map<String, dynamic>> get _filteredFaqs {
    if (categories.isEmpty || selectedIndex >= categories.length) return faqs;
    final cat = categories[selectedIndex];
    if (cat == 'All') return faqs;
    return faqs.where((f) => f['category']?.toString() == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB71C1C), Color(0xFFFF1744)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<int>(
            value: selectedIndex >= categories.length ? 0 : selectedIndex,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
            ),
            underline: const SizedBox(),
            dropdownColor: Colors.red,
            items: List.generate(categories.length, (idx) {
              return DropdownMenuItem(
                value: idx,
                child: Text(
                  '  ${categories[idx]}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: idx == selectedIndex
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }),
            onChanged: (idx) {
              if (idx != null) setState(() => selectedIndex = idx);
            },
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
        const SizedBox(height: 18),
        if (loading)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Could not load FAQs.',
                  style: TextStyle(color: Colors.red[700], fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _loadFaqs,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          )
        else
          FaqList(items: _filteredFaqs),
      ],
    );
  }
}
