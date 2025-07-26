const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendOrderStatusNotification = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    try {
      const beforeData = change.before.data();
      const afterData = change.after.data();
      const orderId = context.params.orderId;

      if (beforeData.status === afterData.status) {
        console.log("No status change detected");
        return null;
      }

      console.log(`Order ${orderId} status changed: ${beforeData.status} → ${afterData.status}`);

      const userDoc = await admin.firestore().collection("users").doc(afterData.userId).get();

      if (!userDoc.exists) {
        console.error("User not found:", afterData.userId);
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        console.error("No FCM token found for user:", afterData.userId);
        return null;
      }

      const statusMessages = {
        confirmed: {
          title: "Order Confirmed! ✅",
          body: `Your order #${orderId.substring(0, 8)} (GH₵${afterData.totalAmount.toFixed(2)}) has been confirmed and is being prepared.`,
        },
        shipped: {
          title: "Order Shipped! 🚚",
          body: `Your order #${orderId.substring(0, 8)} is on its way! Track your delivery in the app.`,
        },
        delivered: {
          title: "Order Delivered! 📦",
          body: `Your order #${orderId.substring(0, 8)} has been delivered! Thank you for choosing Farmer Friends.`,
        },
        cancelled: {
          title: "Order Cancelled ❌",
          body: `Your order #${orderId.substring(0, 8)} has been cancelled. Refund will be processed within 3-5 business days.`,
        },
      };

      const notification = statusMessages[afterData.status] || {
        title: "Order Update",
        body: `Your order #${orderId.substring(0, 8)} status has been updated to ${afterData.status}`,
      };

      const message = {
        notification: notification,
        data: {
          type: "order_update",
          orderId: orderId,
          status: afterData.status,
          screen: "order_details",
        },
        token: fcmToken,
      };

      const response = await admin.messaging().send(message);
      console.log("✅ Notification sent successfully:", response);

      await admin.firestore().collection("notifications").add({
        userId: afterData.userId,
        title: notification.title,
        body: notification.body,
        type: "order_update",
        orderId: orderId,
        status: afterData.status,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        fcmResponse: response,
      });

      return response;
    } catch (error) {
      console.error("❌ Error sending notification:", error);
      return null;
    }
  });

