import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/advertiser_provider.dart';
import '../../common/custom_card.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  bool _showAddForm = false;
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Electronics';
  String _selectedModel = 'assets/models/shoe.glb';

  final _modelOptions = {
    'assets/models/shoe.glb': 'Shoe (shoe.glb)',
    'assets/models/sunglasses.glb': 'Sunglasses (sunglasses.glb)',
    'assets/models/beverage.glb': 'Beverage (beverage.glb)',
    'assets/models/watch.glb': 'Watch (watch.glb)',
    'assets/models/boombox.glb': 'Boombox (boombox.glb)',
  };

  final _categories = ['Electronics', 'Fashion', 'Beverages', 'Accessories', 'Lifestyle'];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final advertiser = context.watch<AdvertiserProvider>();
    final products = advertiser.myProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('3D Product Assets'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showAddForm ? Icons.close_rounded : Icons.add_rounded,
              color: AppColors.primary,
            ),
            onPressed: () => setState(() => _showAddForm = !_showAddForm),
          ),
        ],
      ),
      body: Column(
        children: [
          // Add Product Form (collapsible)
          if (_showAddForm) _buildAddProductForm(),

          // Product List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              itemCount: products.length,
              separatorBuilder: (_, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = products[index];
                return _buildProductTile(p);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(ProductModel p) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.view_in_ar_rounded, size: 32, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.category.toUpperCase(), style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                const SizedBox(height: 2),
                Text(p.name, style: AppTypography.headlineSmall),
                const SizedBox(height: 2),
                Text('${p.brand} • ${p.modelAssetPath.split('/').last}', style: AppTypography.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.formatCurrency(p.price), style: AppTypography.headlineSmall),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                  const SizedBox(width: 2),
                  Text('${p.rating}', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add New Product', style: AppTypography.headlineSmall),
          const SizedBox(height: 14),

          // Name
          TextField(
            controller: _nameController,
            decoration: _inputDecoration('Product Name', Icons.inventory_2_rounded),
          ),
          const SizedBox(height: 10),

          // Brand
          TextField(
            controller: _brandController,
            decoration: _inputDecoration('Brand', Icons.business_rounded),
          ),
          const SizedBox(height: 10),

          // Description
          TextField(
            controller: _descController,
            maxLines: 2,
            decoration: _inputDecoration('Description', Icons.description_rounded),
          ),
          const SizedBox(height: 10),

          // Price & Category Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Price (\$)', Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: _inputDecoration('Category', null),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: AppTypography.bodyMedium))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v ?? 'Electronics'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3D Model Picker
          DropdownButtonFormField<String>(
            initialValue: _selectedModel,
            decoration: _inputDecoration('3D Model Asset', null),
            items: _modelOptions.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: AppTypography.bodyMedium)))
                .toList(),
            onChanged: (v) => setState(() => _selectedModel = v ?? _selectedModel),
          ),
          const SizedBox(height: 16),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded, size: 18),
              label: Text('Save Product', style: AppTypography.buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name and price are required')),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product "${_nameController.text}" saved'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
                setState(() {
                  _showAddForm = false;
                  _nameController.clear();
                  _brandController.clear();
                  _descController.clear();
                  _priceController.clear();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodySmall,
      prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.textTertiary) : null,
      filled: true,
      fillColor: AppColors.surfaceSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }
}
