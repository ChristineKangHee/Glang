const functions = require('firebase-functions');

exports.appleNotifications = functions.https.onRequest((req, res) => {
    console.log('Received Apple Notification:', req.body);

    const notificationType = req.body.notification_type;
    const userId = req.body.sub;

    switch (notificationType) {
        case 'EMAIL_FORWARDING_ENABLED':
            console.log(`Email forwarding enabled for user: ${userId}`);
            break;
        case 'EMAIL_FORWARDING_DISABLED':
            console.log(`Email forwarding disabled for user: ${userId}`);
            break;
        case 'ACCOUNT_DELETED':
            console.log(`Account deleted for user: ${userId}`);
            break;
        default:
            console.log('Unknown notification type:', notificationType);
    }

    res.status(200).send('Notification received');
});
