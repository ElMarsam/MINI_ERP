import 'package:flutter/material.dart';
import '../../domain/entities/report_data.dart';

class BuffetReportPage extends StatelessWidget {
  const BuffetReportPage({super.key, required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final buffetTransactions = data.transactions
        .where((t) => t.type == RevenueType.buffet)
        .toList();

    return Scaffold(
      backgroundColor: ReportPalette.background,
      appBar: AppBar(
        title: const Text('تقرير البوفيه والمشروبات والمأكولات'),
        backgroundColor: ReportPalette.surface,
        foregroundColor: ReportPalette.text,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ResponsiveReportGrid(
                  wideColumns: 2,
                  children: [
                    _MetricCard(
                      label: 'إجمالي إيرادات البوفيه',
                      value: '${formatNumber(data.buffetRevenue)} ج.م',
                      icon: Icons.coffee_outlined,
                    ),
                    _MetricCard(
                      label: 'إجمالي الأصناف المصروفة',
                      value: '${formatNumber(data.buffetItemsCount)} صنف',
                      icon: Icons.local_bar_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ReportCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الأصناف الأكثر مبيعاً في البوفيه',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      for (final item in data.buffetItems)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('الكمية: ${formatNumber(item.quantity)}   |   الإيراد: ${formatNumber(item.revenue)} ج.م',
                                  style: const TextStyle(color: ReportPalette.mutedText)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ReportCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'معاملات البوفيه التفصيلية',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      if (buffetTransactions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('لا توجد معاملات بوفيه مسجلة.'),
                        )
                      else
                        for (final t in buffetTransactions)
                          ListTile(
                            title: Text(t.customerName),
                            subtitle: Text('${t.itemLabel} • ${formatTime(t.dateTime)}'),
                            trailing: Text('${formatNumber(t.amount)} ج.م',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ReportPalette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ReportPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: ReportPalette.mutedText)),
              Icon(icon, size: 20, color: ReportPalette.warning),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
