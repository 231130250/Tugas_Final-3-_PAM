import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/model/transaksi_model.dart';
import 'package:wallet/providers/transaksi_provider.dart';

class AddEditTransactionSheet extends StatefulWidget {
  final TransaksiModel? transaction;

  const AddEditTransactionSheet({super.key, this.transaction});

  @override
  State<AddEditTransactionSheet> createState() =>
      _AddEditTransactionSheetState();
}

class _AddEditTransactionSheetState extends State<AddEditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;

  bool _isIncome = true;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;

    _isIncome = t?.type?.toLowerCase() == 'pemasukan';

    _amountController = TextEditingController(
      text: t?.amount?.toString() ?? '',
    );
    _descController = TextEditingController(text: t?.description ?? '');
    _categoryController = TextEditingController(text: t?.category ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    final transaksiProvider = Provider.of<TransaksiProvider>(
      context,
      listen: false,
    );

    final amount = double.tryParse(_amountController.text) ?? 0;
    final desc = _descController.text;
    final category = _categoryController.text;
    final type = _isIncome ? 'pemasukan' : 'pengeluaran';

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      if (widget.transaction == null) {
        // Tambah transaksi baru
        final newTransaksi = TransaksiModel(
          idTransaksi: '',
          idUser: '',
          amount: amount.toInt(),
          description: desc,
          category: category,
          type: type,
          timestamp: DateTime.now().toIso8601String(),
        );
        await transaksiProvider.addTransaction(newTransaksi);
      } else {
        // Edit transaksi yang sudah ada (sederhana, hanya amount & desc)
        await transaksiProvider.updateTransaction(
          widget.transaction!.idTransaksi!,
          newAmount: amount,
          newDesc: desc,
        );
      }

      Navigator.of(context).pop(); // Tutup modal setelah sukses
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.transaction == null
                    ? 'Tambah Transaksi'
                    : 'Edit Transaksi',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              if (widget.transaction == null)
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Pemasukan'),
                      icon: Icon(Icons.arrow_downward),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Pengeluaran'),
                      icon: Icon(Icons.arrow_upward),
                    ),
                  ],
                  selected: {_isIncome},
                  onSelectionChanged: (newSelection) {
                    setState(() => _isIncome = newSelection.first);
                  },
                ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  prefixText: 'Rp ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator:
                    (value) =>
                        (value == null ||
                                value.isEmpty ||
                                double.tryParse(value) == null ||
                                double.parse(value) <= 0)
                            ? 'Masukkan jumlah yang valid'
                            : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Deskripsi tidak boleh kosong'
                            : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: _isIncome ? 'Sumber' : 'Kategori',
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Field ini tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submitData,
                icon: const Icon(Icons.save),
                label: Text(widget.transaction == null ? 'Simpan' : 'Perbarui'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
