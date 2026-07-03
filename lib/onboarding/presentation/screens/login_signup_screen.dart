import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
import '../../../core/services/service_locator.dart';
import '../../data/services/onboarding_storage_service.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';
import '../../../core/presentation/components/ads/native_ad_widget.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  bool _loginObscure = true;
  bool _signupObscure = true;
  bool _signupConfirmObscure = true;
  bool _isLoading = false;

  // Design constants
  static const Color _bg = Color(0xFF090C14);
  static const Color _surface = Color(0xFF0F1422);
  static const Color _card = Color(0xFF151B2E);
  static const Color _border = Color(0xFF1E2840);
  static const Color _gold = Color(0xFFE8B84B);
  static const Color _purple = Color(0xFFC084FC);
  static const Color _muted = Color(0xFF8892AA);
  static const Color _text = Color(0xFFF1F5FF);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _signupPhoneController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final storage = sl<OnboardingStorageService>();
    final storedPhone = storage.getUserPhone();
    final storedPassword = storage.getUserPassword();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (storedPhone == null || storedPassword == null) {
      _showSnackBar('No account found. Please sign up first.', isError: true);
      return;
    }

    if (_loginPhoneController.text == storedPhone &&
        _loginPasswordController.text == storedPassword) {
      await storage.setLoggedIn(true);
      _showSnackBar('Welcome back!');
      if (storage.isOnboardingComplete()) {
        if (mounted) context.go('/movies');
      } else {
        if (mounted) context.go('/profile-setup');
      }
    } else {
      _showSnackBar('Invalid phone number or password', isError: true);
    }
  }

  Future<void> _handleSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final storage = sl<OnboardingStorageService>();
    await storage.saveCredentials(
      _signupPhoneController.text,
      _signupPasswordController.text,
    );
    await storage.setLoggedIn(true);

    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSnackBar('Account created!');
    context.go('/profile-setup');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(message, style: GoogleFonts.dmSans(color: Colors.white)),
          ],
        ),
        backgroundColor: isError ? const Color(0xFF991B1B) : const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AdEnabledScreen(
        child: Stack(
          children: [
            // Background radial glows
            Positioned(
              top: -40,
              right: -40,
              child: _glowCircle(_purple, 200, 0.08),
            ),
            Positioned(
              bottom: 100,
              left: -60,
              child: _glowCircle(_gold, 220, 0.06),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Hero section
                  _buildHero(),

                  // Tab bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildTabBar(),
                  ),
                  const SizedBox(height: 24),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLoginForm(),
                        _buildSignupForm(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowCircle(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Column(
        children: [
          // Icon with glow
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _card,
              border: Border.all(color: _gold.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _gold.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.movie_creation_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'WELCOME BACK',
            style: GoogleFonts.bebasNeue(
              fontSize: 32,
              letterSpacing: 5,
              color: _text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in or create your account',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: _muted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Color(0xFFE8B84B), Color(0xFFD4A032)],
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.black,
        unselectedLabelColor: _muted,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Sign Up'),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Native Ad
            const HybridNativeAdWidget(adKey: 'login_signup'),
            _fieldLabel('Phone Number'),
            _buildPhoneField(_loginPhoneController),
            const SizedBox(height: 16),
            _fieldLabel('Password'),
            _buildPasswordField(
              controller: _loginPasswordController,
              obscure: _loginObscure,
              onToggle: () => setState(() => _loginObscure = !_loginObscure),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot password?',
                  style: GoogleFonts.dmSans(
                    color: _purple,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildGoldButton(
              label: 'Login',
              onTap: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('Phone Number'),
            _buildPhoneField(_signupPhoneController),
            const SizedBox(height: 16),
            _fieldLabel('Password'),
            _buildPasswordField(
              controller: _signupPasswordController,
              obscure: _signupObscure,
              onToggle: () => setState(() => _signupObscure = !_signupObscure),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Confirm Password'),
            _buildPasswordField(
              controller: _signupConfirmPasswordController,
              obscure: _signupConfirmObscure,
              onToggle: () => setState(
                      () => _signupConfirmObscure = !_signupConfirmObscure),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _signupPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            _buildGoldButton(
              label: 'Create Account',
              onTap: _isLoading ? null : _handleSignup,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 11,
          color: _muted,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPhoneField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      style: GoogleFonts.dmSans(color: _text, fontSize: 15),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        counterText: '',
        fillColor: _card,
        filled: true,
        hintText: '98765 43210',
        hintStyle: GoogleFonts.dmSans(color: _muted, fontSize: 15),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+91',
              style: GoogleFonts.dmSans(
                color: _gold,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: GoogleFonts.dmSans(color: const Color(0xFFEF4444), fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your phone number';
        if (value.length != 10) return 'Phone number must be 10 digits';
        if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(value)) {
          return 'Enter a valid Indian phone number';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.dmSans(color: _text, fontSize: 15),
      decoration: InputDecoration(
        fillColor: _card,
        filled: true,
        hintText: '••••••••',
        hintStyle: GoogleFonts.dmSans(color: _muted, fontSize: 18, letterSpacing: 3),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: _muted, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: _muted,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: GoogleFonts.dmSans(color: const Color(0xFFEF4444), fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) return 'Please enter your password';
            if (value.length < 6) return 'At least 6 characters required';
            return null;
          },
    );
  }

  Widget _buildGoldButton({
    required String label,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: onTap != null
              ? const LinearGradient(
            colors: [Color(0xFFE8B84B), Color(0xFFD4A032)],
          )
              : null,
          color: onTap == null ? _border : null,
          boxShadow: onTap != null
              ? [
            BoxShadow(
              color: const Color(0xFFE8B84B).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2.5,
            ),
          )
              : Text(
            label,
            style: GoogleFonts.dmSans(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}