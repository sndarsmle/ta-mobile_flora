// lib/views/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projekakhir_praktpm/models/user_model.dart';
import 'package:projekakhir_praktpm/presenters/user_presenter.dart';
import 'package:projekakhir_praktpm/utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userPresenter = Provider.of<UserPresenter>(context, listen: false);
      
      try {
        if (_passwordController.text != _confirmPasswordController.text) {
          _showErrorSnackbar('Konfirmasi password tidak cocok.');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final newUser = User(
          id: '',
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

        await userPresenter.register(newUser);

        _showSuccessSnackbar('Registrasi berhasil! Silakan login.');
        Navigator.pushReplacementNamed(context, '/login'); 
      } catch (e) {
        _showErrorSnackbar(e.toString().replaceFirst('Exception: ', ''));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                'Daftar Akun',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                AppConstants.registSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.secondaryTextColor,
                    ),
              ),
              const SizedBox(height: AppPadding.extraLargePadding),

              // Input Username
              TextFormField(
                controller: _usernameController,
                style: TextStyle(color: AppColors.textColor, fontSize: 14.0),
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Masukkan username Anda',
                  prefixIcon: const Icon(Icons.person, color: AppColors.hintColor, size: 20.0),
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
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppPadding.mediumPadding),

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
                  if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                  return null;
                },
              ),
              const SizedBox(height: AppPadding.mediumPadding),

              // Input Konfirmasi Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_confirmPasswordVisible,
                style: TextStyle(color: AppColors.textColor, fontSize: 14.0),
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  hintText: 'Konfirmasi password Anda',
                  prefixIcon: const Icon(Icons.password_outlined, color: AppColors.hintColor, size: 20.0),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.hintColor,
                      size: 20.0,
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
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
                    return 'Konfirmasi password tidak boleh kosong';
                  }
                  if (value != _passwordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48.0), 

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                
                  Text( 
                    'Sudah punya akun?',
                    style: TextStyle(
                      color: AppColors.secondaryTextColor, 
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  _isLoading
                      ? const CircularProgressIndicator(color: AppColors.accentColor)
                      : ElevatedButton(
                          onPressed: _register,
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
                            'DAFTAR',
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
                  Navigator.pushReplacementNamed(context, '/login');
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
                      'SIGN IN',
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