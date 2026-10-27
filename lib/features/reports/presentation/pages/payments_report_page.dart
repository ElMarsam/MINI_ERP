import 'package:flutter/material.dart';
import '../../domain/entities/report_data.dart';

class PaymentsReportPage extends StatelessWidget {
  const PaymentsReportPage({super.key, required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final total = data.totalCollected;
    final cash = data.paid(PaymentMethod.cash);
    final instaPay = data.paid(PaymentMethod.instaPay);
    final vodafoneCash = data.paid(PaymentMethod.vodafoneCash);

    return Scaffold(
      backgroundColor: ReportPalette.background,
      appBar: AppBar(
        title: const Text('تقرير وسائل الدفع والتحصيل'),
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
                    _PaymentTile(
                      label: 'كاش نقدي',
                      icon: Icons.payments_outlined,
                      amount: cash,
                      total: total,
                    ),
                    _PaymentTile(
                      label: 'InstaPay',
                      icon: Icons.qr_code_2,
                      amount: instaPay,
                      total: total,
                    ),
                    _PaymentTile(
                      label: 'فودافون كاش',
                      icon: Icons.phone_android,
                      amount: vodafoneCash,
                      total: total,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ReportCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إجمالي المتحصلات بجميع الطرق',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('إجمالي النقدية المحصلة'),
                        trailing: Text('${formatNumber(total)} ج.م',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ReportPalette.accent)),
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

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.label,
    required this.icon,
    required this.amount,
    required this.total,
  });

  final String label;
  final IconData icon;
  final int amount;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : amount / total * 100;

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
          Text('${formatNumber(amount)} ج.م', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('النسبة: ${percent.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, color: ReportPalette.mutedText)),
        ],
      ),
    );
  }
}
