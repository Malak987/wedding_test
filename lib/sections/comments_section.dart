import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../services/comments_service.dart';
import '../dashboard/links.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_title.dart';
import '../animations/fade_in.dart';

/// ============================================================
/// GUEST COMMENTS
/// ============================================================
/// A simple form where guests leave a name + a message for the
/// couple. Submissions are saved to Firestore (collection
/// `comments`) and are NOT shown back on the page — the couple
/// reviews them privately from the Firebase Console.
/// ============================================================

class CommentsSection extends StatefulWidget {
  const CommentsSection({super.key});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

enum _SubmitState { idle, sending, success, error }

class _CommentsSectionState extends State<CommentsSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  _SubmitState _state = _SubmitState.idle;

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _state = _SubmitState.sending);
    try {
      await CommentsService.instance.addComment(
        name: _nameController.text,
        message: _messageController.text,
        siteId: AppLinks.siteId,
      );
      if (!mounted) return;
      setState(() => _state = _SubmitState.success);
      _nameController.clear();
      _messageController.clear();
      _formKey.currentState!.reset();
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _SubmitState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final isAr = manager.selectedLanguage == 'ar';
    final primary = manager.primaryColor;
    final secondary = manager.secondaryColor;

    return Container(
      color: manager.accentColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            children: [
              SectionTitle(
                title: isAr ? 'اكتبلنا كلمة' : 'Leave Us a Note',
                subtitle: isAr
                    ? 'شاركونا تهنئتكم وكلماتكم الحلوة في يومنا السعيد'
                    : 'Share your wishes and words for our special day',
              ),
              const SizedBox(height: 36),
              FadeIn(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: _state == _SubmitState.success
                      ? _SuccessMessage(isAr: isAr, secondary: secondary, primary: primary)
                      : Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: isAr ? 'اسمك' : 'Your name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? (isAr ? 'من فضلك اكتب اسمك' : 'Please enter your name')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: isAr ? 'رسالتك' : 'Your message',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? (isAr ? 'من فضلك اكتب رسالتك' : 'Please enter a message')
                              : null,
                        ),
                        const SizedBox(height: 20),
                        if (_state == _SubmitState.error)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              isAr
                                  ? 'حصل خطأ، حاول تاني بعد شوية.'
                                  : 'Something went wrong, please try again.',
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _state == _SubmitState.sending ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _state == _SubmitState.sending
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Text(
                              isAr ? 'ابعت' : 'Send',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  final bool isAr;
  final Color secondary;
  final Color primary;

  const _SuccessMessage({
    required this.isAr,
    required this.secondary,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.favorite, color: primary, size: 36),
        const SizedBox(height: 16),
        Text(
          isAr ? 'شكراً لكلماتك الحلوة ❤️' : 'Thank you for your kind words ❤️',
          style: TextStyle(fontWeight: FontWeight.bold, color: secondary, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}