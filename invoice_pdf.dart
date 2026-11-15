import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:projectck/helper.dart';
import 'package:projectck/order.dart';

class InvoicePdf {
  static const PdfColor _primary = PdfColor.fromInt(0xFF4F46E5);

  static Future<Uint8List> build(Order order) async {
    var font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    var bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );
    var doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: bold,
        italic: font,
        boldItalic: bold,
      ),
    );
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Khảo Sát Doanh Nghiệp - Hóa đơn ${order.code}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.Text(
              'In lúc ${Helper.date(DateTime.now())} - Trang ${context.pageNumber}/${context.pagesCount}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
        build: (context) => [
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            color: _primary,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'KHẢO SÁT DOANH NGHIỆP',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Dịch vụ khảo sát cho doanh nghiệp',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 10),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'HÓA ĐƠN',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      order.code,
                      style: pw.TextStyle(color: PdfColors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _block('Khách hàng', [
                  order.fullName,
                  'SĐT: ${order.phone}',
                  'Địa chỉ: ${order.address}',
                  if (order.memberEmail != null) 'Email: ${order.memberEmail}',
                ]),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _block('Đơn hàng', [
                  'Ngày đặt: ${order.createdDate}',
                  'Trạng thái: ${order.statusName}',
                  'Thanh toán: ${Helper.paymentLabel(order.paymentMethod)}',
                  if (order.note.isNotEmpty) 'Ghi chú: ${order.note}',
                ]),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['STT', 'Gói dịch vụ', 'Đơn giá', 'SL', 'Thành tiền'],
            data: [
              for (int i = 0; i < order.items.length; i++)
                [
                  '${i + 1}',
                  order.items[i].productName,
                  Helper.money(order.items[i].price),
                  '${order.items[i].quantity}',
                  Helper.money(order.items[i].amount),
                ],
            ],
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: pw.BoxDecoration(color: _primary),
            cellAlignments: {
              0: pw.Alignment.center,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.center,
              4: pw.Alignment.centerRight,
            },
            columnWidths: {
              0: pw.FixedColumnWidth(36),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(1.6),
              3: pw.FixedColumnWidth(36),
              4: pw.FlexColumnWidth(1.8),
            },
            oddRowDecoration: pw.BoxDecoration(color: PdfColors.grey100),
          ),
          pw.SizedBox(height: 12),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Tổng cộng: ${Helper.money(order.total)}',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: _primary,
              ),
            ),
          ),
          pw.SizedBox(height: 32),
          pw.Text(
            'Cảm ơn quý khách đã sử dụng dịch vụ khảo sát của chúng tôi!',
            style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
          ),
        ],
      ),
    );
    return doc.save();
  }

  static pw.Widget _block(String title, List<String> lines) {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          ...lines.map(
            (p) => pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 2),
              child: pw.Text(p, style: pw.TextStyle(fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }
}
