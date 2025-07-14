import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/services/firestore_service.dart';

class CreateGoalScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final Goal? existingGoal;
  final bool? isGroupGoal;

  const CreateGoalScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    this.existingGoal,
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
  List<Map<String, String>> _selectedParticipants = [];

  Map<String, Map<String, String>> _friends = {};
  bool _isLoadingFriends = true;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();

    if (widget.existingGoal != null) {
      _titleController.text = widget.existingGoal!.title;
      _descriptionController.text = widget.existingGoal!.description;
      _dueDate = widget.existingGoal!.dueDate;
      _isGroupGoal = widget.existingGoal!.isGroupGoal;

      _selectedParticipants = widget.existingGoal!.participants
          .where((participant) => participant['email'] != widget.currentUserId)
          .toList();
    } else if (widget.isGroupGoal != null) {
      _isGroupGoal = widget.isGroupGoal!;
    }

    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final user = await _firestoreService.getUserByEmail(widget.currentUserId);
      if (user == null) return;

      final friendsList = await _firestoreService.getUsersByEmails(
        user.friends,
      );

      final Map<String, Map<String, String>> loadedFriends = {
        for (var f in friendsList) f.id: {'email': f.id, 'name': f.name},
      };

      setState(() {
        _friends = loadedFriends;
        _isLoadingFriends = false;
      });
    } catch (e) {
      print('Error loading friends: $e');
      setState(() {
        _isLoadingFriends = false;
      });
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

  void _toggleParticipant(String friendEmail) {
    setState(() {
      final friend = _friends[friendEmail];
      if (friend == null) return;

      if (_selectedParticipants.any((p) => p['email'] == friendEmail)) {
        _selectedParticipants.removeWhere((p) => p['email'] == friendEmail);
      } else {
        _selectedParticipants.add(friend);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              widget.existingGoal == null ? 'Add New Goal' : 'Edit Goal',
              style: const TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
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
                _isLoadingFriends
                    ? const Center(child: CircularProgressIndicator())
                    : _friends.isEmpty
                    ? const Text('No friends found')
                    : Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _friends.entries.map((entry) {
                          return FilterChip(
                            label: Text(entry.value['name'] ?? ''),
                            selected: _selectedParticipants.any(
                              (p) => p['email'] == entry.key,
                            ),
                            onSelected: (_) => _toggleParticipant(entry.key),
                            avatar: CircleAvatar(
                              child: Text(
                                entry.value['name']
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    '?',
                              ),
                            ),
                            backgroundColor: Colors.grey[200],
                            selectedColor: Colors.blue[100],
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final goal = Goal(
                        id:
                            widget.existingGoal?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _titleController.text,
                        description: _descriptionController.text,
                        dueDate: _dueDate,
                        createdBy: {
                          'email': widget.currentUserId,
                          'name': widget.currentUserName,
                        },
                        isGroupGoal: _isGroupGoal,
                        participants: [
                          ..._selectedParticipants,
                          {
                            'email': widget.currentUserId,
                            'name': widget.currentUserName,
                          },
                        ],
                        isCompleted: widget.existingGoal?.isCompleted ?? false,
                        createdAt:
                            widget.existingGoal?.createdAt ?? DateTime.now(),
                      );
                      Navigator.pop(context, goal);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.existingGoal == null ? 'Save Goal' : 'Update Goal',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
