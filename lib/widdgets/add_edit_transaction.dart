import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/providers/waallet_providers.dart';

class AddEditTransactionSheet extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionSheet({super.key, this.transaction});

  @override
  _AddEditTransactionSheetState createState() => _AddEditTransactionSheetState();
}

class _AddEditTransactionSheetState extends State<AddEditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isIncome = true;
  late TextEditingController _amountController;
  late TextEditingController _descController;
  late TextEditingController _sourceOrCategoryController;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _isIncome = t == null || t is IncomeTransaction;

    _amountController = TextEditingController(text: t?.amount.toString() ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _sourceOrCategoryController = TextEditingController(
        text: t != null
            ? (_isIncome
                ? (t as IncomeTransaction).source
                : (t as ExpenseTransaction).category)
            : '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _sourceOrCategoryController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    final wallet = Provider.of<WalletProvider>(context, listen: false);
    final amount = double.tryParse(_amountController.text) ?? 0;
    final desc = _descController.text;
    final sourceOrCategory = _sourceOrCategoryController.text;

    try {
      if (widget.transaction == null) {
        // Mode Tambah
        final newTransaction = _isIncome
            ? IncomeTransaction(0, amount, desc, DateTime.now(), sourceOrCategory)
            : ExpenseTransaction(0, amount, desc, DateTime.now(), sourceOrCategory);
        wallet.addTransaction(newTransaction);
      } else {
        // Mode Edit
        wallet.updateTransaction(widget.transaction!.id, amount, desc);
        // (Untuk simplisitas, source/category tidak diubah di sini, tapi bisa ditambahkan)
      }
      Navigator.of(context).pop(); // Tutup modal setelah berhasil
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
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
                widget.transaction == null ? 'Tambah Transaksi' : 'Edit Transaksi',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Tombol switch Pemasukan/Pengeluaran (hanya di mode tambah)
              if (widget.transaction == null)
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Pemasukan'), icon: Icon(Icons.arrow_downward)),
                    ButtonSegment(value: false, label: Text('Pengeluaran'), icon: Icon(Icons.arrow_upward)),
                  ],
                  selected: {_isIncome},
                  onSelectionChanged: (newSelection) {
                    setState(() => _isIncome = newSelection.first);
                  },
                ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Jumlah', prefixText: 'Rp '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null || value.isEmpty || double.tryParse(value) == null || double.parse(value) <= 0)
                    ? 'Masukkan jumlah yang valid'
                    : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (value) => (value == null || value.isEmpty) ? 'Deskripsi tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _sourceOrCategoryController,
                decoration: InputDecoration(labelText: _isIncome ? 'Sumber' : 'Kategori'),
                 validator: (value) => (value == null || value.isEmpty) ? 'Field ini tidak boleh kosong' : null,
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