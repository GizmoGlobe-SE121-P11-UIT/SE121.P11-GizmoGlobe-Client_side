import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import '../../../data/database/database.dart';
import '../../../objects/address_related/address.dart';
import '../../../widgets/general/gradient_icon_button.dart';
import 'add_address_screen_cubit.dart';
import '../../../widgets/general/address_picker.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  static Widget newInstance() => BlocProvider(
    create: (context) => AddAddressScreenCubit(),
    child: const AddAddressScreen(),
  );

  @override
  State<AddAddressScreen> createState() => _AddAddressScreen();
}

class _AddAddressScreen extends State<AddAddressScreen> {
  AddAddressScreenCubit get cubit => context.read<AddAddressScreenCubit>();

  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();

  @override
  void dispose() {
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: GradientIconButton(
            icon: Icons.chevron_left,
            onPressed: () {
              Navigator.pop(context);
            },
            fillColor: Colors.transparent,
          ),
          title: const GradientText(text: 'Add Address'), // 'Thêm địa chỉ'
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(
                  Address(
                    customerID: Database().userID,
                    receiverName: cubit.state.receiverName,
                    receiverPhone: cubit.state.receiverPhone,
                    province: cubit.state.province,
                    district: cubit.state.district,
                    ward: cubit.state.ward,
                    street: cubit.state.street,
                  ),
                );
              },
              child: const Text('OK', style: TextStyle(color: Colors.white)), // 'Xác nhận'
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                FieldWithIcon(
                  controller: _receiverNameController,
                  hintText: 'Receiver Name', // 'Tên người nhận'
                  onChanged: (value) {
                    cubit.updateAddress(receiverName: value);
                  },
                  fillColor: Theme.of(context).colorScheme.surface,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  ],
                ),
                const SizedBox(height: 8),

                FieldWithIcon(
                  controller: _receiverPhoneController,
                  hintText: 'Receiver Phone', // 'Số điện thoại người nhận'
                  onChanged: (value) {
                    cubit.updateAddress(receiverPhone: value);
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.phone,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                const SizedBox(height: 8),

                AddressPicker(
                  onAddressChanged: (province, district, ward) {
                    cubit.updateAddress(
                      province: province,
                      district: district,
                      ward: ward,
                    );
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: 8),

                FieldWithIcon(
                  controller: _streetController,
                  hintText: 'Street name, building, house no.', // 'Tên đường, tòa nhà, số nhà'
                  onChanged: (value) {
                    cubit.updateAddress(street: value);
                  },
                  fillColor: Theme.of(context).colorScheme.surface,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s,-]')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}