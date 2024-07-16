import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:task_api_flutter/components/app_dialog.dart';
import 'package:task_api_flutter/components/button/td_elevated_button.dart';
import 'package:task_api_flutter/models/task_model.dart';
import 'package:task_api_flutter/pages/home/widgets/card_task.dart';
import 'package:task_api_flutter/resources/app_color.dart';
import 'package:task_api_flutter/services/remote/body/delete_task_body.dart';
import 'package:task_api_flutter/services/remote/task_services.dart';
import 'package:task_api_flutter/utils/enum.dart';

class DeletedPage extends StatefulWidget {
  const DeletedPage({super.key});

  @override
  State<DeletedPage> createState() => _DeletedPageState();
}

class _DeletedPageState extends State<DeletedPage> {
  TaskServices taskServices = TaskServices();
  List<TaskModel> tasks = [];
  bool isLoading = false;

  bool get anyTaskSelected {
    for (var element in tasks) {
      if (element.isSelected)
        return true; //chir canaf chon 1 cai thi return true. Nếu có chọn thì hiện cái dòng dưới 2 cái button
    }
    return false;
  }

  //getter
  List<String> get selectedIds {
    //list chứa id những cái task đang được chọn
    List<String> ids = [];
    for (var element in tasks) {
      // if (element.isSelected) ids.add(element.id ?? ''); //nếu = true thì add vào list ids
      //cach 2
      if (element.isSelected) [...ids, element.id];
    }
    return ids;
  }

  @override
  void initState() {
    super.initState();
    _getDeletedTasks();
  }

  // Get List Deleted Task
  Future<void> _getDeletedTasks() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1600));

    final query = {'deleted': true};

    taskServices.getListTask(queryParams: query).then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        // List<Map<String, dynamic>> maps = (data['body']['docs'] ?? [])
        //     .cast<Map<String, dynamic>>() as List<Map<String, dynamic>>;
        final maps = (data['body']['docs'] ?? []).cast<Map<String, dynamic>>()
            as List<Map<String, dynamic>>;
        tasks = maps.map((e) => TaskModel.fromJson(e)).toList();
        setState(() => isLoading = false);
      } else {
        print('object message ${data['message']}');
        setState(() => isLoading = false);
      }
    }).catchError((onError) {
      print('$onError 😐');
      setState(() => isLoading = false);
    });
  }

  // Delete Task
  //goi api
  void _deleteMultipleTask(DeleteTaskBody body) {
    taskServices.deleteMultipleTask(body).then((response) {
      final data = jsonDecode(response
          .body); //tra ve cai response va minh decode no se duoc cai ben duoi
      if (data['status_code'] == 200) {
        if (body.ids == null) {
          //
          tasks.clear();
        } else {
          for (var id in body.ids!) {
            tasks.removeWhere((element) => (element.id ?? '') == id);
          }
        }
        setState(() {});
      } else {
        print('object message ${data['message']}');
      }
    }).catchError((onError) {
      print('$onError 😐');
    });
  }

  // Restore Task
  //2 cai body giong nhau nen chung ta dung luon body cua deleted hoac co the viet cai moi tai vi minh truyen cai map len thi nó nhưu nhau
  void _restoreMultipleTask(DeleteTaskBody body) {
    taskServices.restoreMultipleTask(body).then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        if (body.ids == null) {
          tasks.clear();
        } else {
          for (var id in body.ids!) {
            tasks.removeWhere((element) => (element.id ?? '') == id);
          }
        }
        setState(() {});
      } else {
        print('object message ${data['message']}');
      }
    }).catchError((onError) {
      print('$onError 😐');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: tasks.isNotEmpty,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TdElevatedButton.smallOutline(
                onPressed: () => AppDialog.dialog(
                  context,
                  title: '😍',
                  content: 'Do you want to restore all task?',
                  action: () => _restoreMultipleTask(
                    DeleteTaskBody()..type = TaskType.RESTORE_ALL.name,
                  ),
                ),
                borderColor: AppColor.green,
                text: 'Restore All',
                textColor: AppColor.green,
                icon: const Icon(
                  Icons.restore,
                  size: 18.0,
                  color: AppColor.green,
                ),
              ),
              TdElevatedButton.smallOutline(
                onPressed: () {
                  for (var element in tasks) {
                    element.isConfirmDelete =
                        false; // đang hiện cái box yes no, xong mình chọn cái del all thì nó tắt cái nớ đi
                  }
                  setState(() {});
                  AppDialog.dialog(
                    context,
                    title: '😐',
                    content: 'Do you want to permanently delete the task list?',
                    action: () => _deleteMultipleTask(
                      DeleteTaskBody()..type = TaskType.DELETE_ALL.name,
                    ),
                  );
                },
                text: 'Delete All',
                icon: const Icon(
                  Icons.delete,
                  size: 18.0,
                  color: AppColor.red,
                ),
              ),
            ],
          ),
        ),
        if (anyTaskSelected) const SizedBox(height: 6.0),
        Visibility(
          visible: anyTaskSelected == true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => AppDialog.dialog(
                      context,
                      title: '😍',
                      content: 'Restore the selected tasks?',
                      action: () => _restoreMultipleTask(
                        DeleteTaskBody()..ids = selectedIds,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Restore selected tasks',
                        style:
                            TextStyle(color: AppColor.primary, fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => AppDialog.dialog(
                      context,
                      title: '😐',
                      content: 'Delete the selected tasks?',
                      action: () => _deleteMultipleTask(
                        DeleteTaskBody()..ids = selectedIds,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Delete selected tasks',
                        style:
                            TextStyle(color: AppColor.primary, fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!anyTaskSelected) const SizedBox(height: 8.0),
        if (tasks.isNotEmpty) const SizedBox(height: 6.0),
        const Divider(
          height: 2.0,
          indent: 20.0,
          endIndent: 20.0,
          color: AppColor.primary,
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColor.primary,
            onRefresh: () async {
              _getDeletedTasks();
            },
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColor.primary),
                  )
                : tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No deleted task',
                          style:
                              TextStyle(color: AppColor.brown, fontSize: 20.0),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 16.0),
                        itemCount: tasks.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: ((context, index) {
                          final task = tasks.reversed.toList()[index];
                          return CardTask(
                            task,
                            onRestore: () {
                              for (var element in tasks) {
                                element.isConfirmDelete = false;
                              }
                              setState(() {});
                              AppDialog.dialog(
                                context,
                                title: '😍',
                                content: 'Do you want to restore this task?',
                                action: () => _restoreMultipleTask(
                                  DeleteTaskBody()..ids = [task.id ?? ''],
                                ),
                              );
                            },
                            onDeleted: () {
                              for (var element in tasks) {
                                element.isConfirmDelete = false;
                              }
                              task.isConfirmDelete = true;
                              setState(() {});
                            },
                            onHorizontalDragEnd: (details) {
                              for (var element in tasks) {
                                element.isConfirmDelete = false;
                              }
                              task.isConfirmDelete = true;
                              setState(() {});
                            },
                            onConfirmYes: () => _deleteMultipleTask(
                              DeleteTaskBody()..ids = [task.id ?? ''],
                            ),
                            onConfirmNo: () {
                              task.isConfirmDelete = false;
                              setState(() {});
                            },
                            onSelected: () {
                              task.isSelected = !task.isSelected;
                              setState(() {});
                            },
                            confirmDeleteText: 'Permanently delete?',
                          );
                        }),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16.4),
                      ),
          ),
        ),
      ],
    );
  }
}
