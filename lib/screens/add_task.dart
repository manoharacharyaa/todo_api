// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print, use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:todo_api_app/providers/app_logic.dart';
import 'package:todo_api_app/widgets/custom_appbar.dart';
import 'package:todo_api_app/widgets/custom_button.dart';
import 'package:todo_api_app/widgets/custom_textfield.dart';

class AddTaskScreen extends StatefulWidget {
  final Map? todo;
  const AddTaskScreen({super.key, this.todo});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      _titleController.text = title;
      _descController.text = description;
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLogic = Provider.of<AppLogic>(context);

    // final _title = _titleController.value.toString();
    // final _description = _descController.value.toString();

    Future<void> submitData() async {
      final body = {
        "title": _titleController.text,
        "description": _descController.text,
        "is_completed": false,
      };
      final uri = Uri.parse('https://api.nstack.in/v1/todos');
      final response = await http.post(
        uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        _titleController.text = '';
        _descController.text = '';
        appLogic.loading();
        showSucessMessage('Task Created Sucessfully');
      } else {
        appLogic.loading();
        showFailureMessage('Task Not Created');
      }
    }

    Future<void> updateData() async {
      final todo = widget.todo;
      if (todo == null) {
        print('Empty todo data');
        return;
      }
      final id = todo['_id'];
      final body = {
        "title": _titleController.text,
        "description": _descController.text,
        "is_completed": false,
      };
      final uri = Uri.parse('https://api.nstack.in/v1/todos/$id');
      final response = await http.put(
        uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _titleController.text = '';
        _descController.text = '';
        appLogic.loading();
        showSucessMessage('Task Updated Sucessfully');
      } else {
        appLogic.loading();
        showFailureMessage('Task Not Updated');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'Add Task'),
        flexibleSpace: const CustomAppBar(),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            CustomTextField(
              controller: _titleController,
              hintText: isEdit ? 'Edit Title' : 'Title',
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _descController,
              hintText: isEdit ? 'Edit Description' : 'Description',
              maxLines: 10,
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: isEdit ? 'Update' : 'Submit',
              isLoading: appLogic.isLoading,
              onPressed: () {
                appLogic.loading();
                isEdit ? updateData() : submitData();
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void showSucessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showFailureMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
