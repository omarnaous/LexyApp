const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Function to send notification to a specific user by user ID
exports.sendNotification = functions.https.onCall(async (data, context) => {
  const { targetUserId, title, body } = data;

  // Validate the inputs
  if (!targetUserId || !title || !body) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }

  try {
    // Get the user document from Firestore
    const userDoc = await admin.firestore().collection('users').doc(targetUserId).get();
    const fcmToken = userDoc.data().token;

    // Check if the FCM token exists
    if (!fcmToken) {
      throw new functions.https.HttpsError('not-found', 'FCM token not found');
    }

    // Send the notification
    await admin.messaging().send({
      notification: { title, body },
      token: fcmToken,
    });

    return { success: true };
  } catch (error) {
    console.error('Error:', error);
    throw new functions.https.HttpsError('unknown', 'Error sending notification');
  }
});

// Function to send notification to all users via topic
exports.sendNotificationToAllUsers = functions.https.onCall(async (data, context) => {
  const { title, body, topic } = data;

  // Validate the inputs
  if (!title || !body || !topic) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }

  try {
    // Send notification to the specified topic
    const message = {
      notification: {
        title: title,
        body: body,
      },
      topic: topic,
    };

    // Send the message
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);

    return { success: true };
  } catch (error) {
    console.error('Error sending message:', error);
    throw new functions.https.HttpsError('unknown', 'Error sending notification');
  }
});
