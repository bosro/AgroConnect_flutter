const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();

// 🔔 Function 1: Auto-send notification when order status changes
exports.sendOrderStatusNotification = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    try {
      const beforeData = change.before.data();
      const afterData = change.after.data();
      const orderId = context.params.orderId;

      // Check if status actually changed
      if (beforeData.status === afterData.status) {
        console.log('No status change detected');
        return null;
      }

      console.log(`Order ${orderId} status changed: ${beforeData.status} → ${afterData.status}`);

      // Get user's FCM token
      const userDoc = await admin.firestore().collection('users').doc(afterData.userId).get();
      
      if (!userDoc.exists) {
        console.error('User not found:', afterData.userId);
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        console.error('No FCM token found for user:', afterData.userId);
        return null;
      }

      // Create notification message
      const statusMessages = {
        confirmed: {
          title: 'Order Confirmed! ✅',
          body: `Your order #${orderId.substring(0, 8)} (GH₵${afterData.totalAmount.toFixed(2)}) has been confirmed and is being prepared.`,
        },
        shipped: {
          title: 'Order Shipped! 🚚',
          body: `Your order #${orderId.substring(0, 8)} is on its way! Track your delivery in the app.`,
        },
        delivered: {
          title: 'Order Delivered! 📦',
          body: `Your order #${orderId.substring(0, 8)} has been delivered! Thank you for choosing Farmer Friends.`,
        },
        cancelled: {
          title: 'Order Cancelled ❌',
          body: `Your order #${orderId.substring(0, 8)} has been cancelled. Refund will be processed within 3-5 business days.`,
        },
      };

      const notification = statusMessages[afterData.status] || {
        title: 'Order Update',
        body: `Your order #${orderId.substring(0, 8)} status has been updated to ${afterData.status}`,
      };

      // Send notification
      const message = {
        notification: notification,
        data: {
          type: 'order_update',
          orderId: orderId,
          status: afterData.status,
          screen: 'order_details',
        },
        token: fcmToken,
      };

      const response = await admin.messaging().send(message);
      console.log('✅ Notification sent successfully:', response);

      // Log notification to Firestore
      await admin.firestore().collection('notifications').add({
        userId: afterData.userId,
        title: notification.title,
        body: notification.body,
        type: 'order_update',
        orderId: orderId,
        status: afterData.status,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        fcmResponse: response,
      });

      return response;
    } catch (error) {
      console.error('❌ Error sending notification:', error);
      return null;
    }
  });

