import 'dart:developer';

import 'package:mobx/mobx.dart';
import 'package:uber/app/module/model/message_view.dart';
import 'package:uber_clone_core/uber_clone_core.dart';

part 'chat_controller.g.dart';

class ChatController = ChatControllerBase with _$ChatController;

abstract class ChatControllerBase with Store {
  final IaService _iaService;
  final IUserService _userSerice;
  final IAuthService _authService;
  ChatControllerBase(
      {required IaService iaService,
      required IUserService userService,
      required IAuthService authService})
      : _iaService = iaService,
        _userSerice = userService,
        _authService = authService;

  @readonly
  bool? _loading;

  @readonly
  var _messages = <MessageView>[
    MessageView(
        title: "O que você está planejando para hoje?",
        role: 'assistent',
        description: "")
  ];

  @action
  Future<void> addMessage(Messages message) async {
    
    _messages.add(MessageView(
        title: message.content, role: message.role, description: ''));
        _loading = true;
    await sendMensage(message.content);
  }

  @action
  Future<void> sendMensage(String message) async {
    try {

      
      final user = await _getUserData();
      if (user == null) {
        throw RepositoryException;
      }

      final messages = await _iaService.sendMessage(message, user);
      final m = messages.map((m) => MessageView(
        title: m.title, role: m.role, description: m.description));
     /*   await Future.delayed(const Duration(seconds: 2));
      final mv = <MessageView>[
       ..._messages,...[ MessageView(
      role: 'assistent',
      title: 'Academia FitLife - R. do Acaba Vida, 456, Itapoã',
      description: 'Aberta até 22h, tem avaliação 4.9 no Google. Plano semestral com 15% de desconto.'
      ),MessageView(
      role: 'assistant',
      title: 'Academia FitLife - R. do Acaba Vida, 456, Itapoã',
      description: 'Aberta até 22h, tem avaliação 4.9 no Google. Plano semestral com 15% de desconto.'
      )]
      ]; */

      _messages = [..._messages, ...m];

      //_messages= [...m];
    } on RepositoryException catch (e, s) {
      log("ERRO ao receber mensagem", error: e, stackTrace: s);
    } finally {
      _loading = null;
    }
  }

  Future<void> getDetailSuggestion(
      ({String title, String subject}) data) async {
    try {
       _loading = true;
      final MessagesResponseSuggestion(:description, :title, :role) =
          await _iaService.getDetailSuggestion(data);
          
     final newTitle  = title.split("-").first;
      _messages = [
        ..._messages,
        ...[MessageView(title: "Mais detalhes $newTitle", role: 'user', description: ""),
          MessageView(title: "", role: role, description: "$newTitle- $description")
        ]
      ];
    } on RepositoryException catch (e) {
      log("Erro ao receber mensagem", error: e);
    }finally {
      _loading = null;
      _loading = false;
    }
  }

   Future<void> freeChatIa(
      ({String title, String subject}) data) async {
    try {
       _loading = true;
       final user = await _getUserData();
      if (user == null) {
        throw RepositoryException;
      }
      
      final messages = await _iaService.freeChatIa(data,user);
      final t = messages.map((m) {
       final  newTitle  = m.title.split("-").first;
         return MessageView(
          title: newTitle, role: m.role, description: m.description); 
      });
        
       _messages = [..._messages,MessageView(title: data.subject, role: 'user', description:''),  ...t];

    } on RepositoryException catch (e) {
      log("ERRO ao receber mensagem", error: e);
    }
    on ServiceException catch (e) {
      log("ERRO ao receber mensagem", error: e);
    }finally {
      _loading = null;
      _loading = false;
    }
  }

  Future<Usuario?> _getUserData() async {
    try {
      final idUser = await _authService.verifyStateUserLogged();

      if (idUser == null) {
        throw RepositoryException;
      }

      return await _userSerice.getDataUserOn(idUser);
    } on RepositoryException catch (e, s) {
      log("ERRO ao receber mensagem", error: e, stackTrace: s);
      return null;
    }
  }
}
