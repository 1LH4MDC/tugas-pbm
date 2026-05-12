// lib/screens/submit_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SubmitScreen extends StatefulWidget {
  const SubmitScreen({super.key});

  @override
  State<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _githubController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Konfirmasi sebelum submit
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFF0C344D)),
            SizedBox(width: 8),
            Text('Konfirmasi Submit'),
          ],
        ),
        content: const Text(
          'Pastikan semua data sudah benar.\nData TIDAK dapat diubah setelah submit!',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cek Lagi',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C344D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Submit!'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final success = await _apiService.submitTugas(
      name: _nameController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      description: _descController.text.trim(),
      githubUrl: _githubController.text.trim(),
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (success) {
      setState(() => _isSubmitted = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal submit. Periksa koneksi internet kamu.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Tampilan sukses setelah submit
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 72),
            ),
            const SizedBox(height: 28),
            const Text(
              'Tugas Berhasil Disubmit!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C344D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Waktu submit telah tercatat otomatis oleh sistem. Pastikan repository GitHub kamu dapat diakses.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C344D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Kembali ke Beranda',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: const Text(
          'Submit Tugas',
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
      body: _isSubmitted
          ? _buildSuccessView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Warning Box ──────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Data yang disubmit TIDAK dapat diubah. Pastikan nama produk, harga, deskripsi, dan link GitHub sudah benar!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildLabel('Nama Produk'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Contoh: Laptop Asus VivoBook',
                      icon: Icons.label_outline_rounded,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Nama tidak boleh kosong'
                          : null,
                    ),

                    const SizedBox(height: 20),

                    _buildLabel('Harga (Rp)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _priceController,
                      hint: 'Contoh: 8500000',
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Harga tidak boleh kosong';
                        }
                        if (int.tryParse(v) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildLabel('Deskripsi'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descController,
                      hint: 'Deskripsi singkat produk...',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Deskripsi tidak boleh kosong'
                          : null,
                    ),

                    const SizedBox(height: 20),

                    _buildLabel('Link GitHub Repository'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _githubController,
                      hint: 'https://github.com/username/nama-repo',
                      icon: Icons.link_rounded,
                      keyboardType: TextInputType.url,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Link GitHub tidak boleh kosong';
                        }
                        if (!v.startsWith('https://github.com/')) {
                          return 'Link harus diawali https://github.com/';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 36),

                    // ── Tombol Submit ────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submit,
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
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          _isLoading ? 'Mengirim...' : 'Submit Tugas',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Color(0xFF0C344D),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Color(0xFF0C344D)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: const Color(0xFF1A6B9A))
            : null,
        contentPadding: maxLines > 1
            ? const EdgeInsets.all(16)
            : const EdgeInsets.symmetric(vertical: 16),
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
      ),
      validator: validator,
    );
  }
}