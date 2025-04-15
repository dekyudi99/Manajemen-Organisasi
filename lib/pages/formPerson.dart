import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manajemen_organisasi/models/person.dart';
import 'package:manajemen_organisasi/services/api.dart';

class PersonFormPage extends StatefulWidget {
  final Person? person;

  const PersonFormPage({Key? key, this.person}) : super(key: key);

  @override
  _PersonFormPageState createState() => _PersonFormPageState();
}

class _PersonFormPageState extends State<PersonFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _personService = PersonService();
  bool _isLoading = false;
  File? _imageFile;
  bool _isImageChanged = false;

  // Form controllers
  final _nimController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ratingController = TextEditingController();
  final _divisionTargetController = TextEditingController();
  final _priorityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.person != null) {
      _nimController.text = widget.person!.nim;
      _titleController.text = widget.person!.titleIssues;
      _descriptionController.text = widget.person!.descriptionIssues;
      _ratingController.text = widget.person!.rating.toString();
      _divisionTargetController.text = widget.person!.idDivisionTarget.toString();
      _priorityController.text = widget.person!.idPriority.toString();
    }
  }

  @override
  void dispose() {
    _nimController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _ratingController.dispose();
    _divisionTargetController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  // Image Picker
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isImageChanged = true;
      });
    }
  }

  // Submit handler
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final rating = int.tryParse(_ratingController.text) ?? 0;
      final idDivisionTarget = int.tryParse(_divisionTargetController.text) ?? 0;
      final idPriority = int.tryParse(_priorityController.text) ?? 0;

      if (widget.person == null) {
        await _personService.createPersonWithImage(
          nim: _nimController.text,
          titleIssues: _titleController.text,
          descriptionIssues: _descriptionController.text,
          rating: rating,
          imageFile: _imageFile,
          idDivisionTarget: idDivisionTarget,
          idPriority: idPriority,
        );
      } else {
        await _personService.updatePersonWithImage(
          idCustomerService: widget.person!.idCustomerService,
          nim: _nimController.text,
          titleIssues: _titleController.text,
          descriptionIssues: _descriptionController.text,
          rating: rating,
          imageFile: _isImageChanged ? _imageFile : null,
          idDivisionTarget: idDivisionTarget,
          idPriority: idPriority,
          currentImageUrl: widget.person?.imageUrl,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.person == null ? 'Data berhasil ditambahkan' : 'Data berhasil diperbarui')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Widget builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String emptyError,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) return emptyError;
            return null;
          },
    );
  }

  Widget _buildImageSection() {
    final hasNetworkImage = widget.person?.imageUrl.isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upload Gambar:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Galeri'),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera),
              label: const Text('Kamera'),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_imageFile != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
          )
        else if (hasNetworkImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.person!.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 150),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.person == null ? 'Tambah Data' : 'Edit Data')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nimController,
                label: 'NIM',
                emptyError: 'NIM tidak boleh kosong',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _titleController,
                label: 'Judul Issue',
                emptyError: 'Judul tidak boleh kosong',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Deskripsi tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ratingController,
                label: 'Rating (1-5)',
                emptyError: 'Rating tidak boleh kosong',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final rating = int.tryParse(value ?? '');
                  if (rating == null || rating < 1 || rating > 5) return 'Masukkan angka 1-5';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildImageSection(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _divisionTargetController,
                label: 'ID Divisi Target',
                emptyError: 'ID Divisi Target tidak boleh kosong',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _priorityController,
                label: 'ID Prioritas',
                emptyError: 'ID Prioritas tidak boleh kosong',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.person == null ? 'Simpan' : 'Perbarui', style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}