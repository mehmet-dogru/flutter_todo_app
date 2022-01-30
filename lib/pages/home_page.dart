import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_todo_app/data/local_storage.dart';
import 'package:flutter_todo_app/main.dart';
import 'package:flutter_todo_app/models/task_model.dart';
import 'package:flutter_todo_app/widgets/task_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Task> _allTasks;
  late LocalStorage _localStorage;

  @override
  void initState() {
    super.initState();
    _localStorage = locator<LocalStorage>();
    _allTasks = [];
    _getAllTaskFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _showAddTaskBottomSheet(context);
          },
          child: const Text(
            'Bugün neler yapacaksın?',
            style: TextStyle(color: Colors.black),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              _showAddTaskBottomSheet(context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _allTasks.isNotEmpty
          ? ListView.builder(
              itemBuilder: (context, index) {
                var _oAnkiEleman = _allTasks[index];
                return Dismissible(
                  background: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      Text('Bu görev silindi.'),
                    ],
                  ),
                  key: Key(_oAnkiEleman.id),
                  onDismissed: (direction) {
                    setState(() {
                      _allTasks.removeAt(index);
                      _localStorage.deleteTask(task: _oAnkiEleman);
                    });
                  },
                  child: TaskItem(task: _oAnkiEleman),
                );
              },
              itemCount: _allTasks.length,
            )
          : const Center(
              child: Text(
                'Yeni Görev Ekleyin',
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
            ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          width: MediaQuery.of(context).size.width,
          child: ListTile(
            autofocus: true,
            title: TextField(
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                hintText: 'Görev Nedir?',
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                Navigator.of(context).pop();
                if (value.length > 3) {
                  DatePicker.showTimePicker(
                    context,
                    showSecondsColumn: false,
                    onConfirm: (time) async {
                      var newAddTask =
                          Task.create(name: value, createdAt: time);
                      _allTasks.add(newAddTask);
                      await _localStorage.addTask(task: newAddTask);
                      setState(() {});
                    },
                  );
                } else {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return const ListTile(
                        title:
                            Text('Girdiğiniz değer üç harften fazla olmalı!'),
                      );
                    },
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _getAllTaskFromDB() async {
    _allTasks = await _localStorage.getAllTask();
    setState(() {});
  }
}
