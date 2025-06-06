import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projekakhir_praktpm/presenters/user_presenter.dart';
import 'package:projekakhir_praktpm/utils/constants.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.dangerColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userPresenter = Provider.of<UserPresenter>(context, listen: false);

      try {
        final user = await userPresenter.login(
          _emailController.text,
          _passwordController.text,
        );

        if (user != null) {
          _showSuccessSnackbar('Login berhasil! Selamat datang, ${user.username}!');
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showErrorSnackbar('Email atau password salah.');
        }
      } catch (e) {
        _showErrorSnackbar(e.toString().replaceFirst('Exception: ', ''));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.largePadding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 30.0),

              SizedBox(
                height: 150, 
                child: Center(
                  child: Image.asset(
                    'assets/logo/logo1.jpg',
                    height: 120, 
                    width: 120,  
                  ),
                ),
              ),
              const SizedBox(height: AppPadding.smallPadding),
              Text(
                'Selamat Datang',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                AppConstants.appSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.secondaryTextColor,
                    ),
              ),
              const SizedBox(height: AppPadding.extraLargePadding),

              // Input Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: AppColors.textColor, fontSize: 14.0),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Masukkan alamat email Anda',
                  prefixIcon: const Icon(Icons.alternate_email, color: AppColors.hintColor, size: 20.0),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.softGrey),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.softGrey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.accentColor, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.primaryColor,
                  focusColor: AppColors.primaryColor,
                  hoverColor: AppColors.primaryColor,
                  labelStyle: TextStyle(color: AppColors.hintColor, fontSize: 12.0),
                  hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 12.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Masukkan email yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppPadding.mediumPadding),

              // Input Password
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                style: TextStyle(color: AppColors.textColor, fontSize: 14.0),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan password Anda',
                  prefixIcon: const Icon(Icons.password_outlined, color: AppColors.hintColor, size: 20.0),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.hintColor,
                      size: 20.0,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.softGrey),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.softGrey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.accentColor, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.primaryColor,
                  focusColor: AppColors.primaryColor,
                  hoverColor: AppColors.primaryColor,
                  labelStyle: TextStyle(color: AppColors.hintColor, fontSize: 12.0),
                  hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 12.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 48.0), 

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text( 
                    'Belum punya akun?',
                    style: TextStyle(
                      color: AppColors.secondaryTextColor, 
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _isLoading
                      ? const CircularProgressIndicator(color: AppColors.accentColor)
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            foregroundColor: AppColors.textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppPadding.tinyPadding), 
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: AppPadding.largePadding, vertical: AppPadding.mediumPadding),
                            elevation: 4,
                          ),
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: AppPadding.mediumPadding),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.registerButtonCustomColor,
                  foregroundColor: AppColors.textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppPadding.tinyPadding), 
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppPadding.mediumPadding),
                  elevation: 0,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'REGISTER',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(width: AppPadding.smallPadding),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}