exports.processNotificationRequest = functions.firestore
  .document("notificationRequests/{requestId}")
  .onCreate(async (snap, context) => {
    try {
      const requestData = snap.data();
      const {type} = requestData;

      console.log(`📨 Processing notification request: ${type}`);

      if (type === "bulk") {
        return await processBulkNotification(snap, requestData);
      } else if (type === "single") {
        return await processSingleNotification(snap, requestData);
      } else if (type === "new_product") {
        return await processNewProductNotification(snap, requestData);
      }

      return null;
    } catch (error) {
      console.error("❌ Error processing notification request:", error);
      await snap.ref.update({
        status: "failed",
        error: error.message,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return null;
    }
  });

async function processSingleNotification(snap, requestData) {
  const {userId, title, body, data} = requestData;

  const userDoc = await admin.firestore().collection("users").doc(userId).get();

  if (!userDoc.exists) {
    await snap.ref.update({
      status: "failed",
      error: "User not found",
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }

  const userData = userDoc.data();
  const fcmToken = userData.fcmToken;

  if (!fcmToken) {
    await snap.ref.update({
      status: "failed",
      error: "No FCM token",
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }

  const message = {
    notification: {title, body},
    data: data || {},
    token: fcmToken,
  };

  try {
    const response = await admin.messaging().send(message);

    await snap.ref.update({
      status: "sent",
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      fcmResponse: response,
    });

    console.log("✅ Single notification sent:", response);
  } catch (error) {
    await snap.ref.update({
      status: "failed",
      error: error.message,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.error("❌ Failed to send single notification:", error);
  }
}

async function processBulkNotification(snap, requestData) {
  const {title, body, data, category} = requestData;

  let usersQuery = admin.firestore().collection("users").where("fcmToken", "!=", null);

  if (category && category !== "all") {
    usersQuery = usersQuery.where("interests", "array-contains", category.toLowerCase());
  }

  const usersSnapshot = await usersQuery.get();

  if (usersSnapshot.empty) {
    await snap.ref.update({
      status: "failed",
      error: "No users found",
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }

  const tokens = [];
  usersSnapshot.forEach((doc) => {
    const userData = doc.data();
    if (userData.fcmToken) {
      tokens.push(userData.fcmToken);
    }
  });

  if (tokens.length === 0) {
    await snap.ref.update({
      status: "failed",
      error: "No valid FCM tokens",
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }

  const batchSize = 500;
  let totalSent = 0;
  let totalFailed = 0;

  for (let i = 0; i < tokens.length; i += batchSize) {
    const batchTokens = tokens.slice(i, i + batchSize);

    const message = {
      notification: {title, body},
      data: data || {},
      tokens: batchTokens,
    };

    try {
      const response = await admin.messaging().sendMulticast(message);
      totalSent += response.successCount;
      totalFailed += response.failureCount;

      console.log(`📊 Batch ${Math.floor(i / batchSize) + 1}: ${response.successCount} sent, ${response.failureCount} failed`);
    } catch (error) {
      console.error("❌ Batch sending failed:", error);
      totalFailed += batchTokens.length;
    }
  }

  await snap.ref.update({
    status: "completed",
    sentAt: admin.firestore.FieldValue.serverTimestamp(),
    totalTargeted: tokens.length,
    totalSent: totalSent,
    totalFailed: totalFailed,
  });

  console.log(`✅ Bulk notification completed: ${totalSent} sent, ${totalFailed} failed`);
}

async function processNewProductNotification(snap, requestData) {
  const {targetUserIds, title, body, data} = requestData;

  let totalSent = 0;
  let totalFailed = 0;

  for (const userId of targetUserIds) {
    try {
      const userDoc = await admin.firestore().collection("users").doc(userId).get();

      if (!userDoc.exists) {
        totalFailed++;
        continue;
      }

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        totalFailed++;
        continue;
      }

      const message = {
        notification: {title, body},
        data: data || {},
        token: fcmToken,
      };

      await admin.messaging().send(message);
      totalSent++;
    } catch (error) {
      console.error(`❌ Failed to send to user ${userId}:`, error);
      totalFailed++;
    }
  }

  await snap.ref.update({
    status: "completed",
    sentAt: admin.firestore.FieldValue.serverTimestamp(),
    totalTargeted: targetUserIds.length,
    totalSent: totalSent,
    totalFailed: totalFailed,
  });

  console.log(`✅ New product notification completed: ${totalSent} sent, ${totalFailed} failed`);
}

exports.sendWelcomeNotification = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    const userData = snap.data();
    const userId = context.params.userId;

    console.log(`👋 New user registered: ${userData.name}`);

    await new Promise((resolve) => setTimeout(resolve, 5000));

    await admin.firestore().collection("notificationRequests").add({
      type: "single",
      userId: userId,
      title: "Welcome to Farmer Friends! 🌾",
      body: `Hi ${userData.name}! Discover fresh produce and farming supplies in your area.`,
      data: {
        type: "welcome",
        screen: "home",
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      status: "pending",
    });

    console.log("📝 Welcome notification request created");
  });

exports.cleanupOldData = functions.pubsub
  .schedule("0 2 * * *")
  .timeZone("Africa/Accra")
  .onRun(async (context) => {
    console.log("🧹 Starting daily cleanup...");

    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 30);

    const oldRequestsQuery = admin.firestore()
      .collection("notificationRequests")
      .where("createdAt", "<=", cutoffDate);

    const oldRequestsSnapshot = await oldRequestsQuery.get();
    const batch = admin.firestore().batch();

    oldRequestsSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`🗑️ Deleted ${oldRequestsSnapshot.size} old notification requests`);

    return null;
  });