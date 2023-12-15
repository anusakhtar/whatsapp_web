
import 'package:flutter/cupertino.dart';
import 'package:whatsapp_webapp/Model/user_model.dart';

class ProviderChat with ChangeNotifier{

  UserModel? _toUserData;
  UserModel? get toUserData => _toUserData;

  set toUserData(UserModel? userDataModel){
    _toUserData =userDataModel;
    notifyListeners();
  }

}


