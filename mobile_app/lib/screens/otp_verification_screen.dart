import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startResendCountdown();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _startResendCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startResendCountdown();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    
    if (otp.length != 6) {
      _showErrorSnackBar('Please enter complete OTP');
      _shakeAnimation();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.verifyOTP(widget.phoneNumber, otp);
      
      if (!mounted) return;

      if (result['success']) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorSnackBar(result['message']);
        _shakeAnimation();
      }
    } catch (e) {
      _showErrorSnackBar('Verification failed. Please try again.');
      _shakeAnimation();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
    });

    try {
      final result = await AuthService.resendOTP(widget.phoneNumber);
      
      if (!mounted) return;

      if (result['success']) {
        _showSuccessSnackBar('OTP sent successfully');
        setState(() {
          _resendCountdown = 60;
        });
        _startResendCountdown();
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to resend OTP');
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _shakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _onOTPChanged(int index, String value) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOTP();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withOpacity(0.9),
              AppTheme.secondary.withOpacity(0.8),
              AppTheme.accent.withOpacity(0.7),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          _buildHeader(),
                          const SizedBox(height: 40),

                          // OTP Input
                          _buildOTPInput(),
                          const SizedBox(height: 32),

                          // Verify Button
                          _buildVerifyButton(),
                          const SizedBox(height: 24),

                          // Resend OTP
                          _buildResendSection(),
                          const SizedBox(height: 32),

                          // Back to Login
                          _buildBackToLogin(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.verified_user,
            size: 40,
            color: AppTheme.textOnPrimary,
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          'Verify Your Phone',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppTheme.textOnPrimary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          'We\'ve sent a 6-digit code to',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textOnPrimary.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Phone Number
        Text(
          '+91 ${widget.phoneNumber}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textOnPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOTPInput() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeController.value * 10 * (1 - _shakeController.value), 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 45,
                height: 55,
                child: TextFormField(
                  controller: _otpControllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.neutral200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.neutral200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.error, width: 2),
                    ),
                  ),
                  onChanged: (value) => _onOTPChanged(index, value),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOTP,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.textOnPrimary,
                  ),
                ),
              )
            : const Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          'Didn\'t receive the code?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textOnPrimary.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _resendCountdown > 0 || _isResending ? null : _resendOTP,
          child: _isResending
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.textOnPrimary,
                    ),
                  ),
                )
              : Text(
                  _resendCountdown > 0
                      ? 'Resend OTP in ${_resendCountdown}s'
                      : 'Resend OTP',
                  style: TextStyle(
                    color: _resendCountdown > 0
                        ? AppTheme.textOnPrimary.withOpacity(0.6)
                        : AppTheme.textOnPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildBackToLogin() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        'Change Phone Number',
        style: TextStyle(
          color: AppTheme.textOnPrimary.withOpacity(0.8),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}
