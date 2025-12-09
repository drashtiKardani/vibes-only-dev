import 'package:flutter/material.dart';
import 'package:flutter_panel/generated/l10n.dart';

import 'colors.dart';

class CrudScaffold extends StatelessWidget {
  final List<Widget> children;
  final String title;
  final VoidCallback onResetClickHandler;
  final VoidCallback onSubmitClickHandler;
  final bool isLoading;
  final String? submitButtonLabel;
  final bool showBackButton;

  const CrudScaffold(
      {super.key,
      required this.children,
      required this.title,
      required this.onResetClickHandler,
      required this.onSubmitClickHandler,
      this.isLoading = false,
      this.submitButtonLabel,
      this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: showBackButton,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.05,
                    horizontal: MediaQuery.of(context).size.width * 0.1),
                color: cardBackgroundColor(context),
                child: Padding(
                  padding: const EdgeInsets.only(left: 32.0, right: 32, top: 20, bottom: 20),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: onResetClickHandler,
                            child: Text(S.of(context).reset),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: children,
                          )),
                      const SizedBox(
                        height: 16,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: onSubmitClickHandler,
                            child: Text(submitButtonLabel ?? S.of(context).add),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
