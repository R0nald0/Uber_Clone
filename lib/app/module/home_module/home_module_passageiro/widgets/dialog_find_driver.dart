

 part of '../home_page_passageiro.dart';
 typedef OnPressed = void Function()?;   
class DialogFindDriver extends StatelessWidget {
  final  OnPressed onPressed; 



  const DialogFindDriver({super.key,required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return  Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          width: MediaQuery.sizeOf(context).width * 0.80,
          height: MediaQuery.of(context).size.height * 0.36,
          decoration: BoxDecoration(
              color: Colors.white.withAlpha(220),
              borderRadius: BorderRadius.circular(32)),
          child: Column(
            children: [
              Text('Buscando Motorista',
                  style:
                      Theme.of(context).textTheme.titleMedium),
              SizedBox(
                height:
                    MediaQuery.of(context).size.height * 0.2,
                child: lottie.Lottie.asset(
                    UberCloneConstants.LOTTI_ASSET_FIND_DRIVER),
              ),
              ElevatedButton(
                onPressed: onPressed,
               style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red
               ),
               child:const Text(
                "Cancelar",
                  style: TextStyle(color: Colors.white),
               ) 
              )
            ],
          ),
        ),
      );
  }
}