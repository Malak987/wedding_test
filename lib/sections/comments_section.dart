import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../services/comments_service.dart';
import '../dashboard/links.dart';
import '../widgets/section_title.dart';
import '../animations/fade_in.dart';

/// ============================================================
/// GUEST COMMENTS
/// ============================================================
/// A simple form where guests leave a name + a message for the
/// couple. Submissions are saved to Firestore (collection
/// `comments`) and are NOT shown back on the page — the couple
/// reviews them privately from the Firebase Console.
///
/// UI: same light-emerald backdrop (`accentColor`) as the Gallery
/// and Memories sections, with a clean white "letter" card: gold
/// top strip, deep-emerald field icons, and a deep-emerald send
/// button — the green stays clearly visible in the iconography.
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

  void _writeAnother() => setState(() => _state = _SubmitState.idle);

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    required Color emerald,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: emerald.withOpacity(0.75), fontSize: 14),
      prefixIcon: Icon(icon, color: emerald.withOpacity(0.85), size: 20),
      filled: true,
      fillColor: const Color(0xFFF6F4EE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: border(emerald.withOpacity(0.18)),
      focusedBorder: border(emerald, 1.6),
      errorBorder: border(Colors.redAccent.withOpacity(0.5)),
      focusedErrorBorder: border(Colors.redAccent, 1.6),
    );
  }

  ButtonStyle _sendButtonStyle(Color emerald) {
    return ElevatedButton.styleFrom(
      backgroundColor: emerald,
      disabledBackgroundColor: emerald.withOpacity(0.65),
      elevation: 8,
      shadowColor: emerald.withOpacity(0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final isAr = manager.selectedLanguage == 'ar';

    // Palette — derived from the dashboard colors, so everything here
    // still follows whatever is configured in the Admin Dashboard.
    final emerald = manager.secondaryColor; // deep emerald — visible accents
    final gold = manager.primaryColor; // antique gold — letter strip

    return Container(
      // Same light-green background as Gallery + Memories sections
      color: manager.accentColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              SectionTitle(
                title: isAr ? 'اكتبلنا كلمة' : 'Leave Us a Note',
                subtitle: isAr
                    ? 'شاركونا تهنئتكم وكلماتكم الحلوة في يومنا السعيد'
                    : 'Share your wishes and words for our special day',
              ),
              const SizedBox(height: 40),
              FadeIn(
                child: _buildLetterCard(
                  context,
                  isAr: isAr,
                  emerald: emerald,
                  gold: gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The white "letter" card holding the form (or the success state).
  Widget _buildLetterCard(
      BuildContext context, {
        required bool isAr,
        required Color emerald,
        required Color gold,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: emerald.withOpacity(0.14),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Antique-gold strip along the top of the "letter"
            Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gold.withOpacity(0.3), gold, gold.withOpacity(0.3)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
              child: _state == _SubmitState.success
                  ? _SuccessMessage(
                isAr: isAr,
                emerald: emerald,
                gold: gold,
                onWriteAnother: _writeAnother,
              )
                  : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _fieldDecoration(
                        label: isAr ? 'اسمك' : 'Your name',
                        icon: Icons.person_outline_rounded,
                        emerald: emerald,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? (isAr ? 'من فضلك اكتب اسمك' : 'Please enter your name')
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: _fieldDecoration(
                        label: isAr ? 'رسالتك' : 'Your message',
                        icon: Icons.chat_bubble_outline_rounded,
                        emerald: emerald,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? (isAr ? 'من فضلك اكتب رسالتك' : 'Please enter a message')
                          : null,
                    ),
                    const SizedBox(height: 20),
                    if (_state == _SubmitState.error)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 17),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isAr
                                    ? 'حصل خطأ، حاول تاني بعد شوية.'
                                    : 'Something went wrong, please try again.',
                                style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: _state == _SubmitState.sending
                          ? ElevatedButton(
                        onPressed: null,
                        style: _sendButtonStyle(emerald),
                        child: const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        ),
                      )
                          : ElevatedButton.icon(
                        onPressed: _submit,
                        style: _sendButtonStyle(emerald),
                        icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                        label: Text(
                          isAr ? 'ابعت تهنئتك' : 'Send your wishes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 14, color: Colors.black38),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isAr
                                ? 'رسالتك بتوصل للعروسين بس، مش بتتعرض على الموقع'
                                : 'Your note reaches the couple only — it is not shown on the site',
                            style: const TextStyle(color: Colors.black45, fontSize: 11.5, height: 1.4),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  final bool isAr;
  final Color emerald;
  final Color gold;
  final VoidCallback onWriteAnother;

  const _SuccessMessage({
    required this.isAr,
    required this.emerald,
    required this.gold,
    required this.onWriteAnother,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Deep-emerald heart in a gold-ringed circle — the section's
        // signature "شكراً" emblem
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: emerald.withOpacity(0.08),
            border: Border.all(color: gold.withOpacity(0.65), width: 1.4),
          ),
          child: Icon(Icons.favorite_rounded, color: emerald, size: 34),
        ),
        const SizedBox(height: 18),
        Text(
          isAr ? 'شكراً لكلماتك الحلوة ❤️' : 'Thank you for your kind words ❤️',
          style: TextStyle(fontWeight: FontWeight.bold, color: emerald, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isAr
              ? 'وصلتنا رسالتك، وبجد فرحتنا جداً'
              : 'We received your note and it truly made our day',
          style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        TextButton.icon(
          onPressed: onWriteAnother,
          icon: Icon(Icons.edit_note_rounded, color: emerald, size: 19),
          label: Text(
            isAr ? 'اكتب رسالة تانية' : 'Write another note',
            style: TextStyle(color: emerald, fontWeight: FontWeight.w600),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: emerald.withOpacity(0.35)),
            ),
          ),
        ),
      ],
    );
  }
}
