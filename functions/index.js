const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.todayDropDailyNotification = functions.pubsub.schedule('0 8 * * *')
  .timeZone('Europe/Bucharest')
  .onRun(async context => {
    const todayStart = new Date();
    const todayEnd = new Date();
    todayStart.setHours(0, 0, 0, 0);
    todayEnd.setHours(23, 59, 59, 999);

    const shopsRef = admin.firestore().collection('shops');
    const favoritesRef = admin.firestore().collection('favorites');
    const todayShops = await shopsRef.where('nextDrop', '>=', todayStart)
                                     .where('nextDrop', '<=', todayEnd)
                                     .get();

    const jobs = todayShops.docs.map(async (shopDoc) => {
      const shopData = shopDoc.data();
      const shopId = shopDoc.id;
      const users = await favoritesRef.where('shopId', '==', shopId).get();
      const hour = Math.floor(shopData.openTime / 100);
      const minute = shopData.openTime % 100;

      if (users.empty) {
        console.log(`No users favorite the shop ${shopData.name}`);
        return;
      }

      const userNotifications = users.docs.map(async (userDoc) => {
        const userData = userDoc.data();
        const userRef = admin.firestore().collection('users').doc(userData.userId);
        const userSnap = await userRef.get();

        if (!userSnap.exists) {
          console.log(`No data for user ${userData.userId}`);
          return;
        }

        const user = userSnap.data();

        if (user.fcmToken) {
          const message = {
            notification: {
              title: `${shopData.name} drops TODAY!`,
              body: `New items are waiting for you after ${hour}:${minute < 10 ? '0' + minute : minute}.`
            },
            token: user.fcmToken,
          };

          try {
            const response = await admin.messaging().send(message);
            console.log('Successfully sent message:', response);

            const notifications = admin.firestore().collection('notifications');
            await notifications.add({
              text: `${shopData.name} drops TODAY! Opens at ${hour}:${minute < 10 ? '0' + minute : minute}.`,
              userId: user.id,
              shopId: shopId,
              time: admin.firestore.FieldValue.serverTimestamp(),
              isSensitive: true,
              seen: false
            });

            return response;
          } catch (error) {
            console.error('Failed to send notification:', error);
            return null;
          }
        }
      });

      await Promise.all(userNotifications);
      return shopId;
    });

    await Promise.all(jobs);

    console.log('All notifications sent successfully.');
  });

exports.tomorrowNextDrop = functions.pubsub.schedule('0 18 * * *') // Runs every evening at 18:00
  .timeZone('Europe/Bucharest') // Adjust the timezone to your local timezone
  .onRun(async context => {
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const tomorrowStart = new Date();
    tomorrowStart.setDate(tomorrowStart.getDate() + 1);
    tomorrowStart.setHours(0, 0, 0, 0); // Set time to 00:00:00.000

    const tomorrowEnd = new Date(tomorrowStart);
    tomorrowEnd.setHours(23, 59, 59, 999); // Set time to 23:59:59.999

    const shopsRef = admin.firestore().collection('shops');
    const favoritesRef = admin.firestore().collection('favorites');

    const tomorrowShops = await shopsRef.where('nextDrop', '>=', tomorrowStart)
                                        .where('nextDrop', '<=', tomorrowEnd)
                                        .get();

    const jobs = tomorrowShops.docs.map(async (shopDoc) => {
      const shopData = shopDoc.data();
      const shopId = shopDoc.id;
      const users = await favoritesRef.where('shopId', '==', shopId).get();
      const hour = Math.floor(shopData.openTime / 100);
      const minute = shopData.openTime % 100;

      if (users.empty) {
        console.log(`No users favorite the shop ${shopData.name}`);
        return;
      }

      const userNotifications = users.docs.map(async (userDoc) => {
        const userData = userDoc.data();
        const userRef = admin.firestore().collection('users').doc(userData.userId);
        const userSnap = await userRef.get();

        if (!userSnap.exists) {
          console.log(`No data for user ${userData.userId}`);
          return;
        }

        const user = userSnap.data();

        if (user.fcmToken) {
          const message = {
            notification: {
              title: `New drop tomorrow!`,
              body: `${shopData.name} waits for you tomorrow after ${hour}:${minute < 10 ? '0' + minute : minute} to check out their latest items!`
            },
            token: user.fcmToken,
          };

          try {
              const response = await admin.messaging().send(message);
              console.log('Successfully sent message:', response);

              const notifications = admin.firestore().collection('notifications');
              await notifications.add({
                text: `${shopData.name} drops tomorrow!`,
                userId: user.id,
                shopId: shopId,
                time: admin.firestore.FieldValue.serverTimestamp(),
                isSensitive: true,
                seen: false
              });

              return response;
            } catch (error) {
              console.error('Failed to send notification:', error);
              return null;
            }
        }
      });

      await Promise.all(userNotifications);
      return shopId;
    });

    await Promise.all(jobs);

    console.log('All notifications sent successfully.');
  });

