part of '../home_page_passageiro.dart';

class DialogValuesInfoTrip extends StatelessWidget {
  final Requisicao request;
  const DialogValuesInfoTrip({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.sizeOf(context).width * 0.80,
            height: MediaQuery.of(context).size.height * 0.50,
            decoration: BoxDecoration(
                color: Colors.white.withAlpha(220),
                borderRadius: BorderRadius.circular(32)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 14,
              children: [
                Center(
                    child: Text(
                  'Viagem Finalizada',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                )),
                 Text(
                  'Aguarde o Motorista Consfirmar o Pagamento',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  textAlign: TextAlign.center,
                ),
                 Text(
                  'Valor da viagem:',style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    )
                ),
                Text('R\$ ${request.valorCorrida}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
                 Text("Pagamento em:",style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    )),
                Text(
                  "${request.paymentType.type} ",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                )
              ],
            )),
      ),
    );
  }
}


