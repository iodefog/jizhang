require('NSUserDefaults','SSJReminderItem');
defineClass('SSJLocalNotificationHelper', {}, {
    registerLocalNotificationWithremindItem: function(item) {
        if (!item.remindState()) {
            return;
        }

        if (!item.userId().length()) {
            item.setUserId(NSUserDefaults.standardUserDefaults().stringForKey("kSSJUserIdKey"));;
        }
        self.ORIGregisterLocalNotificationWithremindItem(item);
    },
});
