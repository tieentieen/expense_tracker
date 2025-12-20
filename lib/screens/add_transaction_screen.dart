import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  final bool isEditing;
  
  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.isEditing = false,
  });
  
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedType = 'expense';
  Category _selectedCategory = CategoryRepository.getDefaultExpenseCategory();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  @override
  void initState() {
    super.initState();
    
    if (widget.isEditing && widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _noteController.text = widget.transaction!.note ?? '';
      _selectedType = widget.transaction!.type;
      _selectedCategory = CategoryRepository.getCategoryById(widget.transaction!.categoryId);
      _selectedDate = widget.transaction!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.transaction!.date);
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.currentUserId ?? widget.transaction?.userId ?? 0;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch'),
        backgroundColor: _selectedType == 'income' 
            ? AppColors.incomeColor 
            : AppColors.expenseColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteDialog(
                transactionProvider,
                userId,
              ),
              tooltip: 'Xóa giao dịch',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Type selector
              _buildTypeSelector(),
              const SizedBox(height: 20),
              
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề',
                  hintText: 'Ví dụ: Mua sắm Tết, Lương tháng...',
                  prefixIcon: const Icon(Icons.title_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                validator: Validators.validateTitle,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  hintText: '0',
                  prefixIcon: const Icon(Icons.attach_money_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                keyboardType: TextInputType.number,
                validator: Validators.validateAmount,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Category selector
              _buildCategorySelector(),
              const SizedBox(height: 16),
              
              // Date and Time pickers
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePicker(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Note field
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Ghi chú (tuỳ chọn)',
                  hintText: 'Thêm ghi chú cho giao dịch...',
                  prefixIcon: const Icon(Icons.note_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: Validators.validateNote,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 30),
              
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _saveTransaction(
                    transactionProvider,
                    userId,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType == 'income'
                        ? AppColors.incomeColor
                        : AppColors.expenseColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    widget.isEditing ? 'CẬP NHẬT' : 'LƯU GIAO DỊCH',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Quick amount buttons (optional)
              if (!widget.isEditing) _buildQuickAmountButtons(),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildTypeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_downward, color: AppColors.expenseColor),
                    SizedBox(width: 8),
                    Text('CHI TIÊU'),
                  ],
                ),
                selected: _selectedType == 'expense',
                selectedColor: AppColors.expenseColor,
                onSelected: (_) {
                  setState(() {
                    _selectedType = 'expense';
                    _selectedCategory = CategoryRepository.getDefaultExpenseCategory();
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_upward, color: AppColors.incomeColor),
                    SizedBox(width: 8),
                    Text('THU NHẬP'),
                  ],
                ),
                selected: _selectedType == 'income',
                selectedColor: AppColors.incomeColor,
                onSelected: (_) {
                  setState(() {
                    _selectedType = 'income';
                    _selectedCategory = CategoryRepository.getDefaultIncomeCategory();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategorySelector() {
    final categories = _selectedType == 'income'
        ? CategoryRepository.getIncomeCategories()
        : CategoryRepository.getExpenseCategories();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh mục',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            return ChoiceChip(
              avatar: Text(category.icon),
              label: Text(category.name),
              selected: _selectedCategory.id == category.id,
              selectedColor: Color(category.color),
              backgroundColor: Color(category.color),
              onSelected: (_) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              labelStyle: TextStyle(
                color: _selectedCategory.id == category.id
                    ? Colors.white
                    : Colors.black,
                fontWeight: _selectedCategory.id == category.id
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngày',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            
            if (pickedDate != null) {
              setState(() {
                _selectedDate = pickedDate;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  Formatters.formatDate(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giờ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );
            
            if (pickedTime != null) {
              setState(() {
                _selectedTime = pickedTime;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickAmountButtons() {
    final quickAmounts = [10000, 20000, 50000, 100000, 200000, 500000];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn nhanh số tiền:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickAmounts.map((amount) {
            return ActionChip(
              label: Text(
                Formatters.formatCurrency(amount.toDouble()),
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () {
                setState(() {
                  _amountController.text = amount.toString();
                });
              },
              backgroundColor: AppColors.primaryLight,
            );
          }).toList(),
        ),
      ],
    );
  }

    void _saveTransaction(
    TransactionProvider provider,
    int userId,
  ) {
    if (_formKey.currentState!.validate()) {
      // Combine date and time
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      final transaction = Transaction(
        id: widget.isEditing ? widget.transaction!.id : null,
        userId: userId,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        date: combinedDateTime,
        categoryId: _selectedCategory.id,
        type: _selectedType,
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
      );
      
      if (widget.isEditing) {
        provider.updateTransaction(transaction).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật giao dịch thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }).catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        });
      } else {
        provider.addTransaction(transaction).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm giao dịch thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }).catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        });
      }
    }
  }
  
  void _showDeleteDialog(
    TransactionProvider provider,
    int userId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteTransaction(
                widget.transaction!.id!,
                userId,
              ).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Xóa giao dịch thành công!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'XÓA',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}