exports.updateDropDates = functions.pubsub.schedule('0 0 * * *')
  .timeZone('Europe/Bucharest')
  .onRun(async (context) => {
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const todayEnd = new Date();
    todayEnd.setHours(23, 59, 59, 999);

    const shopsRef = admin.firestore().collection('shops');

    const todayShops = await shopsRef.where('nextDrop', '>=', todayStart)
                                     .where('nextDrop', '<=', todayEnd)
                                     .get();

    const jobs = todayShops.docs.map(async (shopDoc) => {
      const shopId = shopDoc.id;

      return shopsRef.doc(shopId).update({
        lastDrop: new Date(),
      }).then(() => {
        console.log(`Updated shop ${shopId} with lastDrop set to today and nextDrop set to null.`);
      }).catch((error) => {
        console.error(`Failed to update shop ${shopId}:`, error);
      });
    });

    await Promise.all(jobs);

    console.log('All updates processed successfully.');
  });

exports.notifyShopOwnerOnFavorite = functions.firestore
  .document('favorites/{favoriteId}')
  .onCreate(async (snap, context) => {
    const favoriteData = snap.data();
    const shopId = favoriteData.shopId;
    const userId = favoriteData.userId;

    const shopRef = admin.firestore().collection('shops').doc(shopId);
    const shopSnap = await shopRef.get();

    if (!shopSnap.exists) {
      console.log('Shop not found!');
      return null;
    }

    const shopData = shopSnap.data();
    const ownerId = shopData.ownerId;

    const userRef = admin.firestore().collection('users').doc(userId);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      console.log('User data not found!');
      return null;
    }

    const userData = userSnap.data();
    const userName = userData.name;

    const ownerRef = admin.firestore().collection('users').doc(ownerId);
    const ownerSnap = await ownerRef.get();

    if (!ownerSnap.exists) {
      console.log('Shop owner not found!');
      return null;
    }

    const ownerData = ownerSnap.data();
    const ownerToken = ownerData.fcmToken;

    if (ownerToken) {
      const message = {
        notification: {
          title: 'New Favorite!',
          body: `${userName} just added your shop to their favorites!`
        },
        token: ownerToken
      };

      try {
        const response = await admin.messaging().send(message);
        console.log('Successfully sent message:', response);

        const notifications = admin.firestore().collection('notifications');
        await notifications.add({
          text: `New favourites add: ${userName}`,
          userId: ownerId,
          shopId: '',
          time: admin.firestore.FieldValue.serverTimestamp(),
          isSensitive: false,
          seen: false
        });

        return response;
      } catch (error) {
        console.error('Failed to send notification:', error);
        return null;
      }
    } else {
      console.log('No FCM token available for shop owner');
      return null;
    }
  });

exports.notifyShopOwnerOnRating = functions.firestore
  .document('ratings/{ratingId}')
  .onCreate(async (snap, context) => {
    const ratingData = snap.data();
    const shopId = ratingData.shopId;
    const userId = ratingData.userId;

    const shopRef = admin.firestore().collection('shops').doc(shopId);
    const shopSnap = await shopRef.get();

    if (!shopSnap.exists) {
      console.log('Shop not found!');
      return null;
    }

    const shopData = shopSnap.data();
    const ownerId = shopData.ownerId;

    const userRef = admin.firestore().collection('users').doc(userId);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      console.log('User data not found!');
      return null;
    }

    const userData = userSnap.data();
    const userName = userData.name;
    const rating = ratingData.rating;
    const ownerRef = admin.firestore().collection('users').doc(ownerId);
    const ownerSnap = await ownerRef.get();

    if (!ownerSnap.exists) {
      console.log('Shop owner not found!');
      return null;
    }

    const ownerData = ownerSnap.data();
    const ownerToken = ownerData.fcmToken;

    if (ownerToken) {
      const message = {
        notification: {
          title: 'New Rating!',
          body: `${userName} just rated your shop with ${rating} stars.`
        },
        token: ownerToken
      };

      try {
        const response = await admin.messaging().send(message);
        console.log('Successfully sent message:', response);

        const notifications = admin.firestore().collection('notifications');
        await notifications.add({
          text: `${rating} stars from ${userName}: "${review}"`,
          userId: ownerId,
          shopId: '',
          time: admin.firestore.FieldValue.serverTimestamp(),
          isSensitive: false,
          seen: false
        });

        return response;
      } catch (error) {
        console.error('Failed to send notification:', error);
        return null;
      }
    } else {
      console.log('No FCM token available for shop owner');
      return null;
    }
  });

exports.updateShopRating = functions.firestore
  .document('ratings/{ratingId}')
  .onWrite(async (change, context) => {
    const ratingData = change.after.data();
    const shopId = ratingData.shopId;

    const shopRef = admin.firestore().collection('shops').doc(shopId);
    const shopSnap = await shopRef.get();

    if (!shopSnap.exists) {
      console.log('Shop not found!');
      return null;
    }

    const ratingsRef = admin.firestore().collection('ratings');
    const ratingsQuery = ratingsRef.where('shopId', '==', shopId);
    const ratingSnapshots = await ratingsQuery.get();

    let totalRating = 0;
    let ratingCount = 0;

    ratingSnapshots.forEach(doc => {
      const ratingData = doc.data();
      totalRating += ratingData.rating;
      ratingCount++;
    });

    const averageRating = ratingCount > 0 ? totalRating / ratingCount : 0;

    return shopRef.update({ rating: averageRating,
        }).then(() => {
            console.log(`Updated shop ${shopId} rating to ${averageRating}.`);
        }).catch((error) => {
            console.error(`Failed to update shop ${shopId}:`, error);
        });;

  });
