import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isPasswordFocused = false;
  bool isPasswordVisible = false;
  bool isLoading = false;
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
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      bool success = await ApiService.loginUser(
        emailController.text,
        passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushNamed(context, '/avatar');
      } else {
        _showErrorSnackBar('Invalid email or password');
      }
    } catch (e) {
      _showErrorSnackBar('Login failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withOpacity(0.8),
              AppTheme.secondary.withOpacity(0.8),
              AppTheme.accent.withOpacity(0.6),
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
                          // Animated Logo
                          _buildAnimatedLogo(),
                          const SizedBox(height: 40),

                          // Welcome Text
                          _buildWelcomeText(),
                          const SizedBox(height: 40),

                          // Login Form
                          _buildLoginForm(),
                          const SizedBox(height: 24),

                          // Additional Options
                          _buildAdditionalOptions(),
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
              Icons.sports,
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
          'Welcome to GoChamp',
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
          'Discover your sporting potential with AI-powered assessment',
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

  Widget _buildLoginForm() {
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
                'Sign In',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your credentials to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email Field
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppTheme.primary,
                  ),
                  suffixIcon: emailController.text.isNotEmpty
                      ? Icon(
                          Icons.check_circle,
                          color: AppTheme.success,
                          size: 20,
                        )
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),

              // Password Field
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    isPasswordFocused = hasFocus;
                  });
                },
                child: TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.textTertiary,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Forgot password feature coming soon'),
                        backgroundColor: AppTheme.info,
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login Button
              ElevatedButton(
                onPressed: isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
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
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.neutral300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.neutral300)),
                ],
              ),

              const SizedBox(height: 24),

              // Demo Login Button
              OutlinedButton(
                onPressed: () {
                  emailController.text = 'demo@gochamp.com';
                  passwordController.text = 'demo123';
                  login();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Try Demo Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Column(
      children: [
        Text(
          'New to GoChamp?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textOnPrimary.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // TODO: Implement sign up
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sign up feature coming soon'),
                backgroundColor: AppTheme.info,
              ),
            );
          },
          child: Text(
            'Create Account',
            style: TextStyle(
              color: AppTheme.textOnPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
