import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/screens/user/address_screen/address_screen_state.dart';
import 'package:gizmoglobe_client/widgets/general/app_text_style.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:gizmoglobe_client/widgets/general/invisible_gradient_button.dart';
import '../../../objects/address_related/address.dart';
import '../../../widgets/general/gradient_icon_button.dart';
import '../add_address_screen/add_address_screen_view.dart';
import '../edit_address_screen/edit_address_screen_view.dart';
import 'address_screen_cubit.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => AddressScreenCubit(),
        child: const AddressScreen(),
      );

  @override
  State<AddressScreen> createState() => _AddressScreen();
}

class _AddressScreen extends State<AddressScreen> {
  AddressScreenCubit get cubit => context.read<AddressScreenCubit>();

  @override
  void initState() {
    super.initState();
    cubit.reloadList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GradientIconButton(
          icon: Icons.chevron_left,
          onPressed: () {
            Navigator.pop(context);
          },
          fillColor: Colors.transparent,
        ),
        title: GradientText(text: S.of(context).address),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              BlocBuilder<AddressScreenCubit, AddressScreenState>(
                builder: (context, state) {
                  return state.addressList.isEmpty
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60.0),
                          child: Text(
                            S.of(context).noAddressFound,
                            style: AppTextStyle.regularText,
                          ),
                        ))
                      : Column(
                          children: state.addressList.map((address) {
                            return GestureDetector(
                              onTap: () async {
                                Address? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditAddressScreen.newInstance(
                                              address)),
                                );

                                if (result != null) {
                                  cubit.editAddress(result);
                                }
                              },
                              child: ListTile(
                                title: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        address.firstLine(),
                                        style: AppTextStyle.boldText,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        address.secondLine(isEnglish: false),
                                        style: AppTextStyle.regularText,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                },
              ),
              InvisibleGradientButton(
                text: S.of(context).addAddress,
                prefixIcon: Icons.add,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddAddressScreen.newInstance()),
                  );

                  if (result != null && result is Address) {
                    cubit.addAddress(result);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}