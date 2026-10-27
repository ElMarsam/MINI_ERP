import 'package:flutter/material.dart';
import '../../domain/entities/report_data.dart';

class EventsReportPage extends StatelessWidget {
  const EventsReportPage({super.key, required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReportPalette.background,
      appBar: AppBar(
        title: const Text('تقرير أعياد الميلاد وحجوزات القاعات'),
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
                      label: 'إجمالي الحجوزات',
                      value: '${formatNumber(data.eventsTotal)} ج.م',
                      icon: Icons.celebration_outlined,
                    ),
                    _MetricCard(
                      label: 'العرابين المحصلة',
                      value: '${formatNumber(data.eventsRevenue)} ج.م',
                      icon: Icons.payments_outlined,
                    ),
                    _MetricCard(
                      label: 'المبالغ المتبقية',
                      value: '${formatNumber(data.eventsRemaining)} ج.م',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ReportCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'قائمة الحفلات والحجوزات المؤكدة',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      if (data.events.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('لا توجد حجوزات أعياد ميلاد مسجلة.'),
                        )
                      else
                        for (final event in data.events)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ReportPalette.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: ReportPalette.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(event.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('موعد الحفل: ${formatDayMonth(event.eventDate)}',
                                        style: const TextStyle(fontSize: 12, color: ReportPalette.mutedText)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('الإجمالي: ${formatNumber(event.total)} ج.م',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('العربون: ${formatNumber(event.deposit)} ج.م | المتبقي: ${formatNumber(event.remaining)} ج.م',
                                        style: const TextStyle(fontSize: 12, color: ReportPalette.info)),
                                  ],
                                ),
                              ],
                            ),
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
              Icon(icon, size: 20, color: ReportPalette.info),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
