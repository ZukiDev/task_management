import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/local/session_storage.dart';
import '../../data/models/task_model.dart';
import '../../data/models/task_priority.dart';
import '../../data/repositories/task_repository_impl.dart';
import 'task_form_controller.dart';

/// Halaman form, dipakai untuk DUA mode sekaligus:
/// - Add (existingTask == null): judul "Tambah Task"
/// - Edit (existingTask != null): judul "Edit Task", field di-prefill
///
/// Pendekatan satu halaman untuk dua mode ini menghindari duplikasi
/// kode form yang sebenarnya identik strukturnya.
class TaskFormPage extends StatefulWidget {
  final TaskModel? existingTask;

  const TaskFormPage({super.key, this.existingTask});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TaskPriority _selectedPriority;

  late final TaskFormController _controller;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;

    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _selectedDate = task?.dueDate ?? DateTime.now();
    _selectedPriority = task?.priority ?? TaskPriority.medium;

    final apiClient = ApiClient();
    final sessionStorage = SessionStorage();
    final taskRepository = TaskRepositoryImpl(
      TaskRemoteDatasource(apiClient),
      sessionStorage,
    );
    _controller = TaskFormController(taskRepository, existingTask: task);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {});
    final result = await _controller.submit(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDate,
      priority: _selectedPriority,
    );
    setState(() {});

    if (!mounted) return;

    if (result != null) {
      final message = _controller.isEditMode
          ? 'Task berhasil diperbarui'
          : 'Task berhasil ditambahkan';
      Navigator.of(context).pop(message);
    } else if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_controller.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _controller.isEditMode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          isEdit ? 'Edit Task' : 'Tambah Task',
          style: AppTextStyles.heading2,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  validator: Validators.taskTitle,
                  decoration: const InputDecoration(
                    labelText: 'Judul task',
                    hintText: 'Contoh: Review dokumen kontrak',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  validator: (v) =>
                      Validators.required(v, fieldName: 'Deskripsi'),
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Jelaskan detail task ini',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDatePicker(),
                const SizedBox(height: 16),
                _buildPrioritySelector(),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _controller.isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _controller.isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            isEdit ? 'Simpan Perubahan' : 'Tambah Task',
                            style: AppTextStyles.button,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Tanggal jatuh tempo',
          prefixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text(DateFormatter.toDisplay(_selectedDate)),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prioritas', style: AppTextStyles.caption),
        const SizedBox(height: 8),
        Row(
          children: TaskPriority.values.map((p) {
            final isSelected = _selectedPriority == p;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(p.label),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedPriority = p),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
