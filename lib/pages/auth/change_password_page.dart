import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:task_api_flutter/components/button/td_elevated_button.dart';
import 'package:task_api_flutter/components/snack_bar/td_snack_bar.dart';
import 'package:task_api_flutter/components/snack_bar/top_snack_bar.dart';
import 'package:task_api_flutter/components/text_field/td_text_field_password.dart';
import 'package:task_api_flutter/gen/assets.gen.dart';
import 'package:task_api_flutter/pages/auth/login_page.dart';
import 'package:task_api_flutter/resources/app_color.dart';
import 'package:task_api_flutter/services/local/shared_prefs.dart';
import 'package:task_api_flutter/services/remote/auth_services.dart';
import 'package:task_api_flutter/services/remote/body/change_password_body.dart';
import 'package:task_api_flutter/services/remote/code_error.dart';
import 'package:task_api_flutter/utils/validator.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, required this.email});

  final String email;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final authServices = AuthServices();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _changePassword(BuildContext context) async {
    if (formKey.currentState!.validate() == false) {
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    final body = ChangePasswordBody()
      ..password = newPasswordController.text
      ..oldPassword = currentPasswordController.text;

    authServices.changePassword(body).then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        if (!context.mounted) return;
        showTopSnackBar(
          context,
          const TDSnackBar.success(
              message: 'Password has been changed, please login 😍'),
        );
        // setState(() => isLoading = false);
        SharedPrefs.removeSeason();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => LoginPage(email: widget.email)),
          (Route<dynamic> route) => false,
        );
      } else {
        print('object message ${data['message']}');
        if (!context.mounted) return;
        showTopSnackBar(
          context,
          TDSnackBar.error(
              message: (data['message'] as String?)?.toLang ?? '😐'),
        );
        setState(() => isLoading = false);
      }
    }).catchError((onError) {
      print('object $onError');
      if (!context.mounted) return;
      showTopSnackBar(
        context,
        const TDSnackBar.error(message: "Server error 😐"),
      );
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(
                top: MediaQuery.of(context).padding.top + 38.0, bottom: 16.0),
            children: [
              const Center(
                child: Text('Change Password',
                    style: TextStyle(color: AppColor.red, fontSize: 24.0)),
              ),
              const SizedBox(height: 38.0),
              Center(
                child: Image.asset(Assets.images.todoIcon.path,
                    width: 90.0, fit: BoxFit.cover),
              ),
              const SizedBox(height: 46.0),
              TdTextFieldPassword(
                controller: currentPasswordController,
                hintText: 'Current Password',
                validator: Validator.required,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18.0),
              TdTextFieldPassword(
                controller: newPasswordController,
                hintText: 'New Password',
                validator: Validator.password,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18.0),
              TdTextFieldPassword(
                controller: confirmPasswordController,
                onChanged: (_) => setState(() {}),
                hintText: 'Confirm Password',
                validator: Validator.confirmPassword(
                    newPasswordController.text),
                onFieldSubmitted: (_) => _changePassword(context),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 92.0),
              TdElevatedButton.outline(
                onPressed: () => _changePassword(context),
                text: 'Done',
                isDisable: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
