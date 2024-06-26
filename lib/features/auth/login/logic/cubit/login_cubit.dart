import 'package:flutter/material.dart';
import 'package:flutter_advanced_omar_ahmed/core/helpers/constants.dart';
import 'package:flutter_advanced_omar_ahmed/core/helpers/shared_pref_helper.dart';
import 'package:flutter_advanced_omar_ahmed/core/networking/dio_factory.dart';

import 'package:flutter_advanced_omar_ahmed/features/auth/login/data/models/login_request_body.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_advanced_omar_ahmed/features/auth/login/data/repos/login_repo.dart';

import 'package:flutter_advanced_omar_ahmed/features/auth/login/logic/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;

  LoginCubit(this._loginRepo) : super(LoginState.initial());

  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void emitLoginState(LoginRequestBody loginRequestBody) async {
    emit(const LoginState.loading());

    final response = await _loginRepo.login(loginRequestBody);

    response.when(success: (loginResponse) async {
      await saverUserToken(loginResponse.userData!.token ?? '');

      emit(LoginState.success(loginResponse));
    }, failure: (error) {
      emit(LoginState.error(error: error.apiErrorModel.message ?? ""));
    });
  }

  Future<void> saverUserToken(String token) async {
    await SharedPrefHelper.setSecuredString(SharedPrefKeys.userToken, token);
    DioFactory.setTokenIntoHeaderAfterLogin(token);
  }
}
