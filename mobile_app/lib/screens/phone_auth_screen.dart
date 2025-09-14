import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_selector.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  late AnimationController _animationController;
  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _logoController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _logoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.sendOTP(_phoneController.text);
      
      if (!mounted) return;

      if (result['success']) {
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: _phoneController.text,
        );
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to send OTP. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    
    // Remove any non-digit characters
    final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    
    return null;
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
          child: Column(
            children: [
              // Language selector at top
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    LanguageSelectorButton(),
                  ],
                ),
              ),
              // Main content
              Expanded(
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
                                // Animated Logo
                                _buildAnimatedLogo(),
                                const SizedBox(height: 40),

                                // Welcome Text
                                _buildWelcomeText(),
                                const SizedBox(height: 40),

                                // Phone Input Form
                                _buildPhoneForm(),
                                const SizedBox(height: 24),

                                // Additional Info
                                _buildAdditionalInfo(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _logoController.value * 0.1,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.phone_android,
              size: 60,
              color: AppTheme.textOnPrimary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'auth.welcome'.tr(),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppTheme.textOnPrimary,
            letterSpacing: -0.5,
            shadows: [
              Shadow(
                color: AppTheme.textOnPrimary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'auth.welcome_subtitle'.tr(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textOnPrimary.withOpacity(0.9),
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        border: Border.all(
          color: AppTheme.textOnPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'auth.verify_phone'.tr(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'auth.otp_sent_to'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: 'auth.phone_number'.tr(),
                  hintText: 'auth.phone_hint'.tr(),
                  prefixIcon: Container(
                    width: 60,
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+91',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 1,
                          height: 20,
                          color: AppTheme.neutral300,
                        ),
                      ],
                    ),
                  ),
                  suffixIcon: _phoneController.text.length == 10
                      ? Icon(
                          Icons.check_circle,
                          color: AppTheme.success,
                          size: 20,
                        )
                      : null,
                ),
                validator: _validatePhoneNumber,
                onChanged: (value) {
                  setState(() {});
                },
                onFieldSubmitted: (_) => _sendOTP(),
              ),

              const SizedBox(height: 24),

              // Send OTP Button
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOTP,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
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
                    : Text(
                      'auth.send_otp'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Column(
      children: [
        Text(
          'By continuing, you agree to our',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textOnPrimary.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Show terms and conditions
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terms and conditions coming soon'),
                    backgroundColor: AppTheme.info,
                  ),
                );
              },
              child: Text(
                'Terms of Service',
                style: TextStyle(
                  color: AppTheme.textOnPrimary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' and ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textOnPrimary.withOpacity(0.7),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show privacy policy
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy policy coming soon'),
                    backgroundColor: AppTheme.info,
                  ),
                );
              },
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: AppTheme.textOnPrimary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
