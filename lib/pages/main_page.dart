import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:task_api_flutter/components/snack_bar/td_snack_bar.dart';
import 'package:task_api_flutter/components/snack_bar/top_snack_bar.dart';
import 'package:task_api_flutter/components/td_app_bar.dart';
import 'package:task_api_flutter/components/td_zoom_drawer.dart';
import 'package:task_api_flutter/constants/app_constant.dart';
import 'package:task_api_flutter/models/app_user_model.dart';
import 'package:task_api_flutter/pages/home/drawer_page.dart';
import 'package:task_api_flutter/pages/home/completed_page.dart';
import 'package:task_api_flutter/pages/home/deleted_page.dart';
import 'package:task_api_flutter/pages/home/home_page.dart';
import 'package:task_api_flutter/pages/home/uncompleted_page.dart';
import 'package:task_api_flutter/pages/profile/profile_page.dart';
import 'package:task_api_flutter/resources/app_color.dart';
import 'package:task_api_flutter/services/remote/account_services.dart';
import 'package:task_api_flutter/services/remote/code_error.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.title,
    this.pageIndex,
  });

  final String title;
  final int? pageIndex;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final zoomDrawerController = ZoomDrawerController();
  late int selectedIndex;
  AccountServices accountServices = AccountServices();
  AppUserModel appUser = AppUserModel();

  List pages = [
    const HomePage(),
    const CompletedPage(),
    const UncompletedPage(),
    const DeletedPage(),
  ];

  List<IconData> listIconData = [
    Icons.home,
    Icons.check_box,
    Icons.check_box_outline_blank,
    Icons.delete,
  ];

  List<String> listLabel = [
    'All',
    'Completed',
    'Uncompleted',
    'Deleted',
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.pageIndex ?? 0;
    _getProfile(context);
  }

  void _getProfile(BuildContext context) {
    accountServices.getProfile().then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        appUser = AppUserModel.fromJson(data['body']);
        setState(() {});
      } else {
        print('object message ${data['message']}');
        if (!context.mounted) return;
        showTopSnackBar(
          context,
          TDSnackBar.error(
              message: (data['message'] as String?)?.toLang ?? '😐'),
        );
      }
    }).catchError((onError) {
      if (!context.mounted) return;
      showTopSnackBar(
        context,
        TDSnackBar.error(message: '$onError 😐'),
      );
    });
  }

  toggleDrawer() {
    zoomDrawerController.toggle?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.bgColor,
        appBar: TdAppBar(
          leftPressed: toggleDrawer,
          rightPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                ProfilePage(appUser: appUser, pageIndex: selectedIndex),
          )),
          title: widget.title,
          avatar: '${AppConstant.endPointBaseImage}/${appUser.avatar ?? ''}',
          // avatar: AppConstant.baseImage(appUser.avatar ?? ''),
        ),
        body: TdZoomDrawer(
          controller: zoomDrawerController,
          menuScreen: DrawerPage(appUser: appUser, pageIndex: selectedIndex),
          screen: pages[selectedIndex],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return AnimatedContainer(
      height: 52.0,
      duration: const Duration(milliseconds: 2000),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: List.generate(
          4,
          (index) => Expanded(child: _navigationItem(index)),
        ),
        // children: [
        //   Expanded(
        //     child: _navigationItem(0),
        //   ),
        //   Expanded(
        //     child: _navigationItem(1),
        //   ),
        //   Expanded(
        //     child: _navigationItem(2),
        //   ),
        //   Expanded(
        //     child: _navigationItem(3),
        //   ),
        // ],
      ),
    );
  }

  Widget _navigationItem(int index) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          selectedIndex = index;
          zoomDrawerController.close?.call();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary.withOpacity(0.2),
              AppColor.primary.withOpacity(0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              listIconData[index],
              size: 22.0,
              color:
                  index == selectedIndex ? Colors.amber[800] : AppColor.dark500,
            ),
            Text(
              listLabel[index],
              style: TextStyle(
                color: index == selectedIndex
                    ? Colors.amber[800]
                    : AppColor.dark500,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _navigationItem(int index) {
  //   return GestureDetector(
  //     behavior: HitTestBehavior.translucent,
  //     onTap: () {
  //       setState(() {
  //         selectedIndex = index;
  //         zoomDrawerController.close?.call();
  //       });
  //     },
  //     child: Container(
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [
  //             AppColor.primary.withOpacity(0.2),
  //             AppColor.primary.withOpacity(0.05),
  //           ],
  //           begin: Alignment.centerLeft,
  //           end: Alignment.centerRight,
  //         ),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             // index == 0
  //             //     ? Icons.home
  //             //     : index == 1
  //             //         ? Icons.check_box
  //             //         : index == 2
  //             //             ? Icons.check_box_outline_blank
  //             //             : Icons.delete,
  //             () {
  //               if (index == 0) return Icons.home;
  //               if (index == 1) return Icons.check_box;
  //               if (index == 2) return Icons.check_box_outline_blank;
  //               return Icons.delete;
  //             }(),
  //             size: 22.0,
  //             color:
  //                 index == selectedIndex ? Colors.amber[800] : AppColor.dark500,
  //           ),
  //           Text(
  //             () {
  //               if (index == 0) return 'All';
  //               if (index == 1) return 'Completed';
  //               if (index == 2) return 'Uncompleted';
  //               return 'Deleted';
  //             }(),
  //             style: TextStyle(
  //               color: index == selectedIndex
  //                   ? Colors.amber[800]
  //                   : AppColor.dark500,
  //               fontSize: 12.0,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
