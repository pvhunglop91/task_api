import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:task_api_flutter/components/button/td_elevated_button.dart';
import 'package:task_api_flutter/components/snack_bar/td_snack_bar.dart';
import 'package:task_api_flutter/components/snack_bar/top_snack_bar.dart';
import 'package:task_api_flutter/components/text_field/td_text_field.dart';
import 'package:task_api_flutter/constants/app_constant.dart';
import 'package:task_api_flutter/gen/assets.gen.dart';
import 'package:task_api_flutter/models/app_user_model.dart';
import 'package:task_api_flutter/pages/main_page.dart';
import 'package:task_api_flutter/resources/app_color.dart';
import 'package:task_api_flutter/services/remote/body/profile_body.dart';
import 'package:task_api_flutter/services/remote/account_services.dart';
import 'package:task_api_flutter/services/remote/code_error.dart';
import 'package:task_api_flutter/utils/validator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.appUser,
    required this.pageIndex,
  });

  final AppUserModel appUser;
  final int pageIndex;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  AccountServices accountServices = AccountServices();
  File? fileAvatar;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.appUser.name ?? '';
    emailController.text = widget.appUser.email ?? '';
    // setState(() {});
  }

  Future<void> _updateProfile(BuildContext context) async {
    if (formKey.currentState!.validate() == false) {
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 2000));

    final body = ProfileBody()
      ..name = nameController.text.trim()
      ..avatar = fileAvatar != null ? await uploadAvatar() : null;

    accountServices.updateProfile(body).then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        if (!context.mounted) return;
        showTopSnackBar(
          context,
          const TDSnackBar.success(message: 'Profile has been saved 😍'),
        );
        // setState(() => isLoading = false);
        Route route = MaterialPageRoute(
          builder: (context) =>
              MainPage(title: 'Tasks', pageIndex: widget.pageIndex),
        );
        Navigator.of(context)
            .pushAndRemoveUntil(route, (Route<dynamic> route) => false);
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
    return fileAvatar != null
        ? await uploadFile(fileAvatar!).then((value) {
            return value;
          }).catchError((onError) {
            print('$onError');
            return null;
          })
        : null;
  }

  Future<void> pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result == null) return;
    fileAvatar = File(result.files.single.path!);
    setState(() {});
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
              const Text(
                'My Profile',
                style: TextStyle(color: AppColor.red, fontSize: 24.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 38.0),
              Center(
                child: _buildAvatar(),
              ),
              const SizedBox(height: 42.0),
              TdTextField(
                controller: nameController,
                hintText: "Full Name",
                prefixIcon: const Icon(Icons.person, color: AppColor.orange),
                validator: Validator.required,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 18.0),
              TdTextField(
                controller: emailController,
                hintText: "Email",
                readOnly: true,
                prefixIcon: const Icon(Icons.email, color: AppColor.orange),
              ),
              const SizedBox(height: 72.0),
              TdElevatedButton(
                onPressed: () => _updateProfile(context),
                text: 'Save',
                isDisable: isLoading,
              ),
              const SizedBox(height: 20.0),
              TdElevatedButton.outline(
                onPressed: () => Navigator.pop(context),
                text: 'Back',
                isDisable: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    const radius = 34.0;
    return GestureDetector(
      onTap: isLoading ? null : pickAvatar,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: isLoading
                ? CircleAvatar(
                    radius: radius,
                    backgroundColor: Colors.orange.shade200,
                    child: const SizedBox.square(
                      dimension: 32.0,
                      child: CircularProgressIndicator(
                        color: AppColor.pink,
                        strokeWidth: 2.0,
                      ),
                    ),
                  )
                : fileAvatar != null
                    ? CircleAvatar(
                        radius: radius,
                        backgroundImage:
                            FileImage(File(fileAvatar?.path ?? '')),
                      )
                    : widget.appUser.avatar != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(radius),
                            child: Image.network(
                              '${AppConstant.endPointBaseImage}/${widget.appUser.avatar!}',
                              fit: BoxFit.cover,
                              width: radius * 2,
                              height: radius * 2,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: radius * 2,
                                  height: radius * 2,
                                  color: AppColor.orange,
                                  child: const Center(
                                    child: Icon(Icons.error_rounded,
                                        color: AppColor.white),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return const SizedBox.square(
                                  dimension: radius * 2,
                                  child: Center(
                                    child: SizedBox.square(
                                      dimension: 26.0,
                                      child: CircularProgressIndicator(
                                        color: AppColor.pink,
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : CircleAvatar(
                            radius: radius,
                            backgroundImage:
                                // Assets.images.defaultAvatar.provider()
                                AssetImage(Assets.images.defaultAvatar.path),
                          ),
          ),
          Positioned(
            right: 0.0,
            bottom: 0.0,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.pink)),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 14.6,
                color: Colors.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
