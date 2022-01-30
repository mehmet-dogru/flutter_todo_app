import 'package:flutter/material.dart';
import 'package:flutter_todo_app/data/local_storage.dart';
import 'package:flutter_todo_app/main.dart';
import 'package:flutter_todo_app/models/task_model.dart';
import 'package:intl/intl.dart';

class TaskItem extends StatefulWidget {
  Task task;
  TaskItem({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  final TextEditingController _taskNameController = TextEditingController();
  late LocalStorage _localStorage;

  @override
  void initState() {
    super.initState();
    _taskNameController.text = widget.task.name;
    _localStorage = locator<LocalStorage>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
          leading: GestureDetector(
            onTap: () async {
              widget.task.isCompleted = !widget.task.isCompleted;
              await _localStorage.updateTask(task: widget.task);
              setState(() {});
            },
            child: Container(
              child: const Icon(
                Icons.check,
                color: Colors.white,
              ),
              decoration: BoxDecoration(
                color: widget.task.isCompleted ? Colors.green : Colors.white,
                border: Border.all(color: Colors.grey, width: .8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          title: widget.task.isCompleted
              ? Text(widget.task.name)
              : TextField(
                  minLines: 1,
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  controller: _taskNameController,
                  decoration: const InputDecoration(border: InputBorder.none),
                  onSubmitted: (value) async {
                    if (value.length > 3) {
                      widget.task.name = value;
                      await _localStorage.updateTask(task: widget.task);
                    }
                  },
                ),
          trailing: Text(
            DateFormat('hh:mm a').format(widget.task.createdAt),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          )),
    );
  }
}
