import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/cubit/login/_2fa_cubit.dart';
import 'package:flutter_panel/src/cubit/login/_2fa_state.dart';
import 'package:flutter_panel/src/cubit/login/login_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/feature/login/resend_code_widget.dart';
import 'package:vibes_common/vibes.dart';

import '../../route/router.gr.dart';

@RoutePage()
class TwoFactorAuthenticationPage extends StatelessWidget {
  final String email;
  final String password;

  const TwoFactorAuthenticationPage(
      {super.key, required this.email, required this.password});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child:
                TwoFactorAuthenticationForm(email: email, password: password),
          ),
        ],
      ),
    );
  }
}

class TwoFactorAuthenticationForm extends StatefulWidget {
  final String email;
  final String password;

  const TwoFactorAuthenticationForm(
      {super.key, required this.email, required this.password});

  @override
  State createState() => _TwoFactorAuthenticationFormState();
}

class _TwoFactorAuthenticationFormState
    extends State<TwoFactorAuthenticationForm> {
  TextEditingController code = TextEditingController();
  final codeFieldFocusNode = FocusNode();
  String? codeError;

  final bloc = TwoFactorAuthenticationCubit(inject(), inject());

  @override
  void initState() {
    super.initState();
    codeFieldFocusNode.addListener(textFieldFocusListener);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TwoFactorAuthenticationCubit,
        TwoFactorAuthenticationState>(
      bloc: bloc,
      builder: (context, state) {
        if (state.isSuccess) {
          context.replaceRoute(const DashboardRoute());
        } else if (state.isFailure) {
          codeError = !codeFieldFocusNode.hasFocus ? "wrong code" : null;
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
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: VibesText(text: strings.twoFactorAuthentication),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 60, left: 16, right: 16),
                    child: TextField(
                      controller: code,
                      focusNode: codeFieldFocusNode,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: strings.code,
                        errorText: codeError,
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
                        bloc.send2FACode(
                            TwoFACode(email: widget.email, code: code.text));
                      },
                      child: Text(strings.sendCode),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ResendCodeWidget(
                    callback: () => BlocProvider.of<LoginCubit>(context)
                        .login(widget.email, widget.password),
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
    codeFieldFocusNode.removeListener(textFieldFocusListener);
    codeFieldFocusNode.dispose();
    super.dispose();
  }

  void textFieldFocusListener() {
    if (codeFieldFocusNode.hasFocus) {
      setState(() {});
    }
  }
}
