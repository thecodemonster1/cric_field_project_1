import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cric_field_project_1/Pages/RegisterPage.dart';
import 'package:cric_field_project_1/theme/app_theme.dart'; // app theme
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign In

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
    _loadSavedCredentials();

    // Add system UI overlay style for status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (savedEmail != null && rememberMe) {
        setState(() {
          _emailController.text = savedEmail;
          _rememberMe = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading saved credentials: $e');
    }
  }

  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text.trim());
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> _login() async {
    // Hide keyboard when login is attempted
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Save user credentials if remember me is checked
        await _saveCredentials();

        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          // Track login analytics (mock implementation)
          _logAnalyticsEvent('login_success', {
            'user_id': userCredential.user?.uid,
            'login_method': 'email_password',
          });

          // Navigate to home page/dashboard with animation
          Navigator.of(context).pushReplacementNamed(
            '/',
            arguments: {'user': userCredential.user},
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email address.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many attempts. Please try again later.';
            break;
          default:
            errorMessage =
                'Authentication failed. Please check your credentials.';
        }

        // Log failed login attempt
        _logAnalyticsEvent('login_failed', {'error_code': e.code});

        if (mounted) {
          _showErrorDialog(errorMessage);
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog(
              'An unexpected error occurred. Please try again later.');
          debugPrint('Login error: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Initialize Google Sign In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If user cancels the sign-in flow
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      if (mounted) {
        // Track login analytics
        _logAnalyticsEvent('login_success', {
          'user_id': userCredential.user?.uid,
          'login_method': 'google',
        });

        // Navigate to home page
        Navigator.of(context).pushReplacementNamed(
          '/',
          arguments: {'user': userCredential.user},
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Google Sign In failed: ${e.toString()}');
        debugPrint('Google Sign In error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _logAnalyticsEvent(String eventName, Map<String, dynamic>? parameters) {
    // This would be replaced with actual analytics implementation
    debugPrint('Analytics event: $eventName, params: $parameters');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegisterPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToForgotPassword() {
    // Implementation for forgot password navigation
    // This would navigate to a dedicated forgot password page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Forgot password functionality coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: AppColors.primary.withOpacity(0.5), // Use AppColors
          elevation: 0,
          title: const Text(
            'Login',
            style: TextStyle(color: AppColors.white),
          ),
          centerTitle: true,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: AppColors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null, // Hide the back button if we can't pop
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background design elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Main content
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // App branding
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppColors.grey700
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Hero(
                                  tag: 'app_logo',
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.sports_cricket,
                                      size: 48,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Welcome to Cric Field',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sign in to your account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.grey600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Email field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email address',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.grey300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: isDarkMode
                                  ? AppColors.grey700
                                  : AppColors.grey100,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            validator: _validateEmail,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),

                          const SizedBox(height: 24),

                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.grey600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.grey300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: isDarkMode
                                  ? AppColors.grey700
                                  : AppColors.grey100,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onFieldSubmitted: (_) => _login(),
                          ),

                          const SizedBox(height: 8),

                          // Remember me and forgot password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const Text('Remember me'),
                                ],
                              ),
                              TextButton(
                                onPressed: _navigateToForgotPassword,
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Login button
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColors.white,
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                shadowColor: AppColors.primary.withOpacity(0.5),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppColors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'SIGN IN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.grey300,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: AppColors.grey600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.grey300,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Social login buttons
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              elevation: 1,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/Google_logo.png',
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Register option
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account?',
                                style: TextStyle(
                                  color: AppColors.grey600,
                                ),
                              ),
                              TextButton(
                                onPressed: _navigateToRegister,
                                child: Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Terms of service
                          Text(
                            'By signing in, you agree to our Terms of Service and Privacy Policy',
                            style: TextStyle(
                              color: AppColors.grey600,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
