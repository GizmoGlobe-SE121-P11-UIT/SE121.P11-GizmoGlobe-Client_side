import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/product_related/category_enum.dart';
import '../../../widgets/general/gradient_text.dart';
import '../../../widgets/general/gradient_icon_button.dart';
import 'cart_screen_cubit.dart';
import 'cart_screen_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  static Widget newInstance() => BlocProvider(
      create: (context) => CartScreenCubit(),
      child: const CartScreen(),
    );

  @override
  State<CartScreen> createState() => _CartScreen();
}

class _CartScreen extends State<CartScreen> {
  CartScreenCubit get cubit => context.read<CartScreenCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GradientIconButton(
          icon: Icons.chevron_left,
          onPressed: () {
            Navigator.pop(context);
          },
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        title: const GradientText(text: 'Cart'), // 'Giỏ hàng'
      ),
      body: BlocBuilder<CartScreenCubit, CartScreenState>(
        builder: (context, state) {
          if (state.processState == ProcessState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.processState == ProcessState.failure) {
            return Center(child: Text(state.error ?? 'Error loading cart')); // 'Lỗi khi tải giỏ hàng'
          }

          if (state.items.isEmpty) {
            return const Center(child: Text('Your cart is empty')); // 'Giỏ hàng của bạn trống'
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 16, 16, 20),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    final product = item['product'] as Map<String, dynamic>;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Checkbox
                          Checkbox(
                            value: state.selectedItems.contains(item['productID']),
                            onChanged: (value) {
                              cubit.toggleItemSelection(item['productID']);
                            },
                            activeColor: Colors.blue[200],
                            checkColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          // Product Image
                          Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  _getCategoryIcon(product['category']),
                                  size: 36,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Product Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['productName'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (product['discount'] > 0) ...[
                                  Text(
                                    '\$${(product['sellingPrice'] * item['quantity']).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  '\$${(product['sellingPrice'] * (1 - (product['discount'] ?? 0)) * item['quantity']).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Quantity Controls
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Quantity Controls
                              Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[700]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove,
                                        size: 16,
                                      ),
                                      onPressed: (item['quantity'] as int? ?? 0) > 1
                                          ? () {
                                              cubit.updateQuantity(
                                                item['productID'] as String,
                                                (item['quantity'] as int? ?? 0) - 1,
                                              );
                                            }
                                          : null,
                                      padding: const EdgeInsets.all(2),
                                      constraints: const BoxConstraints(),
                                      style: IconButton.styleFrom(
                                        foregroundColor: (item['quantity'] as int? ?? 0) > 1
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                    Container(
                                      constraints: const BoxConstraints(minWidth: 16),
                                      alignment: Alignment.center,
                                      child: Text(
                                        (item['quantity'] as int? ?? 0).toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add,
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        cubit.updateQuantity(
                                          item['productID'] as String,
                                          (item['quantity'] as int? ?? 0) + 1,
                                        );
                                      },
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(),
                                      style: IconButton.styleFrom(
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Delete Button
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Theme.of(context).colorScheme.surface,
                                      title: const Text(
                                        'Remove Item', // 'Xóa sản phẩm'
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to remove this item from your cart?', // 'Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng không?'
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'), // 'Hủy'
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            cubit.removeFromCart(item['productID'] as String);
                                          },
                                          child: const Text(
                                            'Remove', // 'Xóa'
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: IconButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Bottom Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              activeColor: Colors.blue[200],
                              checkColor: Colors.black,
                              value: state.isAllSelected,
                              onChanged: (value) {
                                cubit.toggleSelectAll();
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            const Text(
                              'Select all', // 'Chọn tất cả'
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (state.hasDiscounts && state.selectedCount > 0) ...[
                              Text(
                                '\$${state.totalBeforeDiscount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              '\$${state.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (state.selectedCount == 0) {
                            return;
                          }

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Go to checkout', // 'Tiến hành thanh toán'
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    CategoryEnum categoryEnum = CategoryEnum.values.firstWhere(
      (element) => element.getName() == category,
    );
    switch (categoryEnum) {
      case CategoryEnum.ram:
        return Icons.memory;
      case CategoryEnum.cpu:
        return Icons.developer_board;
      case CategoryEnum.gpu:
        return Icons.videocam;
      case CategoryEnum.psu:
        return Icons.power;
      case CategoryEnum.drive:
        return Icons.storage;
      case CategoryEnum.mainboard:
        return Icons.dashboard;
      default:
        return Icons.devices_other;
    }
  }
}