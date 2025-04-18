import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../data/database/database.dart';
import '../../authentication/sign_in_screen/sign_in_view.dart';
import 'user_screen_state.dart';

class UserScreenCubit extends Cubit<UserScreenState> {
  UserScreenCubit() : super(const UserScreenState(username: '', email: ''));

  Future<void> getUser() async {
    await Database().getUser();
    emit(state.copyWith(username: Database().username, email: Database().email));
  }

  Future<void> logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen.newInstance()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
        // print('Lỗi khi đăng xuất: $e');
      }
    }
  }

  void updateUsername(String newName) async {
    if (newName.isNotEmpty) {
      final userId = await Database().getCurrentUserID();
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(userId)
            .update({'customerName': newName});

        emit(state.copyWith(username: newName));
      }
    }
  }
}