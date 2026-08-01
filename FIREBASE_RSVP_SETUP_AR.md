# توصيل RSVP مع Firebase Firestore و Firebase Hosting

## 1) تجهيز Firebase داخل المشروع

المشروع متوصل بالفعل بمشروع Firebase باسم:

```txt
weddingtest-2000
```

والملف الموجود هنا يحتوي إعدادات الويب والموبايل:

```txt
lib/firebase_options.dart
```

لو غيرت مشروع Firebase أو عملت مشروع جديد، شغّل من جذر المشروع:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

ثم اختر مشروع Firebase والمنصات المطلوبة، وسيتم تحديث `lib/firebase_options.dart` تلقائياً.

---

## 2) تثبيت الحزم

بعد إضافة RSVP و FCM شغّل:

```bash
flutter pub get
```

الحزم المهمة:

```yaml
firebase_core
cloud_firestore
firebase_messaging
```

---

## 3) Firestore Database

من Firebase Console:

1. افتح Firebase Console.
2. اختر مشروعك.
3. ادخل إلى Firestore Database.
4. اضغط Create database.
5. اختر Production mode.
6. اختر أقرب Region.
7. بعد الإنشاء انشر قواعد الحماية من الملف `firestore.rules`.

الأوامر:

```bash
firebase login
firebase use weddingtest-2000
firebase deploy --only firestore:rules
```

---

## 4) Collection المستخدمة

ميزة RSVP تستخدم Collection واحدة فقط:

```txt
guestResponses
```

كل ضيف يتم حفظه في Document ثابت مبني من:

```txt
eventId + guestId
```

يعني لو الضيف رد مرة أخرى سيتم تحديث نفس الـ Document، وليس إنشاء Document جديد.

مثال document:

```json
{
  "eventId": "event_001",
  "guestId": "guest_120",
  "guestName": "Ahmed",
  "attendanceStatus": "attending",
  "guestCount": 2,
  "message": "Congratulations ❤️",
  "language": "ar",
  "deviceId": "device_xxxxx",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

---

## 5) روابط الضيوف الشخصية

لضمان "رد واحد لكل ضيف" بشكل دقيق، أرسل لكل ضيف رابطاً يحتوي `guestId` و `guestName`:

```txt
https://weddingtest-2000.web.app/?guestId=guest_120&guestName=Ahmed
```

لو لم يتم إرسال `guestId`، سيقوم الموقع بإنشاء رقم ضيف تلقائي داخل المتصفح، وهذا يضمن رد واحد لكل جهاز/متصفح، وليس لكل ضيف حقيقي.

---

## 6) تعديل بيانات الحدث

من الملف:

```txt
lib/dashboard/links.dart
```

يمكن تعديل:

```dart
static const String eventId = 'event_001';
static const String weddingWebsiteUrl = 'https://weddingtest-2000.web.app/';
```

تاريخ ووقت ومكان الفرح يتم قراءتهم من:

```txt
lib/services/config_manager.dart
```

خصوصاً:

```dart
_eventDate
_countdownTarget
_venueName
_venueAddress
```

---

## 7) Add To Calendar

بعد نجاح RSVP يظهر زر Add To Calendar:

- Android/Desktop: يفتح Google Calendar ببيانات الحدث جاهزة.
- iPhone/iPad: ينزّل ملف `wedding_ceremony.ics`.

الحدث يحتوي:

- Title: Wedding Ceremony
- Description: Join us to celebrate our special day.
- Website: https://weddingtest-2000.web.app/
- Location: من إعدادات الموقع
- Start: من تاريخ الحدث
- End: بعد 4 ساعات
- Reminders: صباح يوم الفرح + قبل الحدث بساعة

---

## 8) Firebase Cloud Messaging للإشعارات

تم إضافة كارت بعد نجاح RSVP:

```txt
Stay Updated
Receive a reminder before the wedding.
Enable Notifications
```

عند الضغط يتم طلب إذن الإشعارات ثم حفظ FCM token داخل نفس Document في `guestResponses`.

لتفعيل Web Push Key:

1. Firebase Console.
2. Project settings.
3. Cloud Messaging.
4. Web Push certificates.
5. Generate key pair.
6. انسخ Public key.
7. ضعه هنا:

```dart
// lib/dashboard/links.dart
static const String fcmWebVapidKey = 'PASTE_PUBLIC_VAPID_KEY_HERE';
```

> ملاحظة مهمة: بدون Backend أو Cloud Functions، لا يمكن للعميل وحده إرسال إشعارات FCM مجدولة في المستقبل. الكود الحالي يحفظ token وجدول التذكيرات داخل Firestore في نفس document، ويمكن لاحقاً استخدام Firebase Notifications Composer أو Dashboard/مرسل خارجي لإرسالها. RSVP نفسه يعمل بدون أي Backend.

---

## 9) النشر على Firebase Hosting

```bash
flutter build web --release
firebase deploy --only hosting
```

ولو تريد نشر القواعد والاستضافة معاً:

```bash
firebase deploy --only firestore:rules,hosting
```
