import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';

class CreateGoalScreen extends StatefulWidget {
  final String currentUserId;
  final Goal? existingGoal; // Add this parameter for editing
  final bool? isGroupGoal;

  const CreateGoalScreen({
    super.key,
    required this.currentUserId,
    this.existingGoal, // Make it optional for creation
    this.isGroupGoal,
  });

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  bool _isGroupGoal = false;
  List<String> _selectedParticipants = [];

  // Mock friends list - replace with your actual data source
  final Map<String, String> _friends = {
    'friend1': 'Alice Johnson',
    'friend2': 'Bob Smith',
    'friend3': 'Charlie Brown',
    'friend4': 'Diana Prince',
  };

  @override
  void initState() {
    super.initState();
    // Initialize with existing goal data if editing
    if (widget.existingGoal != null) {
      _titleController.text = widget.existingGoal!.title;
      _descriptionController.text = widget.existingGoal!.description;
      _dueDate = widget.existingGoal!.dueDate;
      _isGroupGoal = widget.existingGoal!.isGroupGoal;
      // Filter out current user from participants to show in UI
      _selectedParticipants = widget.existingGoal!.participants
          .where((id) => id != widget.currentUserId)
          .toList();
    } else if (widget.isGroupGoal != null) {
      _isGroupGoal = widget.isGroupGoal!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _toggleParticipant(String friendId) {
    setState(() {
      if (_selectedParticipants.contains(friendId)) {
        _selectedParticipants.remove(friendId);
      } else {
        _selectedParticipants.add(friendId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingGoal == null ? 'Add New Goal' : 'Edit Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dueDate == null
                          ? 'No due date set'
                          : 'Due: ${_dueDate!.toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Set Due Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text(
                  'Group Goal',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Share this goal with friends'),
                value: _isGroupGoal,
                onChanged: (value) {
                  setState(() {
                    _isGroupGoal = value;
                    if (!value) _selectedParticipants.clear();
                  });
                },
              ),
              if (_isGroupGoal) ...[
                const SizedBox(height: 8),
                const Text(
                  'Select Friends:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _friends.entries.map((entry) {
                    return FilterChip(
                      label: Text(entry.value),
                      selected: _selectedParticipants.contains(entry.key),
                      onSelected: (_) => _toggleParticipant(entry.key),
                      avatar: CircleAvatar(
                        child: Text(entry.value.substring(0, 1)),
                      ),
                      backgroundColor: Colors.grey[200],
                      selectedColor: Colors.blue[100],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final goal = Goal(
                      id:
                          widget.existingGoal?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text,
                      description: _descriptionController.text,
                      dueDate: _dueDate,
                      createdBy: widget.currentUserId,
                      isGroupGoal: _isGroupGoal,
                      participants: _isGroupGoal
                          ? [..._selectedParticipants, widget.currentUserId]
                          : [],
                      // Preserve completion status when editing
                      isCompleted: widget.existingGoal?.isCompleted ?? false,
                      // Preserve original creation date when editing
                      createdAt:
                          widget.existingGoal?.createdAt ?? DateTime.now(),
                    );
                    Navigator.pop(context, goal);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.existingGoal == null ? 'Save Goal' : 'Update Goal',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
