import 'package:flutter/material.dart';
import 'package:uber_clone_core/uber_clone_core.dart';

typedef OnConfirmationTrip = void Function()?;

class UberListTrip extends StatelessWidget {
  final List<Trip> tripOptions;
  final List<PaymentType> paymentsType;
  final ValueChanged<Trip> onSelected;
  final ValueChanged<int> onSelectedPayment;
  final OnConfirmationTrip onConfirmationTrip;
 
  final itemSelected = ValueNotifier<int>(2);  
  final Trip? tripSelected;

   UberListTrip(
      {super.key,
      required this.tripOptions,
      required this.onSelected,
      required this.tripSelected,
      required this.onSelectedPayment,
      required this.paymentsType,
      required this.onConfirmationTrip});

  @override
  Widget build(BuildContext context) {
    

    final size =MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.7,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Divider(
                  color: Colors.grey,
                  indent: 150,
                  endIndent: 150,
                  thickness: 4,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Escolha o tipo da viagem',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: tripOptions.length,
                  itemBuilder: (context, index) {
                    final trip = tripOptions[index];
                    final timeAndDistanceRide= '${trip.timeTripe} - ${trip.distance} de distância';
                     final itemTypeRide = switch(trip.type){
                         'UberX'=> '${UberCloneConstants.ASSEESTS_IMAGE}/uber_car.jpg',
                         'Uber Moto ' =>'${UberCloneConstants.ASSEESTS_IMAGE}/uber_moto.png',
                         _=>''
                      };
                    
                    return ItemRideChosed(
                      isSelected: tripSelected == trip ,
                      imageTypeRide: itemTypeRide,
                      titleTypeRide: trip.type,
                      qunatityTypeRide: '${trip.quatitePersons ?? ''} ',
                      iconPeopleRider:trip.quatitePersons != null ? Icons.person : null,
                      priceRide: 'R\$${trip.price}',
                      timeAndDistanceRide: timeAndDistanceRide,
                      tripSelcted: () => onSelected(trip),
                    );
                  },
                )),
                const Align(alignment: Alignment.centerLeft ,child: Text("Forma de pagamento")),
                 DropdownMenu(
                    leadingIcon: ValueListenableBuilder(
                    valueListenable: itemSelected,
                     builder:(_, value, __) {
                       return switch(value){
                             1 => const Icon(Icons.pix),
                             2 => const Icon(Icons.money),
                             3 => const Icon(Icons.currency_bitcoin_outlined),
                             4 => const Icon(Icons.credit_card_outlined),
                             _=> const  Icon(Icons.money)
                          };
                     } ,
                    
                   ),
                   enableFilter: false,
                   enableSearch: false,
                   inputDecorationTheme: InputDecorationTheme(
                    border:OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                   ),
                   initialSelection: 2,
                   hintText: "Escolha o tipo de pagamento",
                   expandedInsets: const EdgeInsets.symmetric(vertical: 15,horizontal:10),
                   dropdownMenuEntries:paymentsType.map(
                      (p) => DropdownMenuEntry(
                        leadingIcon: switch(p.id){
                           1 => const Icon(Icons.pix),
                           2 => const Icon(Icons.money),
                           3 => const Icon(Icons.currency_bitcoin_outlined),
                           4 => const Icon(Icons.credit_card_outlined),
                           _=> const Icon(Icons.money_off)
                        }, 
                        value:  p.id, 
                        label: p.type) )
                      .toList()
                   ,
                   onSelected: (value) {
                        itemSelected.value = value ?? 2;
                        onSelectedPayment(itemSelected.value);
                   }, 
                   ),
                 const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    onPressed: onConfirmationTrip,
                    child: const Text(
                      'Confirmar Viagem',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ItemRideChosed extends StatelessWidget {
  final String imageTypeRide;
  final String titleTypeRide;
  final String? qunatityTypeRide;
  final IconData? iconPeopleRider;
  final String timeAndDistanceRide;
  final String priceRide;
  final VoidCallback tripSelcted;
  final bool isSelected;

  const ItemRideChosed(
      {required this.imageTypeRide,
      required this.titleTypeRide,
      required this.qunatityTypeRide,
      required this.iconPeopleRider,
      required this.timeAndDistanceRide,
      required this.priceRide,
      required this.tripSelcted,
      required this.isSelected,
     
      super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> selectedVN = ValueNotifier(isSelected);

    return SizedBox(
      child: ValueListenableBuilder<bool>(
          valueListenable: selectedVN,
          builder: (__, value, _) {
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              selectedTileColor:
                  value ? const Color.fromARGB(255, 63, 60, 51) : null,
              selected: value,
              onTap: () {
                selectedVN.value = !value;
                tripSelcted();
              },
              leading: Image.asset(
                imageTypeRide,
                fit: BoxFit.cover,
              ),
              title: Row(
                children: [
                  Text(titleTypeRide,
                      style: TextStyle(
                          color: value ?Colors.white : Colors.black ,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Icon(
                    iconPeopleRider,
                    color: value ?Colors.white : Colors.black,
                  ),
                  Text(
                    qunatityTypeRide ?? '',
                    style: TextStyle(color: value ?Colors.white : Colors.black),
                  ),
                ],
              ),
              subtitle: Text(timeAndDistanceRide,
                  style: TextStyle(
                    color: value ?Colors.white : Colors.black,
                    fontSize: 15,
                  )),
              trailing: Text(priceRide,
                  style: TextStyle(
                      color: value ?Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            );
          }),
    );
  }
}
