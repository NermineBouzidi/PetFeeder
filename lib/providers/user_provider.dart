import 'package:flutter/material.dart';
import 'package:app/models/user_model.dart';
import 'package:app/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final _userService = UserService();

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    _user = await _userService.getCurrentUser();

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
  Future<void> updateUser({
  required String firstName,
  required String lastName,
}) async {
  await _userService.updateUser(
    firstName: firstName,
    lastName: lastName,
  );
  // Refresh local user data
  _user = await _userService.getCurrentUser();
  notifyListeners();
}
}