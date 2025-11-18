import 'package:flutter/foundation.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _phone = '';

  String get name => _name;
  String get email => _email;
  String get phone => _phone;

  bool get isEmpty => _name.isEmpty && _email.isEmpty && _phone.isEmpty;

  void setProfile({
    required String name,
    required String email,
    String phone = '',
  }) {
    _name = name;
    _email = email;
    _phone = phone;
    notifyListeners();
  }

  void update({String? name, String? email, String? phone}) {
    var changed = false;
    if (name != null && name != _name) {
      _name = name;
      changed = true;
    }
    if (email != null && email != _email) {
      _email = email;
      changed = true;
    }
    if (phone != null && phone != _phone) {
      _phone = phone;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void clear() {
    _name = '';
    _email = '';
    _phone = '';
    notifyListeners();
  }
}
