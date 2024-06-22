import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:task_api_flutter/components/td_zoom_drawer.dart';
import 'package:task_api_flutter/pages/home/drawer_page.dart';
import 'package:task_api_flutter/pages/home/home_page.dart';
import 'package:task_api_flutter/resources/app_color.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final zoomDrawerController = ZoomDrawerController();

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
        appBar: AppBar(
          leading: GestureDetector(
              onTap: toggleDrawer,
              child: const Icon(Icons.menu, color: AppColor.brown)),
          title: Text(
            widget.title,
            style: const TextStyle(color: AppColor.red, fontSize: 20.0),
          ),
          centerTitle: true,
        ),
        body: TdZoomDrawer(
          controller: zoomDrawerController,
          menuScreen: const DrawerPage(),
          screen: const HomePage(),
        ),
      ),
    );
  }
}
