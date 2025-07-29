
import 'package:flutter/widgets.dart';
import 'package:flutter_getit/flutter_getit.dart';
import 'package:uber/app/module/chat_module/chat_controller.dart';
import 'package:uber/app/module/chat_module/chat_page.dart';

import '../home_module/home_module_passageiro/home_page_passageiro.dart';

class ChatModule extends FlutterGetItPageRouter {
  ChatModule() : super(name: "/chat_page");
  @override
  List<Bind<Object>> get bindings => [
    Bind.lazySingleton((i) => ChatController(iaService: i(), 
    userService: i(), authService: i(),
   
    ))
  ];
  @override
  WidgetBuilder? get builder => (context) {
    final option = ModalRoute.of(context)?.settings.arguments as OptionIa;
    return ChatPage(chatController: context.get<ChatController>(),choiceUser: option);
   };


}
