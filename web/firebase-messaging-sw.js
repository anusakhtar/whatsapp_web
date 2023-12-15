importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js');


  const firebaseConfig = {
       apiKey: "AIzaSyAqY2rQNSTGZyOlPkHlr4dVS_0bXYhIPeI",
                authDomain: "whatsappwebapp-35e75.firebaseapp.com",
                projectId: "whatsappwebapp-35e75",
                storageBucket: "whatsappwebapp-35e75.appspot.com",
                messagingSenderId: "866651944362",
                appId: "1:866651944362:web:966908d98f1db4febbe7d3"
    };
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging(

  );


  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });