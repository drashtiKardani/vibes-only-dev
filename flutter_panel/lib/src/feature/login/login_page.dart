import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/generated/l10n.dart';
import 'package:flutter_panel/src/cubit/login/login_cubit.dart';
import 'package:flutter_panel/src/cubit/login/login_state.dart';
import 'package:vibes_common/vibes.dart';

import '../../route/router.gr.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: _LoginForm(),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final emailFieldFocusNode = FocusNode();
  final passwordFieldFocusNode = FocusNode();

  bool passwordObscured = true;
  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    emailFieldFocusNode.addListener(textFieldFocusListener);
    passwordFieldFocusNode.addListener(textFieldFocusListener);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        if (state.isSuccess) {
          // context.replaceRoute(TwoFactorAuthenticationRoute(
          //   email: email.text,
          //   password: password.text,
          // ));
          context.replaceRoute(const DashboardRoute());
        } else if (state.isFailure) {
          String errorMsg = state.asFailure.error.asNetwork.error.message;
          emailError =
              !emailFieldFocusNode.hasFocus && errorMsg.contains('user')
                  ? errorMsg
                  : null;
          passwordError =
              !passwordFieldFocusNode.hasFocus && errorMsg.contains('password')
                  ? errorMsg
                  : null;
        }
        return SizedBox(
          height: 550,
          width: 400,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image(
                  //   image: Assets.images.vibesLogo,
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: VibesText(text: s.welcomeMessage),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 60, left: 16, right: 16),
                    child: TextField(
                      controller: email,
                      focusNode: emailFieldFocusNode,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: s.email,
                        errorText: emailError,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: TextField(
                      controller: password,
                      focusNode: passwordFieldFocusNode,
                      obscureText: passwordObscured,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: s.password,
                        errorText: passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(passwordObscured
                              ? Icons.visibility
                              : Icons.visibility_off),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onPressed: () => setState(
                              () => passwordObscured = !passwordObscured),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 56, left: 16, right: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      onPressed: () {
                        BlocProvider.of<LoginCubit>(context)
                            .login(email.text, password.text);
                      },
                      child: Text(s.signIn),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    emailFieldFocusNode.removeListener(textFieldFocusListener);
    passwordFieldFocusNode.removeListener(textFieldFocusListener);
    emailFieldFocusNode.dispose();
    passwordFieldFocusNode.dispose();
    super.dispose();
  }

  void textFieldFocusListener() {
    if (emailFieldFocusNode.hasFocus || passwordFieldFocusNode.hasFocus) {
      setState(() {});
    }
  }
}
