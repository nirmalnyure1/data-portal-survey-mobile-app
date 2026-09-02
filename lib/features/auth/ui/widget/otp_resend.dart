import 'dart:async';

import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/theme.dart';

class OtpResend extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback? onResend;

  const OtpResend({super.key, this.initialSeconds = 21, this.onResend});

  @override
  State<OtpResend> createState() => _OtpResendState();
}

class _OtpResendState extends State<OtpResend> {
  Timer? _timer;
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialSeconds;
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_remaining <= 0) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _remaining -= 1);
    });
  }

  void _handleResend() {
    if (_remaining > 0) return;
    widget.onResend?.call();
    setState(() => _remaining = widget.initialSeconds);
    _start();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: ThemeColors.grey.withValues(alpha: 210),
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );

    final resendStyle = TextStyle(
      color: _remaining > 0
          ? ThemeColors.grey.withValues(alpha: 210)
          : ThemeColors.primaryColor,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Didn't receive code?  ", style: baseStyle),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _remaining > 0 ? null : _handleResend,
          child: Text('RESEND OTP', style: resendStyle),
        ),
        if (_remaining > 0)
          Text(' (${_remaining}s)', style: baseStyle)
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
