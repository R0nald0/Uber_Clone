import 'package:flutter/material.dart';
import 'package:uber_clone_core/uber_clone_core.dart';

typedef OnConfirmationTrip = void Function()?;

class UberListTrip extends StatelessWidget {
  final List<Trip> tripOptions;
  final Trip? tripSelected;
  final Function(Trip) onSelected;
  final OnConfirmationTrip onConfirmationTrip;

  const UberListTrip(
      {super.key,
      required this.tripOptions,
      required this.tripSelected,
      required this.onSelected,
      required this.onConfirmationTrip});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
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

                  return ItemRideChosed(
                    isSelected: tripSelected == trip,
                    colorText:
                        tripSelected == trip ? Colors.white : Colors.black,
                    imageTypeRide: trip.type == 'UberX'
                        ? 'images/uber_car.jpg'
                        : 'images/uber_moto.png',
                    titleTypeRide: trip.type,
                    qunatityTypeRide: '${trip.quatitePersons ?? ''} ',
                    iconPeopleRider:
                        trip.quatitePersons != null ? Icons.person : null,
                    priceRide: 'R\$${trip.price}',
                    timeAndDistanceRide:
                        '${trip.timeTripe} - ${trip.distance} de distância',
                    tripSelcted: () => onSelected(trip),
                  );
                },
              )),
              const SizedBox(
                height: 20,
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
  final Color colorText;
  final Function() tripSelcted;

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
      required this.colorText,
      super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> selected = ValueNotifier(isSelected);

    return SizedBox(
      child: ValueListenableBuilder<bool>(
          valueListenable: selected,
          builder: (context, value, _) {
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              selectedTileColor:
                  value ? const Color.fromARGB(255, 63, 60, 51) : null,
              selected: value,
              onTap: () {
                selected.value = !value;
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
                          color: colorText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Icon(
                    iconPeopleRider,
                    color: colorText,
                  ),
                  Text(
                    qunatityTypeRide ?? '',
                    style: TextStyle(color: colorText),
                  ),
                ],
              ),
              subtitle: Text(timeAndDistanceRide,
                  style: TextStyle(
                    color: colorText,
                    fontSize: 15,
                  )),
              trailing: Text(priceRide,
                  style: TextStyle(
                      color: colorText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            );
          }),
    );
  }
}
