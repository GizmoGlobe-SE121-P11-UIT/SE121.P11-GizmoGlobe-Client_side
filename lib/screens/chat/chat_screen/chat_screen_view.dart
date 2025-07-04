import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/general/gradient_icon_button.dart';
import '../../../widgets/general/gradient_text.dart';
import '../../../objects/chat_related/chat_message.dart';
import '../../../screens/chat/chat_screen/chat_screen_cubit.dart';
import '../../../screens/chat/chat_screen/chat_screen_state.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => ChatScreenCubit(),
        child: const ChatScreen(),
      );

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final RegExp _productLinkRegex =
      RegExp(r'\[PRODUCT_LINK:([^\]]+)\]([^\[]+)\[/PRODUCT_LINK\]');
  ChatScreenCubit get cubit => context.read<ChatScreenCubit>();

  @override
  void initState() {
    super.initState();
    cubit.initialize(context);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  List<InlineSpan> _buildMessageSpans(
      String content, bool isUser, ThemeData theme) {
    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in _productLinkRegex.allMatches(content)) {
      // Thêm text trước link nếu có
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: content.substring(lastIndex, match.start),
          style: TextStyle(
            fontSize: 16,
            color: isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ));
      }

      // Thêm tên sản phẩm như text thông thường
      final productName = match.group(2)!;
      spans.add(
        TextSpan(
          text: productName,
          style: TextStyle(
            fontSize: 16,
            color: isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Thêm phần text còn lại sau link cuối cùng
    if (lastIndex < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastIndex),
        style: TextStyle(
          fontSize: 16,
          color: isUser
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
        ),
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatScreenCubit, ChatScreenState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            leading: GradientIconButton(
              icon: Icons.chevron_left,
              onPressed: () => Navigator.pop(context),
              fillColor: Colors.transparent,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientText(text: S.of(context).chatSupport),
                Text(
                  state.isAIMode
                      ? S.of(context).aiAssistant
                      : S.of(context).adminSupport,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  state.isAIMode ? Icons.support_agent : Icons.smart_toy,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () async {
                  if (state.isAIMode) {
                    await cubit
                        .switchToAdmin(S.of(context).adminWelcomeMessage);
                  } else {
                    await cubit.switchToAI(S.of(context).aiWelcomeMessage);
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    return _buildMessageBubble(message, theme);
                  },
                ),
              ),
              _buildMessageInput(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isUser = !message.isFromBot;
    final isAdmin = !message.isAIMode && message.isFromBot;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : isAdmin
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: RichText(
          text: TextSpan(
            children: _buildMessageSpans(
              message.content,
              isUser,
              theme,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: S.of(context).typeMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                context
                    .read<ChatScreenCubit>()
                    .sendMessage(_messageController.text, context);
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
