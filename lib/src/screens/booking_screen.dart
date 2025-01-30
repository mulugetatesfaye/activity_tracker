import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';

class BookingScreen extends StatefulWidget {
  final Activity activity;

  const BookingScreen({super.key, required this.activity});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';

  final _cardNumberFormatter = FilteringTextInputFormatter.digitsOnly;
  final _expiryDateFormatter = _ExpiryDateInputFormatter();
  final _cvvFormatter = LengthLimitingTextInputFormatter(3);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.activity.name),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _buildDateStep(),
                  _buildPaymentStep(),
                  _buildConfirmationStep(),
                ],
              ),
            ),
            _buildControlBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.tertiarySystemFill,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateStep() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Select Date & Time',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
        ),
        Expanded(
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            minimumDate: DateTime.now(),
            initialDateTime: DateTime.now().add(const Duration(hours: 1)),
            onDateTimeChanged: (date) => _selectedDate = date,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CupertinoFormSection(
            header: const Text('Payment Information'),
            children: [
              CupertinoTextFormFieldRow(
                prefix: const Text('Card Number'),
                placeholder: '4242 4242 4242 4242',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  _cardNumberFormatter,
                  LengthLimitingTextInputFormatter(16),
                ],
                onChanged: (value) => _cardNumber = value,
                validator: (value) =>
                    value?.length == 16 ? null : 'Invalid card',
              ),
              Row(
                children: [
                  Expanded(
                    child: CupertinoTextFormFieldRow(
                      prefix: const Text('Expiry'),
                      placeholder: 'MM/YY',
                      inputFormatters: [_expiryDateFormatter],
                      onChanged: (value) => _expiryDate = value,
                      validator: _validateExpiryDate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CupertinoTextFormFieldRow(
                      prefix: const Text('CVV'),
                      placeholder: '123',
                      keyboardType: TextInputType.number,
                      inputFormatters: [_cvvFormatter],
                      onChanged: (value) => _cvv = value,
                      validator: (value) =>
                          value?.length == 3 ? null : 'Invalid CVV',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return CupertinoScrollbar(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CupertinoListSection(
            header: const Text('Booking Summary'),
            children: [
              CupertinoListTile(
                title: const Text('Activity'),
                additionalInfo: Text(widget.activity.name),
              ),
              CupertinoListTile(
                title: const Text('Date'),
                additionalInfo: Text(
                  _selectedDate != null
                      ? DateFormat('MMM dd, yyyy - hh:mm a')
                          .format(_selectedDate!)
                      : 'Not selected',
                ),
              ),
              CupertinoListTile(
                title: const Text('Payment Method'),
                additionalInfo: Text(
                  _cardNumber.isNotEmpty
                      ? '•••• ${_cardNumber.substring(_cardNumber.length - 4)}'
                      : 'Not provided',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              CupertinoButton(
                child: const Text('Back'),
                onPressed: () => setState(() => _currentStep--),
              ),
            const Spacer(),
            CupertinoButton.filled(
              onPressed: _handleNavigation,
              child: Text(_currentStep == 2 ? 'Confirm' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation() {
    if (_currentStep == 1 && !_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Booking Confirmed'),
        content:
            const Text('Your appointment has been successfully scheduled!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
    );
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final parts = value.split('/');
    if (parts.length != 2) return 'Invalid format';
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null) return 'Invalid date';
    if (month < 1 || month > 12) return 'Invalid month';
    return null;
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length > 4) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(newText[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
