import 'dart:ui';

import 'package:flutter/material.dart';

import '../animations/fade_in.dart';
import '../core/constants.dart';
import '../core/responsive.dart';
import '../dashboard/links.dart';
import '../models/rsvp_response.dart';
import '../services/calendar_service.dart';
import '../services/config_manager.dart';
import '../services/rsvp_identity_service.dart';
import '../services/rsvp_notification_service.dart';
import '../services/rsvp_service.dart';
import '../widgets/animated_button.dart';
import '../widgets/section_title.dart';

class RsvpSection extends StatefulWidget {
  const RsvpSection({super.key});

  @override
  State<RsvpSection> createState() => _RsvpSectionState();
}

class _RsvpSectionState extends State<RsvpSection> {
  RsvpSaveResult? _lastResult;
  bool _notificationBusy = false;
  NotificationEnableResult? _notificationResult;

  Future<void> _openRsvpDialog() async {
    final result = await showPremiumRsvpDialog(context);
    if (!mounted || result == null) return;

    setState(() {
      _lastResult = result;
      _notificationResult = null;
    });

    await showPremiumRsvpSuccessDialog(context);
  }

  Future<void> _enableNotifications() async {
    final result = _lastResult;
    if (result == null || _notificationBusy) return;

    setState(() {
      _notificationBusy = true;
      _notificationResult = null;
    });

    final enableResult = await RsvpNotificationService.instance.enableForResponse(result);
    if (!mounted) return;

    setState(() {
      _notificationBusy = false;
      _notificationResult = enableResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final isAr = manager.selectedLanguage == 'ar';

    return Container(
      color: manager.accentColor,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.horizontalPadding(context),
        vertical: Responsive.value(
          context,
          mobile: AppConstants.sectionSpacingMobile,
          desktop: AppConstants.sectionSpacing,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
          child: Column(
            children: [
              SectionTitle(
                title: isAr ? 'تأكيد الحضور' : 'Confirm Attendance',
                subtitle: isAr
                    ? 'يسعدنا معرفة حضوركم لنجهز لكم أجمل استقبال'
                    : 'Let us know if you will join us so we can prepare beautifully.',
              ),
              const SizedBox(height: 36),
              FadeIn(
                child: _RsvpCallToActionCard(
                  isAr: isAr,
                  onPressed: _openRsvpDialog,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _lastResult == null
                    ? const SizedBox.shrink()
                    : Padding(
                  key: const ValueKey('notifications-card'),
                  padding: const EdgeInsets.only(top: 22),
                  child: _StayUpdatedCard(
                    isAr: isAr,
                    busy: _notificationBusy,
                    result: _notificationResult,
                    onEnable: _enableNotifications,
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

class _RsvpCallToActionCard extends StatelessWidget {
  final bool isAr;
  final VoidCallback onPressed;

  const _RsvpCallToActionCard({
    required this.isAr,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final emerald = manager.secondaryColor;
    final gold = manager.primaryColor;
    final isMobile = Responsive.isMobile(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 24 : 34),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.84),
                manager.accentColor.withOpacity(0.72),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: gold.withOpacity(0.46), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: emerald.withOpacity(0.16),
                blurRadius: 34,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: isMobile
              ? Column(
            children: [
              _RsvpBadge(emerald: emerald, gold: gold),
              const SizedBox(height: 18),
              _RsvpCopy(isAr: isAr),
              const SizedBox(height: 22),
              AnimatedButton(
                label: isAr ? 'تأكيد الحضور' : 'Confirm Attendance',
                icon: Icons.check_circle_outline_rounded,
                onPressed: onPressed,
              ),
            ],
          )
              : Row(
            children: [
              _RsvpBadge(emerald: emerald, gold: gold),
              const SizedBox(width: 24),
              Expanded(child: _RsvpCopy(isAr: isAr)),
              const SizedBox(width: 24),
              AnimatedButton(
                label: isAr ? 'تأكيد الحضور' : 'Confirm Attendance',
                icon: Icons.check_circle_outline_rounded,
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RsvpBadge extends StatelessWidget {
  final Color emerald;
  final Color gold;

  const _RsvpBadge({required this.emerald, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      width: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [emerald, const Color(0xFF071D16)]),
        border: Border.all(color: gold.withOpacity(0.75), width: 1.4),
        boxShadow: [
          BoxShadow(color: emerald.withOpacity(0.28), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Icon(Icons.favorite_rounded, color: gold, size: 34),
    );
  }
}

class _RsvpCopy extends StatelessWidget {
  final bool isAr;

  const _RsvpCopy({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'هل ستشاركونا فرحتنا؟' : 'Will you celebrate with us?',
          style: TextStyle(
            fontFamily: manager.headingFont,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: manager.secondaryColor,
          ),
          textAlign: isAr ? TextAlign.right : TextAlign.left,
        ),
        const SizedBox(height: 8),
        Text(
          isAr
              ? 'اضغطوا لتأكيد الحضور أو الاعتذار مع رسالة لطيفة للعروسين.'
              : 'Tap to confirm attendance or send a kind note if you cannot attend.',
          style: TextStyle(
            fontFamily: manager.bodyFont,
            height: 1.65,
            color: manager.secondaryColor.withOpacity(0.72),
            fontSize: 14.5,
          ),
        ),
      ],
    );
  }
}

class _StayUpdatedCard extends StatelessWidget {
  final bool isAr;
  final bool busy;
  final NotificationEnableResult? result;
  final VoidCallback onEnable;

  const _StayUpdatedCard({
    required this.isAr,
    required this.busy,
    required this.result,
    required this.onEnable,
  });

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final emerald = manager.secondaryColor;
    final gold = manager.primaryColor;
    final success = result?.enabled == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (success ? Colors.green : gold).withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: emerald.withOpacity(0.08),
              border: Border.all(color: gold.withOpacity(0.35)),
            ),
            child: Icon(Icons.notifications_active_outlined, color: emerald),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'ابقَ على اطلاع' : 'Stay Updated',
                  style: TextStyle(
                    fontFamily: manager.headingFont,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: emerald,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAr
                      ? 'استقبل تذكيراً قبل موعد الحفل على هذا الجهاز.'
                      : 'Receive a reminder before the wedding.',
                  style: TextStyle(
                    fontFamily: manager.bodyFont,
                    color: emerald.withOpacity(0.68),
                    height: 1.5,
                  ),
                ),
                if (result != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    result!.message,
                    style: TextStyle(
                      fontFamily: manager.bodyFont,
                      fontSize: 12.5,
                      color: success ? Colors.green.shade700 : Colors.orange.shade800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: busy || success ? null : onEnable,
            icon: busy
                ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Icon(success ? Icons.check_rounded : Icons.notifications_none_rounded, size: 18),
            label: Text(
              success
                  ? (isAr ? 'تم التفعيل' : 'Enabled')
                  : (isAr ? 'تفعيل التنبيهات' : 'Enable Notifications'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: emerald,
              foregroundColor: Colors.white,
              disabledBackgroundColor: success ? Colors.green.shade600 : emerald.withOpacity(0.45),
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

Future<RsvpSaveResult?> showPremiumRsvpDialog(BuildContext context) {
  return showGeneralDialog<RsvpSaveResult>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'RSVP',
    barrierColor: Colors.black.withOpacity(0.62),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return Opacity(
        opacity: animation.value,
        child: Transform.scale(
          scale: 0.92 + (0.08 * curved.value),
          child: const _PremiumRsvpDialog(),
        ),
      );
    },
  );
}

class _PremiumRsvpDialog extends StatefulWidget {
  const _PremiumRsvpDialog();

  @override
  State<_PremiumRsvpDialog> createState() => _PremiumRsvpDialogState();
}

class _PremiumRsvpDialogState extends State<_PremiumRsvpDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  AttendanceStatus? _status;
  int _guestCount = 1;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final identity = RsvpIdentityService.instance.resolve();
    if (identity.guestName.trim().isNotEmpty && identity.guestName != 'Guest') {
      _nameController.text = identity.guestName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;

    final manager = AppConfigManager.instance;
    final isAr = manager.selectedLanguage == 'ar';
    final cleanName = _nameController.text.trim();

    if (_status == null) {
      setState(() => _error = isAr ? 'من فضلك اختر هل ستحضر أم لا.' : 'Please select whether you will attend.');
      return;
    }

    if (cleanName.isEmpty) {
      setState(() => _error = isAr ? 'من فضلك اكتب اسمك.' : 'Please enter your name.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final identity = RsvpIdentityService.instance.resolve();
      RsvpIdentityService.instance.saveGuestName(cleanName);
      final response = RsvpResponse(
        eventId: AppLinks.eventId,
        guestId: identity.guestId,
        guestName: cleanName,
        attendanceStatus: _status!,
        guestCount: _status == AttendanceStatus.attending ? _guestCount : 0,
        message: _messageController.text,
        language: manager.selectedLanguage,
        deviceId: identity.deviceId,
      );

      final result = await RsvpService.instance.saveResponse(response);
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = isAr ? 'لم يتم حفظ الرد، حاول مرة أخرى.' : 'Could not save your response. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final isAr = manager.selectedLanguage == 'ar';
    final emerald = manager.secondaryColor;
    final gold = manager.primaryColor;
    final isMobile = Responsive.isMobile(context);

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.96), manager.accentColor.withOpacity(0.92)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: gold.withOpacity(0.55), width: 1.2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 44, offset: const Offset(0, 24)),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 22 : 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _DialogHeader(emerald: emerald, gold: gold, isAr: isAr),
                      const SizedBox(height: 24),
                      Align(
                        alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(
                          isAr ? 'هل ستحضر حفل الزفاف؟' : 'Will you attend the wedding?',
                          style: TextStyle(
                            fontFamily: manager.headingFont,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: emerald,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _AttendanceChoice(
                        selected: _status == AttendanceStatus.attending,
                        icon: Icons.check_circle_rounded,
                        label: isAr ? 'نعم، سأحضر' : "Yes, I'll attend",
                        activeColor: Colors.green.shade700,
                        onTap: () => setState(() => _status = AttendanceStatus.attending),
                      ),
                      const SizedBox(height: 10),
                      _AttendanceChoice(
                        selected: _status == AttendanceStatus.declined,
                        icon: Icons.cancel_rounded,
                        label: isAr ? 'آسف، لا أستطيع الحضور' : "Sorry, I can't attend",
                        activeColor: Colors.redAccent.shade200,
                        onTap: () => setState(() => _status = AttendanceStatus.declined),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        child: _status == null
                            ? const SizedBox.shrink()
                            : Column(
                          key: ValueKey(_status),
                          children: [
                            const SizedBox(height: 18),
                            TextField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                context,
                                icon: Icons.person_outline_rounded,
                                hint: isAr ? 'اسمك *' : 'Your name *',
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (_status == AttendanceStatus.attending) ...[
                              Align(
                                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                                child: Text(
                                  isAr ? 'كم عدد الحاضرين؟' : 'How many people will attend?',
                                  style: TextStyle(
                                    fontFamily: manager.bodyFont,
                                    color: emerald,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                value: _guestCount,
                                items: [1, 2, 3, 4, 5]
                                    .map((count) => DropdownMenuItem<int>(
                                  value: count,
                                  child: Text(
                                    count == 1
                                        ? (isAr ? '1 - أنا فقط' : '1 - Me only')
                                        : (isAr
                                        ? '$count - أنا ومعي ${count - 1}'
                                        : '$count - Me + ${count - 1}'),
                                  ),
                                ))
                                    .toList(),
                                onChanged: (value) => setState(() => _guestCount = value ?? 1),
                                decoration: _inputDecoration(
                                  context,
                                  icon: Icons.groups_2_outlined,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                                child: Text(
                                  isAr
                                      ? 'العدد يشملك أنت: 1 = أنت فقط، 2 = أنت وشخص آخر.'
                                      : 'The count includes you: 1 = you only, 2 = you plus one guest.',
                                  style: TextStyle(
                                    fontFamily: manager.bodyFont,
                                    fontSize: 12.5,
                                    height: 1.45,
                                    color: emerald.withOpacity(0.58),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            TextField(
                              controller: _messageController,
                              maxLines: 4,
                              maxLength: 500,
                              decoration: _inputDecoration(
                                context,
                                icon: Icons.mode_comment_outlined,
                                hint: _status == AttendanceStatus.attending
                                    ? (isAr
                                    ? 'اترك رسالة للعروسين... مثال: نتمنى لكم حياة سعيدة ❤️'
                                    : 'Leave a message for the couple... Example: Wishing you a lifetime of happiness ❤️')
                                    : (isAr
                                    ? 'رسالة اختيارية... مثال: آسف لا أستطيع الحضور.'
                                    : "Optional message... Example: Sorry I can't attend."),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _submit,
                          icon: _saving
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                              : const Icon(Icons.favorite_rounded),
                          label: Text(isAr ? 'إرسال الرد' : 'Submit RSVP'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: emerald,
                            disabledBackgroundColor: emerald.withOpacity(0.55),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            textStyle: TextStyle(
                              fontFamily: manager.bodyFont,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            elevation: 10,
                            shadowColor: emerald.withOpacity(0.32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
                        child: Text(isAr ? 'إغلاق' : 'Close'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {IconData? icon, String? hint}) {
    final manager = AppConfigManager.instance;
    final emerald = manager.secondaryColor;
    final gold = manager.primaryColor;

    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: emerald.withOpacity(0.42), fontSize: 13),
      prefixIcon: icon == null ? null : Icon(icon, color: emerald.withOpacity(0.72)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.72),
      enabledBorder: border(gold.withOpacity(0.28)),
      focusedBorder: border(emerald, 1.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final Color emerald;
  final Color gold;
  final bool isAr;

  const _DialogHeader({
    required this.emerald,
    required this.gold,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    return Row(
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [emerald, const Color(0xFF061815)]),
            border: Border.all(color: gold.withOpacity(0.8)),
          ),
          child: Icon(Icons.mail_outline_rounded, color: gold, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'بطاقة الرد' : 'RSVP',
                style: TextStyle(
                  fontFamily: manager.headingFont,
                  color: emerald,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isAr ? 'ردكم يسعدنا ويهمنا' : 'Your response means so much to us',
                style: TextStyle(
                  fontFamily: manager.bodyFont,
                  color: emerald.withOpacity(0.62),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendanceChoice extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final Color activeColor;
  final VoidCallback onTap;

  const _AttendanceChoice({
    required this.selected,
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final gold = manager.primaryColor;
    final emerald = manager.secondaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: selected ? activeColor.withOpacity(0.1) : Colors.white.withOpacity(0.66),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : gold.withOpacity(0.25),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: activeColor.withOpacity(0.16), blurRadius: 18, offset: const Offset(0, 8))]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? activeColor : emerald.withOpacity(0.55)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: manager.bodyFont,
                  color: selected ? emerald : emerald.withOpacity(0.72),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: selected ? 1 : 0,
              child: Icon(Icons.check_circle_rounded, color: activeColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showPremiumRsvpSuccessDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Attendance Confirmed',
    barrierColor: Colors.black.withOpacity(0.62),
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return Opacity(
        opacity: animation.value,
        child: Transform.scale(
          scale: 0.88 + (0.12 * curve.value),
          child: const _PremiumSuccessDialog(),
        ),
      );
    },
  );
}

class _PremiumSuccessDialog extends StatelessWidget {
  const _PremiumSuccessDialog();

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final isAr = manager.selectedLanguage == 'ar';
    final emerald = manager.secondaryColor;
    final gold = manager.primaryColor;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 34, 28, 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.96), manager.accentColor.withOpacity(0.92)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: gold.withOpacity(0.6)),
                boxShadow: [BoxShadow(color: emerald.withOpacity(0.28), blurRadius: 40, offset: const Offset(0, 18))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.75, end: 1),
                    duration: const Duration(milliseconds: 520),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                    child: Container(
                      height: 86,
                      width: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Colors.green.shade600, emerald]),
                        border: Border.all(color: gold, width: 2),
                        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.28), blurRadius: 24, offset: const Offset(0, 10))],
                      ),
                      child: Icon(Icons.check_rounded, color: gold, size: 44),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    isAr ? 'تم تأكيد الحضور' : 'Attendance Confirmed',
                    style: TextStyle(
                      fontFamily: manager.headingFont,
                      color: emerald,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isAr
                        ? 'شكراً لردكم. تم تسجيل الحضور بنجاح.'
                        : 'Thank you for your response. Your attendance has been recorded successfully.',
                    style: TextStyle(
                      fontFamily: manager.bodyFont,
                      color: emerald.withOpacity(0.68),
                      height: 1.6,
                      fontSize: 14.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: CalendarService.instance.addWeddingToCalendar,
                          icon: const Icon(Icons.calendar_month_rounded, size: 18),
                          label: Text(isAr ? 'إضافة للتقويم' : 'Add To Calendar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: emerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: emerald,
                            side: BorderSide(color: gold.withOpacity(0.75)),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                          ),
                          child: Text(isAr ? 'إغلاق' : 'Close'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
