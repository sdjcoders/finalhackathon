import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:tripsathihackathon/chatbot/const.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatMessage> _messages = <ChatMessage>[];

  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: "user", lastName: "userr");

  final ChatUser _gptChatUser =
      ChatUser(id: '2', firstName: "Chat", lastName: "GPT");

  final _openAI = OpenAI.instance.build(
      token: OPEN_API_KEY,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
      enableLog: true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AISaathi"),
      ),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              kToolbarHeight -
              kBottomNavigationBarHeight,
          child: DashChat(
            currentUser: _currentUser,
            onSend: _handleSendMessage,
            messages: _messages,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendMessage(ChatMessage message) async {
    setState(() {
      _messages.insert(0, message);
    });
    List<Messages> _messageHistory = _messages.reversed
        .map((m) {
          if (m.user == _currentUser) {
            return Messages(role: Role.user, content: m.text);
          } else {
            return Messages(role: Role.assistant, content: m.text);
          }
        })
        .where((message) => message != null)
        .toList();

    final request = ChatCompleteText(
        model: GptTurbo0301ChatModel(),
        messages: _messageHistory,
        maxToken: 200);
    final resposne = await _openAI.onChatCompletion(request: request);
    for (var element in resposne!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                  user: _gptChatUser,
                  createdAt: DateTime.now(),
                  text: element.message!.content));
        });
      }
    }
    print("messages ${message.text}");
  }
}
