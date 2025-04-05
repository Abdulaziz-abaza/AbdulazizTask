import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mydo/core/constants/constants.dart';

import 'package:mydo/cubit/add_task_cubit.dart';
import 'package:mydo/cubit/add_task_state.dart';

class AddTaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddTaskCubit(),
      child: BlocBuilder<AddTaskCubit, AddTaskState>(
        builder: (context, state) {
          final cubit = context.read<AddTaskCubit>();

          return Scaffold(
            appBar: AppBar(
              title: Text('Add New Task'),
              backgroundColor: AppColors.primary,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                      context, cubit.titleController, ' Task Title'),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: cubit.descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Task Description',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  SizedBox(height: 16),
                  _buildDateSelector(context, cubit),
                  _buildTimeSelector(context, cubit, true),
                  _buildTimeSelector(context, cubit, false),
                  SizedBox(height: 16),
                  _buildDropdown(cubit),
                  SwitchListTile(
                    title: Text('Is this a group task?'),
                    subtitle:
                        Text('If yes, it will be shared with other users.'),
                    activeColor: Theme.of(context).primaryColor,
                    value: cubit.isGroupTask,
                    onChanged: cubit.toggleGroupTask,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state is AddTaskLoading
                          ? null
                          : () => cubit.addTaskToFirebase(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state is AddTaskLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Add Task',
                              style: GoogleFonts.roboto(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context, TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, AddTaskCubit cubit) {
    return ListTile(
      title: Text(cubit.selectedDate != null
          ? 'Date: ${cubit.selectedDate!.toLocal().toString().split(' ')[0]}'
          : 'Select Date'),
      trailing: IconButton(
        icon: Icon(Icons.calendar_today),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2101),
          );
          if (picked != null) cubit.updateDate(picked);
        },
      ),
    );
  }

  Widget _buildTimeSelector(
      BuildContext context, AddTaskCubit cubit, bool isStartTime) {
    final time = isStartTime ? cubit.selectedStartTime : cubit.selectedEndTime;

    return ListTile(
      title: Text(
        time != null
            ? (isStartTime
                ? 'Start Time : ${time.format(context)}'
                : 'End Time : ${time.format(context)}')
            : (isStartTime ? 'Select Start Time' : 'Select End Time'),
      ),
      trailing: IconButton(
        icon: Icon(Icons.access_time),
        onPressed: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) cubit.updateTime(picked, isStartTime);
        },
      ),
    );
  }

  Widget _buildDropdown(AddTaskCubit cubit) {
    return DropdownButtonFormField<String>(
      value: cubit.taskStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: ['Pending', 'In Progress', 'Completed']
          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          cubit.updateStatus(newValue);
        }
      },
    );
  }
}
