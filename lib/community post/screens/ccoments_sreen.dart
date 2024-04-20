import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsathihackathon/community%20post/controller/add_Cpost_controller.dart';
import 'package:tripsathihackathon/community%20post/widgets/ccomments_card.dart';
import 'package:tripsathihackathon/community/constants/error.dart';
import 'package:tripsathihackathon/community/constants/loader.dart';
import 'package:tripsathihackathon/models/cpost_model.dart';

class CCommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CCommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CCommentsScreen> {
  final commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _initialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser!;

    return Scaffold(
      appBar: AppBar(),
      body: _initialized ? _buildContent(context) : _buildLoading(),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ref.watch(getPostByIdProvider(widget.postId)).when(
          data: (data) {
            return Column(
              children: [
                TextField(
                  onSubmitted: (value) => addComment(data),
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: 'What are your thoughts',
                    filled: true,
                    border: InputBorder.none,
                  ),
                ),
                ref.watch(getPostCommentsProvider(widget.postId)).when(
                      data: (comments) {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (BuildContext context, int index) {
                              final comment = comments[index];
                              return CCommentCard(comment: comment);
                            },
                          ),
                        );
                      },
                      error: (error, stackTrace) {
                        return ErrorText(error: error.toString());
                      },
                      loading: () => const Loader(),
                    ),
              ],
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
        context: context, text: commentController.text.trim(), post: post);
    setState(() {
      commentController.text = '';
    });
  }
}
