import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../widgets/general/app_logo.dart';
import '../../../widgets/general/field_with_icon.dart';
import '../../../widgets/general/gradient_icon_button.dart';
import '../../../widgets/general/gradient_button.dart';
import '../../../widgets/dialog/information_dialog.dart';
import 'sign_up_cubit.dart';
import 'sign_up_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static Widget newInstance() {
    return BlocProvider(
      create: (context) => SignUpCubit(),
      child: const SignUpScreen(),
    );
  }

  @override
  State<SignUpScreen> createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  SignUpCubit get cubit => context.read<SignUpCubit>();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      cubit.updateUsername(_nameController.text);
    });
    _emailController.addListener(() {
      cubit.updateEmail(_emailController.text);
    });
    _passwordController.addListener(() {
      cubit.updatePassword(_passwordController.text);
    });
    _confirmPasswordController.addListener(() {
      cubit.updateConfirmPassword(_confirmPasswordController.text);
    });
    _phoneController.addListener(() {
      cubit.updatePhoneNumber(_phoneController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GradientIconButton(
          icon: Icons.chevron_left,
          onPressed: () {
            Navigator.pop(context);
          },
          fillColor: Colors.transparent,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppLogo(
                alignment: Alignment.centerRight,
              ),
              const SizedBox(height: 32),

              const Align(
                alignment: Alignment.centerLeft,
                child: GradientText(
                    text: 'Create an account', // 'Tạo tài khoản'
                    fontSize: 32),
              ),

              const SizedBox(height: 30),
              FieldWithIcon(
                controller: _nameController,
                hintText: 'Full name', // 'Họ và tên'
                fillColor: Theme.of(context).colorScheme.surface,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                textColor: Theme.of(context).colorScheme.primary,
                hintTextColor: Theme.of(context).colorScheme.onPrimary,
                onChanged: (value) {
                  cubit.updateUsername(value);
                },
              ),
              const SizedBox(height: 16.0),

              FieldWithIcon(
                controller: _emailController,
                hintText: 'Email address', // 'Địa chỉ email'
                fillColor: Theme.of(context).colorScheme.surface,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                textColor: Theme.of(context).colorScheme.primary,
                hintTextColor: Theme.of(context).colorScheme.onPrimary,
                onChanged: (value) {
                  cubit.updateEmail(value);
                },
              ),

              const SizedBox(height: 16.0),

              FieldWithIcon(
                controller: _phoneController,
                hintText: 'Phone number', // 'Số điện thoại'
                fillColor: Theme.of(context).colorScheme.surface,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                textColor: Theme.of(context).colorScheme.primary,
                hintTextColor: Theme.of(context).colorScheme.onPrimary,
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  cubit.updatePhoneNumber(value);
                },
              ),

              const SizedBox(height: 16.0),

              FieldWithIcon(
                controller: _passwordController,
                hintText: 'Password', // 'Mật khẩu'
                fillColor: Theme.of(context).colorScheme.surface,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                obscureText: true,
                textColor: Theme.of(context).colorScheme.primary,
                hintTextColor: Theme.of(context).colorScheme.onPrimary,
                onChanged: (value) {
                  cubit.updatePassword(value);
                },
              ),
              const SizedBox(height: 16.0),

              FieldWithIcon(
                controller: _confirmPasswordController,
                hintText: 'Confirm password', // 'Xác nhận mật khẩu'
                fillColor: Theme.of(context).colorScheme.surface,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                obscureText: true,
                textColor: Theme.of(context).colorScheme.primary,
                hintTextColor: Theme.of(context).colorScheme.onPrimary,
                onChanged: (value) {
                  cubit.updateConfirmPassword(value);
                },
              ),
              const SizedBox(height: 30),
              BlocConsumer<SignUpCubit, SignUpState>(
                listener: (context, state) {
                  if (state.processState == ProcessState.success) {
                    showDialog(
                      context: context,
                      builder: (context) => InformationDialog(
                        title: state.dialogName.toString(),
                        content: state.message.toString(),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/sign-in');
                        },
                      ),
                    );
                  }

                  if (state.processState == ProcessState.failure) {
                    showDialog(
                      context: context,
                      builder: (context) => InformationDialog(
                        title: state.dialogName.toString(),
                        content: state.message.toString(),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.processState == ProcessState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return GradientButton(
                    onPress: () async {
                      await cubit.signUp();
                    },
                    text: 'Create account', // 'Tạo tài khoản'
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}