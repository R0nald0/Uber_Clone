import 'package:flutter/material.dart';
import 'package:uber/app/module/home_module/home_module_passageiro/widgets/option_button.dart';
import '../../model/message_view.dart';

class ChatMessage extends StatelessWidget {
   final MessageView msg;
   final String content;
   final bool hideButtons ;
   final VoidCallback onPressedDetail;

  const ChatMessage({
    super.key,
    this.hideButtons =true,
    required this.msg,
    required this.content,
    required this.onPressedDetail
  });

 
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Align(
      alignment: msg.role.contains("user")
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:  size.width * 0.8 
        ),
        margin: const EdgeInsets.symmetric(
            vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg.role.contains("user")
              ? Colors.blue.shade200
              : Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text( content,
              style: TextStyle(
                  fontSize: 16,
                  color: msg.role.contains("user")
                      ? Colors.black
                      : Colors.white),
            ),
            
            Offstage(
              offstage: hideButtons,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 10,
                children: [
                  OptionButton(
                    icon:Icons.route , 
                    onTap: (){
                      Navigator.pop(context,msg.title);
                    }, 
                    label: 'ver rota',
                    ),
                  OptionButton(
                    icon:Icons.route , 
                    onTap: onPressedDetail, 
                    label: 'Mais detalhes',
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
