import 'dart:typed_data';

import 'package:golf_kakis/features/booking/submission/success/viewmodel/booking_submission_success_view_contract.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class BookingSubmissionSuccessPdfService {
  const BookingSubmissionSuccessPdfService._();

  static Future<Uint8List> buildReceiptPdf({
    required BookingSubmissionSuccessDataLoaded state,
  }) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(16),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Text(
                        'Booking Receipt',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#E8F5EC'),
                          borderRadius: pw.BorderRadius.circular(999),
                        ),
                        child: pw.Text(
                          'Confirmed',
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#0D7A3A'),
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                  _buildSection(
                    title: 'Booking Details',
                    children: [
                      _buildInfoCard(
                        label: 'Golf Club',
                        value: state.golfClubName,
                      ),
                      _buildInfoCard(
                        label: 'Booking Ref',
                        value: state.bookingRef,
                      ),
                      _buildInfoCard(
                        label: 'Date',
                        value: _formatBookingDate(state.bookingDate),
                      ),
                      _buildInfoCard(
                        label: 'Tee Time',
                        value: state.teeTimeSlot,
                      ),
                      _buildRoundDetailsSummary(
                        items: [
                          ('Players', '${state.playerCount}'),
                          ('Holes', state.playType == '18_holes' ? '18' : '9'),
                          ('Caddies', '${state.caddieCount}'),
                          ('Buggy', '${state.golfCartCount}'),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                  _buildSection(
                    title: 'Payment Summary',
                    children: [
                      _buildInfoCard(
                        label: 'Payment Method',
                        value: state.paymentMethodLabel,
                      ),
                      _buildInfoCard(
                        label: 'Price Per Pax',
                        value: state.pricePerPersonLabel,
                      ),
                      _buildInfoCard(
                        label: 'Total',
                        value: state.totalCostLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return document.save();
  }

  static pw.Widget _buildSection({
    required String title,
    required List<pw.Widget> children,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#EEF3FF'),
        border: pw.Border.all(color: PdfColor.fromHex('#D7E1FF')),
        borderRadius: pw.BorderRadius.circular(16),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1) pw.SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildInfoCard({
    required String label,
    required String value,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F6F8FF'),
        border: pw.Border.all(color: PdfColor.fromHex('#D8E0FF')),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _safeText(value),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildRoundDetailsSummary({
    required List<(String, String)> items,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F6F8FF'),
        border: pw.Border.all(color: PdfColor.fromHex('#D8E0FF')),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Expanded(child: _buildSummaryText(items[0])),
              pw.SizedBox(width: 12),
              pw.Expanded(child: _buildSummaryText(items[1])),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(child: _buildSummaryText(items[2])),
              pw.SizedBox(width: 12),
              pw.Expanded(child: _buildSummaryText(items[3])),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryText((String, String) item) {
    return pw.RichText(
      text: pw.TextSpan(
        style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
        children: [
          pw.TextSpan(
            text: '${item.$1}: ',
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey700,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.TextSpan(
            text: _safeText(item.$2),
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static String _formatBookingDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return _safeText(rawDate);
    }

    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[parsed.month - 1];
    return '${parsed.day} $month ${parsed.year}';
  }

  static String _safeText(String value) {
    return value
        .replaceAll('\u00A0', ' ')
        .replaceAll('\u2013', '-')
        .replaceAll('\u2014', '-')
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'")
        .replaceAll('\u201C', '"')
        .replaceAll('\u201D', '"')
        .replaceAll(RegExp(r'[^\x00-\x7F]'), '');
  }
}
