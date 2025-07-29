import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:uber/app/module/chat_module/chat_controller.dart';
import 'package:uber_clone_core/uber_clone_core.dart';

import '../home_module/home_module_passageiro/home_page_passageiro.dart';
import 'widgets/chat_massege.dart';

class ChatPage extends StatefulWidget {
  final ChatController chatController;
  final OptionIa choiceUser;
  const ChatPage(
      {super.key, required this.chatController, required this.choiceUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with DialogLoader {
  final reactions = <ReactionDisposer>[];
  

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ChatPage(:chatController, :choiceUser) = widget;
      initReaction(chatController);
      chatController
          .addMessage(Messages(role: 'user', content: choiceUser.nameOption));
      _scrollToBottom();
    });
  }

  Future<void> initReaction(ChatController chatController) async {


    final loadingReaction = reaction((_) => widget.chatController.loading, (loadingNow){
       log("LOADING $loadingNow");
      return switch (loadingNow) {
        true => showLoaderDialog(),
        false => hideLoader(),
        _ => hideLoader()
      };
    });

    reactions.addAll([loadingReaction]);
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 250,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    FocusScope.of(context).requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                children: [
                  Expanded(
                    child: Observer(builder: (context) {
                      final ChatController(:messages, :getDetailSuggestion) =
                          widget.chatController;
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final content = !msg.role.contains("user")
                              ? '${msg.title}\n${msg.description}'
                              : msg.title;

                          return ChatMessage(
                            msg: msg,
                            content: content,
                            hideButtons: msg.role.contains("user") ||
                                index == 0 ||
                                msg.title.isEmpty,
                            onPressedDetail: () async {
                              await getDetailSuggestion(
                                (
                                  subject: "mais detalhes sobre ${msg.title}",
                                  title: msg.title,
                                ),
                              );
                              _scrollToBottom();
                            },
                          );
                        },
                      );
                    }),
                  ),
                  const Divider(height: 1),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.grey[200],
                    child: Row(
                      children: [
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: TextField(
                              onTapOutside: (_) => FocusScope.of(context).unfocus(),
                              controller: _messageController,
                              decoration: const InputDecoration.collapsed(
                                hintText: 'Digite sua mensagem...',
                              ),
                              onSubmitted: (_) {},
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            FocusScope.of(context).requestFocus();
                            final isValid =
                                _formKey.currentState?.validate() ?? false;
                            switch (isValid) {
                              case (false):
                                {
                                  callInfoSnackBar(
                                      "Digite uma mensagem válida");
                                }
                              case true:
                                {
                                  widget.chatController.freeChatIa((
                                    title: '',
                                    subject: _messageController.text
                                  ));
                                  _messageController.text = '';
                                  _scrollToBottom();
                                }
                            }
                          },
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
       /*    Observer(
            builder: (context) {
              return Offstage(
                offstage: widget.chatController.loading == false,
                child: Container(
                  height: MediaQuery.sizeOf(context).height *1,
                  width: double.infinity,
                  color: Colors.grey.withAlpha(100),
                  child: LoadingAnimationWidget.hexagonDots(color: Colors.black, size: 40),
                ),
              );
            }
          ) */
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var react in reactions) {
      react();
    }
    super.dispose();
  }
}
