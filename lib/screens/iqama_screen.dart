import 'package:flutter/material.dart';
import 'package:masjid_admin/services/firebase_service.dart';

class IqamaScreen extends StatefulWidget {
  const IqamaScreen({super.key});

  @override
  State<IqamaScreen> createState() => _IqamaScreenState();
}

class _IqamaScreenState extends State<IqamaScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  final List<Map<String, String>> _prayers = [
    {'key': 'الفجر', 'label': 'الفجر'},
    {'key': 'الشروق', 'label': 'الشروق'},
    {'key': 'الظهر', 'label': 'الظهر'},
    {'key': 'العصر', 'label': 'العصر'},
    {'key': 'المغرب', 'label': 'المغرب'},
    {'key': 'العشاء', 'label': 'العشاء'},
  ];

  Map<String, int> _iqamaTimes = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await FirebaseService.getIqamaTimes();
    setState(() {
      _iqamaTimes = data.map((k, v) => MapEntry(k, (v as num).toInt()));
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await FirebaseService.updateIqamaTimes(
      _iqamaTimes.map((k, v) => MapEntry(k, v)),
    );
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم الحفظ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أوقات الإقامة'),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _save,
                ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'عدّل عدد الدقايق لكل صلاة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ..._prayers.map((prayer) {
                  final key = prayer['key']!;
                  final value = _iqamaTimes[key] ?? 10;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              prayer['label']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: value.toDouble(),
                              min: 1,
                              max: 30,
                              divisions: 29,
                              label: '$value دقيقة',
                              onChanged: (v) => setState(
                                () => _iqamaTimes[key] = v.toInt(),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '$value د',
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ التغييرات'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: _save,
                ),
              ],
            ),
    );
  }
}