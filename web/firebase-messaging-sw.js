/* Firebase Cloud Messaging service worker for Flutter Web RSVP reminders.
 * This file has no backend logic; it only lets the browser receive/display
 * FCM messages after the visitor grants notification permission.
 */
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyAwUgYnwuw_YEdpUsCyTdBHpPNH8Hf8UBM',
  authDomain: 'weddingtest-2000.firebaseapp.com',
  projectId: 'weddingtest-2000',
  storageBucket: 'weddingtest-2000.firebasestorage.app',
  messagingSenderId: '72397530270',
  appId: '1:72397530270:web:f38da708a3388882fdc78f',
  measurementId: 'G-1GNHVXJRP0',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  const title = notification.title || 'Wedding Reminder';
  const options = {
    body: notification.body || 'We look forward to seeing you.',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data || {},
  };

  self.registration.showNotification(title, options);
});
