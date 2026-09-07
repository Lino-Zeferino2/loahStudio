importScripts('https://www.gstatic.com/firebasejs/11.6.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.6.0/firebase-messaging-compat.js');

// Os mesmos valores do teu firebase_options.dart (secção 'web').
firebase.initializeApp({
  apiKey: 'AIzaSyBHEPe0xt7Tx5fHJR4jjYm2U-yDiKpW_nk',
  authDomain: 'myloahstudio.firebaseapp.com',
  projectId: 'myloahstudio',
  storageBucket: 'myloahstudio.firebasestorage.app',
  messagingSenderId: '626704167393',
  appId: '1:626704167393:web:999437f30da14d7d79e2a0',
});

const messaging = firebase.messaging();

// Notificações recebidas com o browser em background/aba fechada.
messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification || {};
  self.registration.showNotification(title || 'Loah Stúdio', {
    body: body || '',
    icon: '/icons/Icon-192.png', // usa o que já tiveres em web/icons/
    data: payload.data,
  });
});

// Clique na notificação nativa do browser -> abre/foca a app.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(clients.openWindow('/'));
});