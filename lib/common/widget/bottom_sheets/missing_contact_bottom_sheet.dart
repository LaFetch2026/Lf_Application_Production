// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../core/constant/constants.dart';

class MissingContactBottomSheet extends StatefulWidget {
  final bool needsEmail;
  final bool needsPhone;

  const MissingContactBottomSheet({
    Key? key,
    required this.needsEmail,
    required this.needsPhone,
  }) : super(key: key);

  @override
  State<MissingContactBottomSheet> createState() =>
      _MissingContactBottomSheetState();
}

class _MissingContactBottomSheetState
    extends State<MissingContactBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final digits = value.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final email =
        widget.needsEmail ? _emailController.text.trim() : null;
    final phone =
        widget.needsPhone ? _phoneController.text.trim() : null;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save to SharedPreferences
      if (email != null && email.isNotEmpty) {
        await prefs.setString('email', email);
      }
      if (phone != null && phone.isNotEmpty) {
        await prefs.setString('phonenumber', phone);
      }

      // Best-effort profile update — do not block checkout on failure
      _updateProfileBestEffort(prefs, email: email, phone: phone);
    } catch (e) {
      print('⚠️ MissingContactBottomSheet: error saving to prefs: $e');
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context, {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      });
    }
  }

  void _updateProfileBestEffort(
    SharedPreferences prefs, {
    String? email,
    String? phone,
  }) {
    // Fire-and-forget — intentionally not awaited
    Future(() async {
      try {
        final token = prefs.getString('token');
        if (token == null || token.isEmpty) return;

        final existingEmail = prefs.getString('email') ?? '';
        final existingPhone = prefs.getString('phonenumber') ?? '';
        final name = prefs.getString('name') ?? '';

        final sendEmail =
            (email != null && email.isNotEmpty) ? email : existingEmail;
        final rawPhone =
            (phone != null && phone.isNotEmpty) ? phone : existingPhone;
        final phoneWithCode =
            rawPhone.startsWith('+91') ? rawPhone : '+91$rawPhone';

        final body = json.encode({
          'fullName': name,
          'email': sendEmail,
          'phone': phoneWithCode,
          'type': 'signup',
        });

        await http.put(
          Uri.parse('${ApiConstants.baseUrl}/auth/update-user-profile'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );
      } catch (e) {
        print('⚠️ MissingContactBottomSheet: best-effort profile update failed: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, null);
        return false;
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.sp, vertical: 24.sp),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40.sp,
                        height: 4.sp,
                        decoration: BoxDecoration(
                          color: dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.sp),

                    // Title
                    Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        fontFamily: 'Clash Display Semibold',
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        color: homeAppBarColor,
                      ),
                    ),
                    SizedBox(height: 6.sp),

                    // Subtitle
                    Text(
                      'We need your contact details to send order confirmations.',
                      style: TextStyle(
                        fontFamily: 'Clash Display Regular',
                        fontWeight: FontWeight.w400,
                        fontSize: 13.sp,
                        color: greyTextColor,
                      ),
                    ),
                    SizedBox(height: 20.sp),

                    // Email field
                    if (widget.needsEmail) ...[
                      _buildLabel('Email Address'),
                      SizedBox(height: 6.sp),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: widget.needsPhone
                            ? TextInputAction.next
                            : TextInputAction.done,
                        validator: _validateEmail,
                        style: TextStyle(
                          fontFamily: 'Clash Display Regular',
                          fontSize: 14.sp,
                          color: homeAppBarColor,
                        ),
                        decoration: _inputDecoration('Enter your email'),
                      ),
                      SizedBox(height: 16.sp),
                    ],

                    // Phone field
                    if (widget.needsPhone) ...[
                      _buildLabel('Phone Number'),
                      SizedBox(height: 6.sp),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: _validatePhone,
                        style: TextStyle(
                          fontFamily: 'Clash Display Regular',
                          fontSize: 14.sp,
                          color: homeAppBarColor,
                        ),
                        decoration: _inputDecoration('Enter 10-digit number'),
                      ),
                      SizedBox(height: 16.sp),
                    ],

                    SizedBox(height: 8.sp),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 48.sp,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: homeAppBarColor,
                          disabledBackgroundColor:
                              homeAppBarColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                height: 20.sp,
                                width: 20.sp,
                                child: const CircularProgressIndicator(
                                  color: whiteColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Continue',
                                style: TextStyle(
                                  fontFamily: 'Clash Display Semibold',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.sp,
                                  color: whiteColor,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 12.sp),

                    // Dismiss link
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, null),
                        child: Text(
                          'Skip for now',
                          style: TextStyle(
                            fontFamily: 'Clash Display Regular',
                            fontWeight: FontWeight.w400,
                            fontSize: 13.sp,
                            color: greyTextColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Clash Display Medium',
        fontWeight: FontWeight.w500,
        fontSize: 13.sp,
        color: textColor,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Clash Display Regular',
        fontSize: 13.sp,
        color: textHintColor,
      ),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: homeAppBarColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: redcolor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: redcolor, width: 1.5),
      ),
      filled: true,
      fillColor: whiteColor,
    );
  }
}
