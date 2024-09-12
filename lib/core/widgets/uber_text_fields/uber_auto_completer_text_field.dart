import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:uber/app/model/addres.dart';
import 'package:uber/core/widgets/uber_text_fields/uber_text_field_widget.dart';

typedef OnSelectedAddres = void Function(Addres)?;
typedef GetAddresCallSuggestion = Function(String);

class UberAutoCompleterTextField extends StatefulWidget {
  final OnSelectedAddres onSelcetedAddes;
  final GetAddresCallSuggestion getAddresCallSuggestion;
  final String labalText;
  final String? hintText;
  final Icon? prefIcon;
  final FormFieldValidator<String>? validator;

  const UberAutoCompleterTextField(
      {super.key,
      required this.onSelcetedAddes,
      required this.getAddresCallSuggestion,
      required this.labalText,
      required this.prefIcon,
      this.validator,
      this.hintText});

  @override
  State<UberAutoCompleterTextField> createState() => _UberAutoCompleterTextFieldState();
}

class _UberAutoCompleterTextFieldState extends State<UberAutoCompleterTextField> {
 var  addresNameSelceted = '';
  
  @override
  void initState() {
    if (widget.hintText != null) {
        addresNameSelceted = widget.hintText ?? '';
    }
    super.initState();
  } 

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Addres>(
      itemBuilder: itemBuilder,
      onSelected: onSelected,
      suggestionsCallback: (search) async {
         await Future.delayed(const Duration(milliseconds: 00));
         return widget.getAddresCallSuggestion(search);
        },
      builder: (context, controller, focusNode) {
           controller.text = addresNameSelceted;
        return UberTextFieldWidget(
          controller: controller,
          focosNode: focusNode,
          onChange: (value )async {
             await Future.delayed(const Duration( milliseconds:700));
             addresNameSelceted =value;
          },
          prefixIcon:widget.prefIcon,
         
          label: widget.labalText,
          validator: widget.validator,
          inputType: TextInputType.streetAddress,
        );
      },
    );
  }

  void onSelected(Addres? addres) {
     if (addres != null) {
        addresNameSelceted = addres.nomeDestino;
        print('${addresNameSelceted} !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        widget.onSelcetedAddes!(addres);
     }
  }

  Widget itemBuilder(context, Addres addres) {
    return ListTile(
      leading: const Icon(Icons.location_on),
      title: Text(addres.nomeDestino),
    );
  }
}
