import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import '../services/logger_service.dart';
import '../models/bill.dart';

class RazorpayService {
  static const String _keyId = 'rzp_test_SjIdp8up30cm2C';
  static const String _keySecret = 'DqxoIIyZ2bYZ1kqH6FNeTsbl';
  static const String _planId = 'plan_QExDeeYIHjinsm';
  
  late Razorpay _razorpay;
  
  // Callbacks
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(ExternalWalletResponse)? onExternalWallet;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    LoggerService.info('Payment Success: ${response.paymentId}', 'RAZORPAY');
    onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    LoggerService.error('Payment Error: ${response.code} - ${response.message}', 'RAZORPAY');
    onPaymentError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    LoggerService.info('External Wallet: ${response.walletName}', 'RAZORPAY');
    onExternalWallet?.call(response);
  }

  /// Initialize payment for a bill
  Future<void> initiatePayment({
    required Bill bill,
    required String userEmail,
    required String userPhone,
    required String userName,
    required BuildContext context,
  }) async {
    try {
      LoggerService.info('Initiating Razorpay payment for bill: ${bill.id}', 'RAZORPAY');
      
      // Convert amount to paise (Razorpay expects amount in smallest currency unit)
      int amountInPaise = (bill.amount * 100).round();
      
      var options = {
        'key': _keyId,
        'amount': amountInPaise,
        'name': 'GateEase Society',
        'description': '${bill.title} - ${bill.description}',
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'prefill': {
          'contact': userPhone,
          'email': userEmail,
          'name': userName,
        },
        'external': {
          'wallets': ['paytm']
        },
        'theme': {
          'color': '#4CAF50'
        },
        'modal': {
          'ondismiss': () {
            LoggerService.info('Payment modal dismissed', 'RAZORPAY');
          }
        },
        'notes': {
          'bill_id': bill.id,
          'resident_id': bill.residentId,
          'bill_type': bill.type,
          'society_id': 'gateease-society',
        }
      };

      _razorpay.open(options);
    } catch (e) {
      LoggerService.error('Error initiating Razorpay payment', 'RAZORPAY', e);
      _showErrorDialog(context, 'Failed to initiate payment. Please try again.');
    }
  }

  /// Verify payment signature (for additional security)
  bool verifyPaymentSignature({
    required String paymentId,
    required String orderId,
    required String signature,
  }) {
    try {
      String generatedSignature = _generateSignature(paymentId, orderId);
      return generatedSignature == signature;
    } catch (e) {
      LoggerService.error('Error verifying payment signature', 'RAZORPAY', e);
      return false;
    }
  }

  String _generateSignature(String paymentId, String orderId) {
    String payload = '$orderId|$paymentId';
    var key = utf8.encode(_keySecret);
    var bytes = utf8.encode(payload);
    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show payment success dialog
  void showSuccessDialog(BuildContext context, String paymentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Payment Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your payment has been processed successfully!'),
              const SizedBox(height: 10),
              Text(
                'Payment ID: $paymentId',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show payment failure dialog
  void showFailureDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text('Payment Failed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your payment could not be processed.'),
              const SizedBox(height: 10),
              Text(
                'Error: $errorMessage',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              const Text('Please try again or contact support if the issue persists.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    _razorpay.clear();
  }
}
