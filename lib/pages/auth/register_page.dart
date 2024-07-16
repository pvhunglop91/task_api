import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:task_api_flutter/components/button/td_elevated_button.dart';
import 'package:task_api_flutter/components/snack_bar/td_snack_bar.dart';
import 'package:task_api_flutter/components/snack_bar/top_snack_bar.dart';
import 'package:task_api_flutter/components/text_field/td_text_field.dart';
import 'package:task_api_flutter/components/text_field/td_text_field_password.dart';
import 'package:task_api_flutter/constants/app_constant.dart';
import 'package:task_api_flutter/gen/assets.gen.dart';
import 'package:task_api_flutter/pages/auth/login_page.dart';
import 'package:task_api_flutter/pages/auth/verification_code_page.dart';
import 'package:task_api_flutter/resources/app_color.dart';
import 'package:task_api_flutter/services/remote/auth_services.dart';
import 'package:task_api_flutter/services/remote/body/otp_body.dart';
import 'package:task_api_flutter/services/remote/body/register_body.dart';
import 'package:task_api_flutter/services/remote/code_error.dart';
import 'package:task_api_flutter/utils/validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  AuthServices authServices = AuthServices();
  final formKey = GlobalKey<FormState>();
  File? fileAvatar;
  bool isLoading = false;

  Future<String?> uploadFile(File file) async {
    const url = AppConstant.endPointUploadFile;
    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.files.addAll([
      await http.MultipartFile.fromPath('file', file.path),
    ]);
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${null}',
    });

    final stream = await request.send();

    final response = await http.Response.fromStream(stream).then((value) {
      if (value.statusCode == 200) {
        return value;
      }
      throw Exception('Failed to load data');
    });

    Map<String, dynamic> result = jsonDecode(response.body);
    print('object ${result['body']['file']}');
    return result['body']['file'];
  }

  Future<String?> uploadAvatar() async {
    return fileAvatar != null ? await uploadFile(fileAvatar!) : null;
  }

  Future<void> pickAvatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result == null) return;
    fileAvatar = File(result.files.single.path!);
    setState(() {});
  }

  Future<void> _sendOtp(BuildContext context) async {
    if (formKey.currentState!.validate() == false) {
      return;
    }

    RegisterBody body = RegisterBody()
      ..name = nameController.text.trim()
      ..email = emailController.text.trim()
      ..password = passwordController.text
      ..avatar = fileAvatar != null ? await uploadAvatar() : null;

    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 2000));

    authServices
        .sendOtp(OtpBody()..email = emailController.text.trim())
        .then((response) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) {
        print('object code ${data['body']['code']}');

        if (!context.mounted) return;
        // để xác định xem context có còn hợp lệ hay không trước khi tương tác với nó
        // vì ở phía trên có thể có lệnh xóa context
        showTopSnackBar(
          context,
          const TDSnackBar.success(
              message: 'Otp has been sent, check email 😍'),
        );
        setState(() => isLoading = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VerificationCodePage(
              registerBody: body,
            ),
          ),
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
        const TDSnackBar.error(message: 'Server error 😐'),
      );
    });
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    // nameFocus.requestFocus();
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
                child: Text(
                  'Register',
                  style: TextStyle(color: AppColor.red, fontSize: 26.0),
                ),
              ),
              const SizedBox(height: 30.0),
              Center(
                child: _buildAvatar(),
              ),
              const SizedBox(height: 40.0),
              TdTextField(
                controller: nameController,
                focusNode: nameFocus,
                hintText: 'Full Name',
                prefixIcon: const Icon(Icons.person, color: AppColor.orange),
                textInputAction: TextInputAction.next,
                validator: Validator.required,
              ),
              const SizedBox(height: 20.0),
              TdTextField(
                controller: emailController,
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email, color: AppColor.orange),
                textInputAction: TextInputAction.next,
                validator: Validator.email,
              ),
              const SizedBox(height: 20.0),
              TdTextFieldPassword(
                controller: passwordController,
                hintText: 'Password',
                textInputAction: TextInputAction.next,
                validator: Validator.password,
              ),
              const SizedBox(height: 20.0),
              TdTextFieldPassword(
                controller: confirmPasswordController,
                onChanged: (_) => setState(() {}),
                hintText: 'Confirm Password',
                onFieldSubmitted: (_) => _sendOtp(context),
                textInputAction: TextInputAction.done,
                validator: Validator.confirmPassword(
                  passwordController.text,
                ),
              ),
              const SizedBox(height: 56.0),
              TdElevatedButton(
                onPressed: () => _sendOtp(context),
                text: 'Sign up',
                isDisable: isLoading,
              ),
              const SizedBox(height: 12.0),
              RichText(
                text: TextSpan(
                  text: 'Do you have an account? ',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: AppColor.grey,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Sign in',
                      style: TextStyle(color: AppColor.red.withOpacity(0.86)),
                      recognizer: TapGestureRecognizer()
                        ..onTap =
                            () => Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                  (Route<dynamic> route) => false,
                                ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector _buildAvatar() {
    return GestureDetector(
      onTap: isLoading == true ? null : pickAvatar,
      child: Stack(
        children: [
          isLoading == true
              ? CircleAvatar(
                  radius: 34.6,
                  backgroundColor: Colors.orange.shade200,
                  child: const SizedBox.square(
                    dimension: 36.0,
                    child: CircularProgressIndicator(
                      color: AppColor.pink,
                      strokeWidth: 2.6,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(3.6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.orange),
                  ),
                  child: CircleAvatar(
                    radius: 34.6,
                    backgroundImage: fileAvatar == null
                        // ? Assets.images.defaultAvatar.provider()
                        // ? AssetImage(Assets.images.defaultAvatar.path)
                        //     as ImageProvider
                        ? Image.asset(Assets.images.defaultAvatar.path).image
                        : FileImage(
                            File(fileAvatar?.path ?? ''),
                          ),
                  ),
                ),
          const Positioned(
            right: 0.0,
            bottom: 0.0,
            child: Icon(Icons.favorite, size: 26.0, color: AppColor.red),
            // child: Container(
            //   padding: const EdgeInsets.all(4.0),
            //   decoration: BoxDecoration(
            //       color: Colors.white,
            //       shape: BoxShape.circle,
            //       border: Border.all(color: Colors.pink)),
            //   child: const Icon(
            //     Icons.camera_alt_outlined,
            //     size: 14.6,
            //     color: AppColor.pink,
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}
