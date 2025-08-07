import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonShare {
  String name;
  double percentage;
  bool isLocked;
  Color color;

  PersonShare({
    required this.name,
    required this.percentage,
    this.isLocked = false,
    required this.color,
  });
}

class BillSplitPage extends StatefulWidget {
  const BillSplitPage({super.key});

  @override
  State<BillSplitPage> createState() => _BillSplitPageState();
}

class _BillSplitPageState extends State<BillSplitPage> {
  List<PersonShare> people = [
    PersonShare(name: 'Ali', percentage: 33.3, color: Colors.red),
    PersonShare(name: 'Mira', percentage: 33.3, color: Colors.green),
    PersonShare(name: 'John', percentage: 33.4, color: Colors.blue),
  ];

  double totalAmount = 100;
  double tax = 0;
  double service = 0;

  double get totalWithCharges => totalAmount * (1 + tax / 100 + service / 100);

  void updatePercentage(int changedIndex, double newValue) {
    setState(() {
      double delta = newValue - people[changedIndex].percentage;
      people[changedIndex].percentage = newValue;

      double totalUnlocked = people
          .asMap()
          .entries
          .where((e) => e.key != changedIndex && !e.value.isLocked)
          .fold(0.0, (sum, e) => sum + e.value.percentage);

      for (int i = 0; i < people.length; i++) {
        if (i != changedIndex && !people[i].isLocked && totalUnlocked > 0) {
          double ratio = people[i].percentage / totalUnlocked;
          people[i].percentage -= delta * ratio;
        }
      }

      double total = people.fold(0, (sum, p) => sum + p.percentage);
      double diff = 100 - total;
      var unlocked = people.where((p) => !p.isLocked).toList();
      if (unlocked.isNotEmpty) {
        unlocked.first.percentage += diff;
      }

      for (var p in people) {
        p.percentage = p.percentage.clamp(0, 100);
      }
    });
  }

  void updateValue(int index, double newValueRM) {
    double newPercent = (newValueRM / totalWithCharges) * 100;
    updatePercentage(index, newPercent);
  }

  void addPerson() {
    if (people.length >= 10) return;
    setState(() {
      people.add(
        PersonShare(
          name: 'Person ${people.length + 1}',
          percentage: 0,
          color: Colors.primaries[people.length % Colors.primaries.length],
        ),
      );
    });
  }

  void removePerson(int index) {
    if (people.length <= 1) return;
    setState(() {
      bool wasLocked = people[index].isLocked;
      people.removeAt(index);

      if (wasLocked) {
        double unlockedTotal = people
            .where((p) => !p.isLocked)
            .fold(0.0, (sum, p) => sum + p.percentage);
        if (unlockedTotal > 0) {
          for (var p in people) {
            if (!p.isLocked) {
              p.percentage = (p.percentage / unlockedTotal) * 100;
            }
          }
        }
      } else {
        double total = people.fold(0, (sum, p) => sum + p.percentage);
        for (var p in people) {
          p.percentage = (p.percentage / total) * 100;
        }
      }
    });
  }

  Future<void> shareToWhatsApp() async {
    String message =
        'Bill Split Summary:\n'
        'Total: RM${totalWithCharges.toStringAsFixed(2)}\n'
        'Tax: $tax%, Service Charge: $service%\n\n';
    for (var p in people) {
      double amount = totalWithCharges * p.percentage / 100;
      message +=
          '${p.name}: RM${amount.toStringAsFixed(2)} (${p.percentage.toStringAsFixed(1)}%)\n';
    }

    final encoded = Uri.encodeComponent(message);
    final url = "https://wa.me/?text=$encoded";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  final Map<int, TextEditingController> nameControllers = {};

  @override
  void dispose() {
    for (var controller in nameControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bill Splitter")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Pie Chart",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            AspectRatio(
              aspectRatio: 1.2,
              child: PieChart(
                PieChartData(
                  sections: people.map((p) {
                    return PieChartSectionData(
                      value: p.percentage,
                      color: p.color,
                      title: '${p.name}\n${p.percentage.toStringAsFixed(1)}%',
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: 'Total Amount (RM)'),
              keyboardType: TextInputType.number,
              onChanged: (val) =>
                  setState(() => totalAmount = double.tryParse(val) ?? 0),
            ),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Tax (%)'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) =>
                        setState(() => tax = double.tryParse(val) ?? 0),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Service Charge (%)',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) =>
                        setState(() => service = double.tryParse(val) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...people.asMap().entries.map((entry) {
              int i = entry.key;
              var p = entry.value;
              double valueInRM = totalWithCharges * p.percentage / 100;
              nameControllers.putIfAbsent(i, () => TextEditingController(text: p.name));
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Focus(
                                    onFocusChange: (hasFocus) {
                                      if (!hasFocus) {
                                        setState(() {
                                          p.name = nameControllers[i]!.text;
                                        });
                                      }
                                    },
                                    child: TextField(
                                      controller: nameControllers[i],
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Name',
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${p.percentage.toStringAsFixed(1)}%) - RM${valueInRM.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              p.isLocked ? Icons.lock : Icons.lock_open,
                            ),
                            onPressed: () =>
                                setState(() => p.isLocked = !p.isLocked),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => removePerson(i),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Slider(
                              value: p.percentage.clamp(0, 100),
                              min: 0,
                              max: 100,
                              onChanged: p.isLocked
                                  ? null
                                  : (val) => updatePercentage(i, val),
                              activeColor: p.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              enabled: !p.isLocked,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'RM',
                              ),
                              onChanged: (val) {
                                double? v = double.tryParse(val);
                                if (v != null) updateValue(i, v);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: addPerson,
              icon: const Icon(Icons.add),
              label: const Text("Add Person"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: shareToWhatsApp,
              icon: const Icon(Icons.share),
              label: const Text("Share to WhatsApp"),
            ),
          ],
        ),
      ),
    );
  }
}