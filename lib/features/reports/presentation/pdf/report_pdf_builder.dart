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

    // ─── الصفحة الأولى: نظرة عامة والملخص ──────────────────────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _header(texts),
          pw.SizedBox(height: 20),
          _totalBox(
            label: texts.totalLabel,
            note: texts.totalNote,
            value: data.hasExpenses ? data.netProfit : data.totalCollected,
          ),
          pw.SizedBox(height: 20),
          _table(
            title: 'ملخص المؤشرات العامة',
            headers: const ['المؤشر الرئيسي', 'القيمة الإجمالية'],
            flex: const [3, 2],
            rows: [
              ['إجمالي إيرادات السيشنات', '${formatNumber(data.sessionsRevenue)} ج.م (${data.sessionsCount} سيشن)'],
              ['إجمالي مبيعات البوفيه', '${formatNumber(data.buffetRevenue)} ج.م (${data.buffetItemsCount} صنف)'],
              ['إجمالي مقبوضات الفعاليات', '${formatNumber(data.eventsRevenue)} ج.م (${data.eventsBookingsCount} حفل)'],
              ['إجمالي المتحصلات النقدية', '${formatNumber(data.totalCollected)} ج.م'],
            ],
          ),
        ],
        footer: (context) => _footer(context),
      ),
    );

    // ─── الصفحة الثانية: تقرير السيشنات والبوفيه ────────────────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _sectionTitle('ثانياً: تقرير السيشنات ومساحات العمل'),
          pw.SizedBox(height: 10),
          _table(
            title: 'تفاصيل السيشنات',
            headers: const ['المؤشر', 'القيمة'],
            flex: const [3, 2],
            rows: [
              ['عدد السيشنات الكلي', formatNumber(data.sessionsCount)],
              ['إجمالي عدد الدقائق', '${formatNumber(data.sessionsMinutes)} دقيقة'],
              ['متوسط مدة السيشن', '${data.avgSessionMinutes} دقيقة'],
              ['متوسط قيمة السيشن', '${formatNumber(data.avgSessionValue)} ج.م'],
            ],
          ),
          pw.SizedBox(height: 20),
          _sectionTitle('ثالثاً: تقرير البوفيه والمشروبات والمأكولات'),
          pw.SizedBox(height: 10),
          _table(
            title: 'تفاصيل مبيعات الأصناف',
            headers: const ['الصنف', 'الكمية المباعة', 'الإيراد المحقق'],
            flex: const [3, 1, 1],
            rows: [
              for (final i in data.buffetItems)
                [i.name, formatNumber(i.quantity), '${formatNumber(i.revenue)} ج.م'],
            ],
            totalRow: [
              'الإجمالي',
              formatNumber(data.buffetItemsCount),
              '${formatNumber(data.buffetRevenue)} ج.م',
            ],
          ),
        ],
        footer: (context) => _footer(context),
      ),
    );

    // ─── الصفحة الثالثة: تقرير الحجوزات وطرق الدفع ─────────────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _sectionTitle('رابعاً: تقرير أعياد الميلاد وحجوزات القاعات'),
          pw.SizedBox(height: 10),
          _table(
            title: 'قائمة الحجوزات المؤكدة',
            headers: const ['موعد الحفل', 'المتبقي', 'الإجمالي', 'العربون', 'العميل'],
            flex: const [3, 2, 2, 2, 3],
            rows: [
              for (final e in data.events)
                [
                  formatDayMonth(e.eventDate),
                  '${formatNumber(e.remaining)} ج.م',
                  '${formatNumber(e.total)} ج.م',
                  '${formatNumber(e.deposit)} ج.م',
                  e.customerName,
                ],
            ],
            totalRow: [
              '',
              '${formatNumber(data.eventsRemaining)} ج.م',
              '${formatNumber(data.eventsTotal)} ج.م',
              '${formatNumber(data.eventsDeposits)} ج.م',
              'الإجمالي',
            ],
          ),
          pw.SizedBox(height: 20),
          _sectionTitle('خامساً: تقرير وسائل الدفع والتحصيل'),
          pw.SizedBox(height: 10),
          _paymentMethodsTable(data),
        ],
        footer: (context) => _footer(context),
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

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: _accent,
      ),
    );
  }

  static pw.Widget _header(_PdfTexts texts) {
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

  static pw.Widget _footer(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          _t('صفحة ${context.pageNumber} من ${context.pagesCount}',
              size: 8, color: _muted),
        ],
      ),
    );
  }

  static pw.Widget _paymentMethodsTable(ReportData data) {
    final total = data.totalCollected;
    final cash = data.paid(PaymentMethod.cash);
    final instaPay = data.paid(PaymentMethod.instaPay);
    final vodafoneCash = data.paid(PaymentMethod.vodafoneCash);

    return _table(
      title: 'توزيع طرق السداد',
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