// 🎯 Function 2: Process notification requests (for promotional notifications)
exports.processNotificationRequest = functions.firestore
  .document('notificationRequests/{requestId}')
  .onCreate(async (snap, context) => {
    try {
      const requestData = snap.data();
      const { userId, title, body, data, type } = requestData;

      console.log(`📨 Processing notification request: ${title}`);

      // Handle different notification types
      if (type === 'bulk') {
        return await processBulkNotification(snap, requestData);
      } else if (type === 'single') {
        return await processSingleNotification(snap, requestData);
      }

    } catch (error) {
      console.error('❌ Error processing notification request:', error);
      await snap.ref.update({
        status: 'failed',
        error: error.message,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });

// Helper function for single notifications
async function processSingleNotification(snap, requestData) {
  const { userId, title, body, data } = requestData;

  // Get user's FCM token
  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  
  if (!userDoc.exists) {
    await snap.ref.update({
      status: 'failed',
      error: 'User not found',
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }

  const userData = userDoc.data();
  const fcmToken = userData.fcmToken;

  if (!fcmToken) {
    await snap.ref.update({
      status: 'failed',
      error: 'No FCM token',
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }

  // Send notification
  const message = {
    notification: { title, body },
    data: data || {},
    token: fcmToken,
  };

  const response = await admin.messaging().send(message);
  
  // Update request status
  await snap.ref.update({
    status: 'sent',
    sentAt: admin.firestore.FieldValue.serverTimestamp(),
    fcmResponse: response,
  });

  console.log('✅ Single notification sent:', response);
}

// Helper function for bulk notifications
async function processBulkNotification(snap, requestData) {
  const { title, body, data, category } = requestData;

  // Get target users
  let usersQuery = admin.firestore().collection('users').where('fcmToken', '!=', null);
  
  if (category && category !== 'all') {
    usersQuery = usersQuery.where('interests', 'array-contains', category.toLowerCase());
  }

  const usersSnapshot = await usersQuery.get();
  
  if (usersSnapshot.empty) {
    await snap.ref.update({
      status: 'failed',
      error: 'No users found',
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }

  // Prepare tokens
  const tokens = [];
  usersSnapshot.forEach(doc => {
    const userData = doc.data();
    if (userData.fcmToken) {
      tokens.push(userData.fcmToken);
    }
  });

  if (tokens.length === 0) {
    await snap.ref.update({
      status: 'failed',
      error: 'No valid FCM tokens',
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }

  // Send to batches of 500 (FCM limit)
  const batchSize = 500;
  let totalSent = 0;
  let totalFailed = 0;

  for (let i = 0; i < tokens.length; i += batchSize) {
    const batchTokens = tokens.slice(i, i + batchSize);
    
    const message = {
      notification: { title, body },
      data: data || {},
      tokens: batchTokens,
    };

    try {
      const response = await admin.messaging().sendMulticast(message);
      totalSent += response.successCount;
      totalFailed += response.failureCount;
      
      console.log(`📊 Batch ${Math.floor(i/batchSize) + 1}: ${response.successCount} sent, ${response.failureCount} failed`);
    } catch (error) {
      console.error('❌ Batch sending failed:', error);
      totalFailed += batchTokens.length;
    }
  }

  // Update request status
  await snap.ref.update({
    status: 'completed',
    sentAt: admin.firestore.FieldValue.serverTimestamp(),
    totalTargeted: tokens.length,
    totalSent: totalSent,
    totalFailed: totalFailed,
  });

  console.log(`✅ Bulk notification completed: ${totalSent} sent, ${totalFailed} failed`);
}

// 🆕 Function 3: Send welcome notification to new users
exports.sendWelcomeNotification = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const userData = snap.data();
    const userId = context.params.userId;

    console.log(`👋 New user registered: ${userData.name}`);

    // Wait for FCM token to be saved
    await new Promise(resolve => setTimeout(resolve, 5000));

    // Create welcome notification request
    await admin.firestore().collection('notificationRequests').add({
      type: 'single',
      userId: userId,
      title: 'Welcome to Farmer Friends! 🌾',
      body: `Hi ${userData.name}! Discover fresh produce and farming supplies in your area.`,
      data: {
        type: 'welcome',
        screen: 'home',
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'pending',
    });

    console.log('📝 Welcome notification request created');
  });

// 🧹 Function 4: Cleanup old data (runs daily)
exports.cleanupOldData = functions.pubsub
  .schedule('0 2 * * *') // Every day at 2 AM
  .timeZone('Africa/Accra') // Ghana timezone
  .onRun(async (context) => {
    console.log('🧹 Starting daily cleanup...');

    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 30); // 30 days ago

    // Cleanup old notification requests
    const oldRequestsQuery = admin.firestore()
      .collection('notificationRequests')
      .where('createdAt', '<=', cutoffDate);

    const oldRequestsSnapshot = await oldRequestsQuery.get();
    const batch = admin.firestore().batch();

    oldRequestsSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`🗑️ Deleted ${oldRequestsSnapshot.size} old notification requests`);

    // Cleanup old notifications
    const oldNotificationsQuery = admin.firestore()
      .collection('notifications')
      .where('sentAt', '<=', cutoffDate);

    const oldNotificationsSnapshot = await oldNotificationsQuery.get();
    const notificationBatch = admin.firestore().batch();

    oldNotificationsSnapshot.docs.forEach(doc => {
      notificationBatch.delete(doc.ref);
    });

    await notificationBatch.commit();
    console.log(`🗑️ Deleted ${oldNotificationsSnapshot.size} old notifications`);

    return null;
  });

// 📊 Function 5: Generate daily analytics
exports.generateDailyAnalytics = functions.pubsub
  .schedule('0 1 * * *') // Every day at 1 AM
  .timeZone('Africa/Accra')
  .onRun(async (context) => {
    console.log('📊 Generating daily analytics...');

    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    // Get yesterday's orders
    const ordersSnapshot = await admin.firestore()
      .collection('orders')
      .where('createdAt', '>=', yesterday)
      .where('createdAt', '<', today)
      .get();

    // Calculate metrics
    const totalOrders = ordersSnapshot.size;
    let totalRevenue = 0;
    const statusCounts = {};

    ordersSnapshot.forEach(doc => {
      const order = doc.data();
      totalRevenue += order.totalAmount;
      statusCounts[order.status] = (statusCounts[order.status] || 0) + 1;
    });

    // Get notifications sent yesterday
    const notificationsSnapshot = await admin.firestore()
      .collection('notifications')
      .where('sentAt', '>=', yesterday)
      .where('sentAt', '<', today)
      .get();

    // Save analytics
    await admin.firestore().collection('dailyAnalytics').add({
      date: admin.firestore.Timestamp.fromDate(yesterday),
      totalOrders,
      totalRevenue,
      statusCounts,
      notificationsSent: notificationsSnapshot.size,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`📈 Analytics saved: ${totalOrders} orders, GH₵${totalRevenue.toFixed(2)} revenue`);
    return null;
  });