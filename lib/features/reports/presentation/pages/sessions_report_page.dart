import 'package:flutter/material.dart';
import '../../domain/entities/report_data.dart';

class SessionsReportPage extends StatelessWidget {
  const SessionsReportPage({super.key, required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final sessionTransactions = data.transactions
        .where((t) => t.type == RevenueType.session)
        .toList();

    return Scaffold(
      backgroundColor: ReportPalette.background,
      appBar: AppBar(
        title: const Text('تقرير السيشنات ومساحات العمل'),
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
                  wideColumns: 3,
                  children: [
                    _MetricCard(
                      label: 'إيرادات السيشنات',
                      value: '${formatNumber(data.sessionsRevenue)} ج.م',
                      icon: Icons.chair_alt_outlined,
                    ),
                    _MetricCard(
                      label: 'عدد السيشنات',
                      value: formatNumber(data.sessionsCount),
                      icon: Icons.timer_outlined,
                    ),
                    _MetricCard(
                      label: 'إجمالي الدقائق',
                      value: '${formatNumber(data.sessionsMinutes)} دقيقة',
                      icon: Icons.access_time,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ReportCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مؤشرات الأداء (Averages)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('متوسط مدة السيشن الواحد'),
                        trailing: Text('${data.avgSessionMinutes} دقيقة',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('متوسط قيمة السيشن الواحد'),
                        trailing: Text('${formatNumber(data.avgSessionValue)} ج.م',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: ReportPalette.accent)),
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
                        'معاملات السيشنات التفصيلية',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      if (sessionTransactions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('لا توجد معاملات سيشنات مسجلة.'),
                        )
                      else
                        for (final t in sessionTransactions)
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
              Icon(icon, size: 20, color: ReportPalette.accent),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
