import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';  // Temporarily disabled
import '../../models/payment.dart';
import '../../models/bill.dart';
import '../../models/app_user.dart';
import '../../services/auth_provider.dart';
import '../../services/bill_service.dart';
import '../../services/payment_service.dart';
// import '../../services/razorpay_service.dart';  // Temporarily disabled
import '../../services/user_service.dart';
import 'package:provider/provider.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String selectedTab = 'pending';
  List<Bill> _bills = [];
  List<Payment> _payments = [];
  bool _isLoading = true;
  // late RazorpayService _razorpayService;  // Temporarily disabled
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
    _loadUserData();
    _loadBills();
    _loadPayments();
  }

  void _initializeRazorpay() {
    // _razorpayService = RazorpayService();  // Temporarily disabled
    // _razorpayService.onPaymentSuccess = _handlePaymentSuccess;
    // _razorpayService.onPaymentError = _handlePaymentError;
    // _razorpayService.onExternalWallet = _handleExternalWallet;
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.appUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  void dispose() {
    // _razorpayService.dispose();  // Temporarily disabled
    super.dispose();
  }

  Future<void> _loadBills() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.appUser;

    if (user != null) {
      setState(() => _isLoading = true);
      try {
        final bills = await BillService.getBillsForResident(user.uid);
        setState(() {
          _bills = bills;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading bills: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _loadPayments() async {
    if (_currentUser != null) {
      try {
        final payments = await PaymentService.getPaymentsForResident(_currentUser!.uid);
        setState(() {
          _payments = payments;
        });
      } catch (e) {
        print('Error loading payments: $e');
      }
    }
  }

  void _handlePaymentSuccess(/* PaymentSuccessResponse response */) async {
    // Temporarily disabled - Razorpay integration
    /*
    try {
      // Find the bill being paid (you might need to store this during payment initiation)
      // For now, we'll assume the most recent unpaid bill
      final unpaidBills = _bills.where((bill) => bill.status != 'paid').toList();
      if (unpaidBills.isNotEmpty && _currentUser != null) {
        final bill = unpaidBills.first;

        // Record the payment
        await PaymentService.recordPayment(
          billId: bill.id,
          residentId: _currentUser!.uid,
          residentName: _currentUser!.name,
          flatNo: _currentUser!.flatNo,
          amount: bill.amount,
          paymentId: response.paymentId ?? '',
          transactionId: response.paymentId ?? '',
          signature: response.signature,
        );

        // Mark bill as paid
        await BillService.markBillAsPaid(
          billId: bill.id,
          paymentId: response.paymentId ?? '',
          paymentMethod: 'razorpay',
        );

        // Show success dialog
        _razorpayService.showSuccessDialog(context, response.paymentId ?? '');

        // Reload data
        _loadBills();
        _loadPayments();
      }
    } catch (e) {
      print('Error handling payment success: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful but failed to update records: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    */
  }

  void _handlePaymentError(/* PaymentFailureResponse response */) {
    // Temporarily disabled - Razorpay integration
    /*
    _razorpayService.showFailureDialog(
      context,
      response.message ?? 'Payment failed'
    );
    */
  }

  void _handleExternalWallet(/* ExternalWalletResponse response */) {
    // Temporarily disabled - Razorpay integration
    /*
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
      ),
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.appUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: _buildTab('Pending Bills', 'pending')),
                Expanded(child: _buildTab('Payment History', 'history')),
              ],
            ),
          ),

          // Content
          Expanded(
            child:
                selectedTab == 'pending'
                    ? _buildPendingBills(user)
                    : _buildPaymentHistory(user),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, String tab) {
    final isSelected = selectedTab == tab;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingBills(user) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final pendingBills = _bills.where((bill) => bill.status == 'pending' || bill.isOverdue).toList();

    if (pendingBills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No pending bills',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All your bills are up to date!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBills,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingBills.length,
        itemBuilder: (context, index) {
          final bill = pendingBills[index];
          return _buildBillCard(bill);
        },
      ),
    );
  }

  Widget _buildBillCard(Bill bill) {
    final isOverdue = bill.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isOverdue ? Border.all(color: Colors.red.shade300, width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bill.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'OVERDUE',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              bill.description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: isOverdue ? Colors.red : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Due: ${_formatDate(bill.dueDate)}',
                  style: TextStyle(
                    color: isOverdue ? Colors.red : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  bill.formattedAmount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showPaymentDialog(bill),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Pay Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showPaymentDialog(Bill bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bill: ${bill.title}'),
            Text('Amount: ${bill.formattedAmount}'),
            const SizedBox(height: 16),
            const Text('Choose payment method:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment(bill, 'UPI');
            },
            child: const Text('Pay with UPI'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment(bill, 'Card');
            },
            child: const Text('Pay with Card'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(Bill bill, String paymentMethod) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Processing payment...'),
          ],
        ),
      ),
    );

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Generate a mock payment ID
      final paymentId = 'PAY_${DateTime.now().millisecondsSinceEpoch}';

      // Mark bill as paid
      await BillService.markBillAsPaid(
        billId: bill.id,
        paymentId: paymentId,
        paymentMethod: paymentMethod,
      );

      // Close loading dialog
      Navigator.pop(context);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text('Payment ID: $paymentId'),
              Text('Amount: ${bill.formattedAmount}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _loadBills(); // Refresh bills
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Failed'),
          content: Text('Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPendingBillCard(Map<String, dynamic> bill, user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bill['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${bill['amount'].toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  Text(
                    'Due: ${bill['dueDate']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _initiatePayment(bill, user),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(user) {
    if (_currentUser == null) {
      return const Center(
        child: Text('User information not available'),
      );
    }

    return StreamBuilder<List<Payment>>(
      stream: PaymentService.getPaymentsStream(residentId: _currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading payment history',
                  style: TextStyle(fontSize: 18, color: Colors.red.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payment_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No payment history',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your completed payments will appear here',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final payment = snapshot.data![index];
            return _buildPaymentHistoryCard(payment);
          },
        );
      },
    );
  }

  Widget _buildPaymentHistoryCard(Payment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment ID: ${payment.paymentId.isNotEmpty ? payment.paymentId : payment.transactionId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Method: ${payment.method.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (payment.status.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: payment.status == 'success'
                              ? Colors.green.shade100
                              : payment.status == 'failed'
                                  ? Colors.red.shade100
                                  : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          payment.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: payment.status == 'success'
                                ? Colors.green.shade700
                                : payment.status == 'failed'
                                    ? Colors.red.shade700
                                    : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${payment.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    _formatDate(payment.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              const Text(
                'Payment Successful',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _downloadReceipt(payment),
                child: const Text('Download Receipt'),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Future<void> _initiatePayment(Map<String, dynamic> bill, user) async {
    // Show payment options dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Options'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: const Text('Razorpay'),
                  subtitle: const Text('Pay with UPI, Cards, Net Banking'),
                  onTap: () {
                    Navigator.pop(context);
                    _processRazorpayPayment(bill, user);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: const Text('Bank Transfer'),
                  subtitle: const Text('Direct bank transfer'),
                  onTap: () {
                    Navigator.pop(context);
                    _showBankDetails();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _processRazorpayPayment(Map<String, dynamic> bill, user) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User information not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Convert bill map to Bill object
      final billObj = Bill(
        id: bill['id'] ?? '',
        title: bill['title'] ?? '',
        description: bill['description'] ?? '',
        amount: (bill['amount'] ?? 0.0).toDouble(),
        residentId: bill['residentId'] ?? '',
        residentName: bill['residentName'] ?? '',
        residentEmail: bill['residentEmail'] ?? '',
        flatNumber: bill['flatNumber'] ?? '',
        billType: bill['billType'] ?? bill['type'] ?? 'other',
        dueDate: bill['dueDate'] ?? DateTime.now(),
        createdAt: bill['createdAt'] ?? DateTime.now(),
        status: bill['status'] ?? 'pending',
        createdBy: bill['createdBy'] ?? '',
        notes: bill['notes'],
      );

      // Initiate Razorpay payment - Temporarily disabled
      // await _razorpayService.initiatePayment(
      //   bill: billObj,
      //   userEmail: _currentUser!.email,
      //   userPhone: _currentUser!.phone.isNotEmpty ? _currentUser!.phone : '9999999999',
      //   userName: _currentUser!.name,
      //   context: context,
      // );

      // Temporary mock payment for testing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment feature temporarily disabled for testing'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initiate payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBankDetails() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Bank Transfer Details'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account Name: GateEase Society'),
                Text('Account Number: 1234567890'),
                Text('IFSC Code: HDFC0001234'),
                Text('Bank: HDFC Bank'),
                SizedBox(height: 16),
                Text(
                  'Please use your flat number as reference while making the transfer.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _downloadReceipt(Payment payment) {
    // TODO: Implement receipt download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt download feature coming soon!')),
    );
  }
}
