import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_button.dart';
import '../../../enums/processing/process_state_enum.dart';
import 'forget_password_cubit.dart';
import '../../../widgets/general/app_logo.dart';
import '../../../widgets/general/field_with_icon.dart';
import 'forget_password_state.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  static Widget newInstance() {
    return BlocProvider(
      create: (context) => ForgetPasswordCubit(),
      child: const ForgetPasswordScreen(),
    );
  }

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  ForgetPasswordCubit get cubit => context.read<ForgetPasswordCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
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
                    text: 'Forget Password', // 'Quên Mật Khẩu'
                    fontSize: 32),
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Do not worry! It happens. Please enter the email associated with your account.', //'Đừng lo lắng! Điều này có thể xảy ra. Vui lòng nhập email liên kết với tài khoản của bạn.'
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email address', // 'Địa chỉ email'
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              FieldWithIcon(
                controller: _emailController,
                hintText: 'Enter your email address', // 'Nhập địa chỉ email của bạn'
                fillColor: Theme.of(context).colorScheme.surface,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                obscureText: false,
                textColor: Theme.of(context).colorScheme.primary,
                hintTextColor: Theme.of(context).colorScheme.onPrimary,
                onChanged: (value) {
                  cubit.emailChanged(value);
                },
              ),
              const SizedBox(height: 40.0),

              BlocListener<ForgetPasswordCubit, ForgetPasswordState>(
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
                  } else if (state.processState == ProcessState.failure) {
                    showDialog(
                      context: context,
                      builder: (context) => InformationDialog(
                        title: state.dialogName.toString(),
                        content: state.message.toString(),
                      ),
                    );
                  }
                },
                child: GradientButton(
                  text: 'Send Verification Link', // 'Gửi Liên Kết Xác Thực'
                  onPress: () {
                    cubit.sendVerificationLink(_emailController.text.trim());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}