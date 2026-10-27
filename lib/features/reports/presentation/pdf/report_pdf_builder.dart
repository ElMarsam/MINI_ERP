import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/report_data.dart';

class ReportPdfBuilder {
  const ReportPdfBuilder._();

  static final _accent = PdfColor.fromInt(0xFF0B6B4B);
  static final _accentSoft = PdfColor.fromInt(0xFFE3F6EC);
  static final _ink = PdfColor.fromInt(0xFF1B1F1D);
  static final _muted = PdfColor.fromInt(0xFF6B7370);
  static final _line = PdfColor.fromInt(0xFFE3E7E5);
  static final _headerFill = PdfColor.fromInt(0xFFF2F4F5);
  static final _danger = PdfColor.fromInt(0xFFC62828);

  static Future<Uint8List> build(ReportData data) async {
    final regular = await PdfGoogleFonts.cairoRegular();
    final bold = await PdfGoogleFonts.cairoBold();
    final texts = _PdfTexts.of(data);

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
      title: texts.subtitle,
      author: 'ERP',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _header(data, texts),
          pw.SizedBox(height: 18),
          _twoColumns(
            _table(
              title: 'البوفيه',
              headers: const ['الصنف', 'الكمية', 'الإيراد'],
              flex: const [3, 1, 1],
              rows: [
                for (final i in data.buffetItems)
                  [i.name, formatNumber(i.quantity), formatNumber(i.revenue)],
              ],
              totalRow: [
                'الإجمالي',
                formatNumber(data.buffetItemsCount),
                formatNumber(data.buffetRevenue),
              ],
            ),
            _table(
              title: 'السيشنات',
              headers: const ['المؤشر', 'القيمة'],
              flex: const [3, 2],
              rows: [
                ['عدد السيشنات', formatNumber(data.sessionsCount)],
                ['إجمالي الدقائق', formatNumber(data.sessionsMinutes)],
                ['متوسط مدة السيشن', '${data.avgSessionMinutes} دقيقة'],
                ['متوسط قيمة السيشن', '${data.avgSessionValue} ج.م'],
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          _table(
            title: 'أعياد الميلاد والحجوزات',
            headers: const [
              'العميل',
              'موعد الحفل',
              'الإجمالي',
              'العربون',
              'المتبقي',
              'الحالة',
            ],
            flex: const [3, 3, 2, 2, 2, 2],
            highlightColumn: 4,
            rows: [
              for (final e in data.events)
                [
                  e.customerName,
                  formatDayMonth(e.eventDate),
                  formatNumber(e.total),
                  formatNumber(e.deposit),
                  formatNumber(e.remaining),
                  e.status,
                ],
            ],
            totalRow: [
              'الإجمالي',
              '',
              formatNumber(data.eventsTotal),
              formatNumber(data.eventsDeposits),
              formatNumber(data.eventsRemaining),
              '',
            ],
          ),
          pw.SizedBox(height: 18),
          _paymentMethodsTable(data),
          pw.SizedBox(height: 18),
          _twoColumns(
            _totalBox(
              label: texts.totalLabel,
              note: texts.totalNote,
              value: data.hasExpenses ? data.netProfit : data.totalCollected,
            ),
            data.hasExpenses
                ? _table(
              title: 'المصروفات وصافي الربح',
              headers: const ['البند', 'المبلغ'],
              flex: const [3, 2],
              rows: [
                for (final x in data.expenses!)
                  [x.name, formatNumber(x.amount)],
              ],
              totalRow: [
                'إجمالي المصروفات',
                formatNumber(data.totalExpenses),
              ],
              footerRow: ['صافي الربح', formatNumber(data.netProfit)],
            )
                : null,
          ),
        ],
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              _t('صفحة ${context.pageNumber} من ${context.pagesCount}',
                  size: 8, color: _muted),
            ],
          ),
        ),
      ),
    );

    return doc.save();
  }

  static pw.Widget _t(
      String text, {
        double size = 9.5,
        bool bold = false,
        PdfColor? color,
      }) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color ?? _ink,
      ),
    );
  }

  static pw.Widget _header(ReportData data, _PdfTexts texts) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 4),
                _t(texts.subtitle, size: 18, bold: true),
                pw.SizedBox(height: 2),
                _t(texts.periodStr, size: 10, color: _muted),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: _headerFill,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: _line),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _t('رقم التقرير: 0', size: 9, bold: true),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Divider(height: 1, color: _line),
      ],
    );
  }

  static pw.Widget _paymentMethodsTable(ReportData data) {
    final total = data.totalCollected;
    final cash = data.paid(PaymentMethod.cash);
    final instaPay = data.paid(PaymentMethod.instaPay);
    final vodafoneCash = data.paid(PaymentMethod.vodafoneCash);

    return _table(
      title: 'بيانات أنواع الدفع (طرق السداد)',
      headers: const ['طريقة السداد', 'المبلغ المحصل', 'النسبة'],
      flex: const [3, 2, 2],
      rows: [
        [
          'كاش نقدي',
          '${formatNumber(cash)} ج.م',
          '${total == 0 ? 0.0 : (cash / total * 100).toStringAsFixed(1)}%'
        ],
        [
          'InstaPay',
          '${formatNumber(instaPay)} ج.م',
          '${total == 0 ? 0.0 : (instaPay / total * 100).toStringAsFixed(1)}%'
        ],
        [
          'فودافون كاش',
          '${formatNumber(vodafoneCash)} ج.م',
          '${total == 0 ? 0.0 : (vodafoneCash / total * 100).toStringAsFixed(1)}%'
        ],
      ],
      totalRow: [
        'الإجمالي',
        '${formatNumber(total)} ج.م',
        '100%'
      ],
    );
  }

  static pw.Widget _twoColumns(pw.Widget? left, pw.Widget? right) {
    if (left == null && right == null) return pw.SizedBox.shrink();
    if (left == null) return right!;
    if (right == null) return left;
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: left),
        pw.SizedBox(width: 14),
        pw.Expanded(child: right),
      ],
    );
  }

  static pw.Widget _table({
    required String title,
    required List<String> headers,
    required List<int> flex,
    required List<List<String>> rows,
    List<String>? totalRow,
    List<String>? footerRow,
    int? highlightColumn,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _line),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding:
            const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: _headerFill,
              border: pw.Border(bottom: pw.BorderSide(color: _line)),
            ),
            child: _t(title, size: 10, bold: true),
          ),
          pw.Table(
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: _line, width: 0.5),
            ),
            columnWidths: {
              for (var i = 0; i < flex.length; i++)
                i: pw.FlexColumnWidth(flex[i].toDouble()),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: _headerFill),
                children: [
                  for (final h in headers)
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: _t(h, size: 8.5, bold: true, color: _muted),
                    ),
                ],
              ),
              for (final row in rows)
                pw.TableRow(
                  children: [
                    for (var i = 0; i < row.length; i++)
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: _t(
                          row[i],
                          size: 8.5,
                          bold: i == 0 || i == highlightColumn,
                          color: i == highlightColumn &&
                              row[i] != 'مؤكد' &&
                              row[i] != 'معلق'
                              ? _danger
                              : _ink,
                        ),
                      ),
                  ],
                ),
              if (totalRow != null)
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: _headerFill),
                  children: [
                    for (final cell in totalRow)
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: _t(cell, size: 8.5, bold: true),
                      ),
                  ],
                ),
              if (footerRow != null)
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: _accentSoft),
                  children: [
                    for (final cell in footerRow)
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: _t(cell, size: 9, bold: true, color: _accent),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _totalBox({
    required String label,
    required String note,
    required int value,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _accentSoft,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _accent, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _t(label, size: 10, bold: true, color: _accent),
          pw.SizedBox(height: 6),
          _t('${formatNumber(value)} ج.م', size: 18, bold: true, color: _accent),
          pw.SizedBox(height: 4),
          _t(note, size: 8.5, color: _muted),
        ],
      ),
    );
  }
}

class _PdfTexts {
  const _PdfTexts({
    required this.subtitle,
    required this.periodStr,
    required this.totalLabel,
    required this.totalNote,
  });

  final String subtitle;
  final String periodStr;
  final String totalLabel;
  final String totalNote;

  static _PdfTexts of(ReportData data) {
    return _PdfTexts(
      subtitle: 'التقرير المالي اليومي',
      periodStr: 'عن يوم ${formatDate(data.from)}',
      totalLabel: 'إجمالي متحصلات اليوم',
      totalNote: 'شامل السيشنات، البوفيه، وعرابين الحفلات.',
    );
  }
}
