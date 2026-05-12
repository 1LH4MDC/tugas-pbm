// lib/screens/add_product_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await _apiService.addProduct(
      _nameController.text.trim(),
      int.parse(_priceController.text.trim()),
      _descController.text.trim(),
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil ditambahkan! ✅'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menambahkan produk. Coba lagi.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Widget helper untuk membuat field yang seragam
  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF0C344D),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFF0C344D)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: const Color(0xFF1A6B9A))
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF1A6B9A), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: maxLines > 1
                ? const EdgeInsets.all(16)
                : const EdgeInsets.symmetric(vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: const Text(
          'Tambah Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0C344D),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header Info ──────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C344D).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF0C344D).withOpacity(0.12),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFF0C344D), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Data produk tidak dapat diedit setelah disimpan. Pastikan sudah benar.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF0C344D),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Field Nama ───────────────────────────
              _buildField(
                label: 'Nama Produk',
                hint: 'Contoh: Macbook Pro M5 2026',
                icon: Icons.label_outline_rounded,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  if (value.length < 3) {
                    return 'Nama produk minimal 3 karakter';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ── Field Harga ──────────────────────────
              _buildField(
                label: 'Harga (Rp)',
                hint: 'Contoh: 32450000',
                icon: Icons.payments_outlined,
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  final price = int.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Masukkan harga yang valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ── Field Deskripsi ──────────────────────
              _buildField(
                label: 'Deskripsi',
                hint: 'Jelaskan produk kamu secara singkat...',
                icon: Icons.description_outlined,
                controller: _descController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  if (value.length < 10) {
                    return 'Deskripsi minimal 10 karakter';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // ── Preview Harga ────────────────────────
              ValueListenableBuilder(
                valueListenable: _priceController,
                builder: (context, value, _) {
                  final raw = int.tryParse(_priceController.text);
                  if (raw == null || raw == 0) {
                    return const SizedBox.shrink();
                  }
                  final formatted = raw
                      .toString()
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (m) => '${m[1]}.',
                      );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A6B9A).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1A6B9A).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long_outlined,
                            color: Color(0xFF1A6B9A), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Preview harga: Rp $formatted',
                          style: const TextStyle(
                            color: Color(0xFF1A6B9A),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ── Tombol Simpan ────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C344D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isLoading ? 'Menyimpan...' : 'Simpan Produk',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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