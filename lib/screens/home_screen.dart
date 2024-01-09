// ignore_for_file: avoid_print, sort_child_properties_last
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:todo_api_app/screens/add_task.dart';
import 'package:todo_api_app/widgets/custom_appbar.dart';

enum Value {
  edit,
  delete,
  isCompleted,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    fetchTodo();
    items;
    super.initState();
  }

  List items = [];
  bool isLoading = true;

  Future<void> fetchTodo() async {
    const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    print(response.body);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
      print('refreshing $isLoading');
    });
  }

//Delete the item
//Remove item from list
  Future<void> deleteById(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filteredItems =
          items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filteredItems;
      });
    } else {
      showFailureMessage('Deletion Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO APP'),
        flexibleSpace: const CustomAppBar(),
      ),
      body: Visibility(
        visible: isLoading,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.indigoAccent,
          ),
        ),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          color: Colors.indigoAccent,
          child: Visibility(
            visible: items.isEmpty,
            child: Center(
              child: Text(
                'No Todo Items',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            replacement: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return Card(
                  color: const Color.fromARGB(133, 51, 78, 234),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigoAccent,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == Value.edit) {
                          navigateToEditPage(item);
                        } else if (value == Value.delete) {
                          deleteById(id);
                        } else if (value == Value.isCompleted) {
                          
                        }
                      },
                      color: const Color.fromARGB(255, 55, 81, 223),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            child: Text('Edit'),
                            value: Value.edit,
                          ),
                          const PopupMenuItem(
                            child: Text('Delete'),
                            value: Value.delete,
                          ),
                        ];
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddPage,
        backgroundColor: Colors.indigoAccent,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
          weight: 20,
        ),
      ),
    );
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: ((context) => const AddTaskScreen()),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: ((context) => AddTaskScreen(
            todo: item,
          )),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
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
