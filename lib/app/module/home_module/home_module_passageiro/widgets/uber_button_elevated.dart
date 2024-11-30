part of '../home_page_passageiro.dart';

class UberButtonElevated extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback functionPadrao;
  final Widget textoPadrao;
  final Color corDoBotaoPadrao;

  const UberButtonElevated(
      {super.key,
      required this.formKey,
      required this.functionPadrao,
      required this.textoPadrao,
      required this.corDoBotaoPadrao});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      left: 0,
      bottom: 30,
      child: Padding(
        padding: const EdgeInsets.only(left: 60, right: 60),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: corDoBotaoPadrao,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          onPressed: () {
            final formValid = formKey.currentState?.validate() ?? false;
            if (formValid) {
              functionPadrao();
            }
          },
          child: textoPadrao,
        ),
      ),
    );
  }
}
