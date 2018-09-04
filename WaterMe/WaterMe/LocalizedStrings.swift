//
//  LocalizedStrings.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 19/12/17.
//  Copyright © 2017 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import WaterMeData

extension UIApplication {
    enum LocalizedString {
        static let appTitle =
            NSLocalizedString("WaterMe",
                              comment: "Name of the app. Shows in various places like Navigation Bars and Alerts.")
        static let editVessel =
            NSLocalizedString("Edit Plant",
                              comment: "Button Title in an Alert. Shows when the user taps on a reminder. After being selected, this will allow the user to edit the details of the plant that owns the reminder.")
        static let editReminder =
            NSLocalizedString("Edit Reminder",
                              comment: "Button Title in an Alert. Shows when the user taps on a reminder. After being selected, this will allow the user to edit the details of the reminder.")
    }
}

extension OptionalAddButtonTableViewHeaderFooterView {
    enum LocalizedString {
        static let addReminder =
            NSLocalizedString("Add Reminder",
                              comment: "Edit Plant: Button: Add Reminder: When tapped, a reminder is added to the current plant.")
        static let addReminderShort =
            NSLocalizedString("Add",
                              comment: "Edit Plant: Button: Add Reminder: Accessible: When tapped, a reminder is added to the current plant. When very large font sizes are used, this much shorter string is used.")
    }
}

extension ReminderVessel {
    enum LocalizedString {
        static let untitledPlant =
            NSLocalizedString("My Plant",
                              comment: "Name shown to the user when they have not given the plant a specific name.")
        static let photo =
            NSLocalizedString("Photo",
                              comment: "Describes the photo or emoji that is associated with an individual plant. Each plant can have only 1 photo")
        static let name =
            NSLocalizedString("Name",
                              comment: "Describes the name associated with an individual plant. The user can choose any name they like. Each plant can have only 1 name.")
        static let reminders =
            NSLocalizedString("Reminders",
                              comment: "Describes all the reminders that are associated with an individual plant. Each plant can have many reminders.")
    }
}

extension ReminderMainViewController {
    enum LocalizedString {
        static let nextPerformLabelNow =
            NSLocalizedString("Now",
                              comment: "Displayed to the user for Reminders that need to be performed now.")
        static let timeAgoLabelNever =
            NSLocalizedString("Never",
                              comment: "When a reminder has never been performed, this shows to the user rather than how long ago they last performed the reminder.")
        static let buttonTitleReminderPerform =
            NSLocalizedString("Mark Reminder as Done",
                              comment: "Button Title in an Alert. Shows when the user taps on a reminder. After being selected, this will mark the reminder as performed.")
        static let reminderAlertTitle =
            NSLocalizedString("%@ – %@",
                              comment: "ReminderMainViewController: Select Reminder Alert Title: 2 Arguments: When the user taps on a reminder, this is the title of the alert if the plant has a name. It tells the user the kind of reminder and the name of the plant. e.g. 'Water Plant - My Cool Plant'")
        static let reminderAlertMessage1Arg =
            NSLocalizedString("Due: %@",
                              comment: "ReminderMainViewController: Select Reminder Alert Message: 1 Argument: When the user taps on a reminder, this is the message of the alert when the reminder does not have a note. It tells the user the Due date of the reminder. The due date is provided by the system already localized.")
        static let reminderAlertMessage2Arg =
            NSLocalizedString("Due: %@\nNote: %@",
                              comment: "ReminderMainViewController: Select Reminder Alert Message: 2 Arguments: When the user taps on a reminder, this is the message of the alert when the reminder has a note. It tells the user the Due date of the reminder and the note. The due date is provided by the system already localized.")
    }
}

extension UIAlertController {
    enum LocalizedString {
        static let buttonTitleChoosePhoto =
            NSLocalizedString("Choose a Photo",
                              comment: "Button Title in an Alert that allows the user to open the Camera, Photo Picker, or Emoji Picker Screen.")
        static let titleNewEmojiPhotoExistingPhoto =
            NSLocalizedString("Choose a new Emoji or Photo for your plant, or view the current photo.",
                              comment: "Title of an Alert that tells the user that they can choose a new photo or emoji for their plant or they can view the current photo for their plant.")

        static let titleNewEmojiPhoto =
            NSLocalizedString("Choose a new Emoji or Photo for your plant.",
                              comment: "Title of an Alert that tells the user that they can choose a new photo or emoji for their plant.")
        static let buttonTitleEmoji =
            NSLocalizedString("Emoji",
                              comment: "Button Title in an Alert that allows the user to open a screen where they can choose from various emoji instead of a photo for their plant.")
        static let buttonTitlePhotos =
            NSLocalizedString("Photos",
                              comment: "Button Title in an Alert that allows the user to open the photo library on their phone to choose a photo.")
        static let buttonTitleViewPhoto =
            NSLocalizedString("View Current Photo",
                              comment: "Button Title in an Alert that allows the user to view the existing photo full-screen.")
        static let buttonTitleCamera =
            NSLocalizedString("Camera",
                              comment: "Button Title in an Alert that allows the user to open the camera and take a new photo.")
        static let buttonTitleCameraLocked =
            NSLocalizedString("Camera 🔒",
                              comment: "Button Title in an Alert that allows the user to open the camera and take a new photo. In this case, the user has denied access to the camera.")
        static let buttonTitleDelete =
            NSLocalizedString("Delete",
                              comment: "Button that allows the user to delete a reminder or a plant.")
        static let buttonTitleNewPlant =
            NSLocalizedString("New Plant",
                              comment: "Button that allows the user to add a new plant.")
        static let buttonTitleDismiss =
            NSLocalizedString("Dismiss",
                              comment: "Button Title in an Alert to close the alert. This button title normally only appears when there are no other options in the alert.")
        static let buttonTitleDontDelete =
            NSLocalizedString("Don't Delete",
                              comment: "Alert: Delete Confirmation: Button Title: When the user is being asked to confirm to delete an item, this button lets them not delete it.")
        static let buttonTitleCancel =
            NSLocalizedString("Cancel",
                              comment: "Button Title in an Alert to close the alert without saving any changes.")
        static let buttonTitleSaveAnyway =
            NSLocalizedString("Save Anyway",
                              comment: "Button Title in an Alert to save the reminder or plant even though all of the fields have not been filled in yet. Fields not yet filled in could include Name, Photo, Reminders.")
        static let titleUnsolvedIssues =
            NSLocalizedString("There are some issues you might want to resolve.",
                              comment: "Title of an Alert that tells the user that they are trying to save a Plant or Reminder and they have not filled in all the fields. They may want to cancel the save and go back and fill them in. Or they may want to Save the changes anyway. Fields not filled in could include, Name, Photo, Reminders.")
        static let newPermissionTitle: String =
            NSLocalizedString("Push Notifications",
                              comment: "Alert: New Permission: Title: Title of the alert that asks the user if they want to grant notification permissions.")
        static let newPermissionMessage: String =
            NSLocalizedString("Do you want WaterMe to send notifications when your plants need attention? WaterMe sends no more than 1 per day.",
                              comment: "Alert: New Permission: Message: Message of the alert that asks the user if they want to grant notification permissions.")
        static let newPermissionButtonTitleSendNotifications: String =
            NSLocalizedString("Send Notifications",
                              comment: "Alert: New Permission: Button Title: Send Notifications: Title of the button that will result in the user being presented the system dialog to grant notification permissions.")
        static let newPermissionButtonTitleDontSendNotifications: String =
            NSLocalizedString("Don't Send Notifications",
                              comment: "Alert: New Permission: Button Title: Don't Send Notifications: Title of the button that will result in the user not being asked for permissions ever again.")
        static let permissionDeniedAlertTitle =
            NSLocalizedString("Can't Send Push Notifications",
                              comment: "Alert: Permission Denied: Title: Title of the alert that tells the user that notification permissions are denied.")
        static let permissionDeniedAlertMessage =
            NSLocalizedString("Permissions to send notifications have been denied. If you would like to receive notifications when your plants need to be attened to, tap the Settings button below.",
                              comment: "Alert: Permission Denied: Message: Message of the alert that tells the user that notification permissions are denied. It asks the user to open Settings.")
        static let permissionDeniedButtonTitleDontAskAgain: String =
            NSLocalizedString("Don't Ask Again",
                              comment: "Alert: New Permission: Button Title: Don't Ask Again: Button title that will stop the app from asking about denied notifications again.")
        static let deleteAlertMessage: String =
            NSLocalizedString("Are you sure you want to delete this?",
                              comment: "Alert: Delete: Message: Message of the alert that asks the user if they want to delete this item.")
        static let copyEmailAlertButtonTitle: String =
            NSLocalizedString("Copy Email Address",
                              comment: "Alert: Email Copy: Button Title and Alert Title: When the user taps this button, the developers email address is copied into the users clipboard so the user can paste it into their favorite email app.")
        static let copyEmailAlertMessage: String =
            NSLocalizedString("Copy my email address into your clipboard, then paste it in your favorite email app.",
                              comment: "Alert: Email Copy: Message: Alert message that tells the user that they can copy my email address into their clipboard and paste it in their favorite email app.")
    }
}

extension EmailDeveloperViewController {
    enum LocalizedString {
        static let subject =
            NSLocalizedString("I have an idea for WaterMe!",
                              comment: "Email Compose: Subject: Shows in the subject line when an iOS in-app mail sheet is presented.")
    }
}

extension Reminder.Kind {
    enum LocalizedString {
        static let waterLong =
            NSLocalizedString("Water Plant",
                              comment: "Reminder Kind: Long Description: This type reminds the user to water their plant.")
        static let fertilizeLong =
            NSLocalizedString("Fertilize Soil",
                              comment: "Reminder Kind: Long Description: This type reminds the user to fertilize their plant.")
        static let trimLong =
            NSLocalizedString("Trim Plant",
                              comment: "Reminder Kind: Long Description: This type reminds the user to trim their plant.")
        static let mistLong =
            NSLocalizedString("Mist Plant",
                              comment: "Reminder Kind: Long Description: This type reminds the user to mist their plant.")
        static let moveLong =
            NSLocalizedString("Move Plant",
                              comment: "Reminder Kind: Long Description: This type reminds the user to move their plant.")
        static let waterShort =
            NSLocalizedString("Water",
                              comment: "Reminder Kind: Short Description: This type reminds the user to water their plant.")
        static let fertilizeShort =
            NSLocalizedString("Fertilize",
                              comment: "Reminder Kind: Short Description: This type reminds the user to fertilize their plant.")
        static let trimShort =
            NSLocalizedString("Trim",
                              comment: "Reminder Kind: Short Description: This type reminds the user to trim their plant.")
        static let mistShort =
            NSLocalizedString("Mist",
                              comment: "Reminder Kind: Short Description: This type reminds the user to mist their plant.")
        static let moveShort =
            NSLocalizedString("Move",
                              comment: "Reminder Kind: Short Description: This type reminds the user to move their plant.")
        static let other =
            NSLocalizedString("Other",
                              comment: "Reminder Kind: This type reminds the user to do something the user entered.")
    }
}

extension ReminderVesselMainViewController {
    enum LocalizedString {
        static let title =
            NSLocalizedString("Plants",
                              comment: "Title of the screen where the user can manage their plants. Also, title of the button that opens this screen.")
    }
}

extension SettingsMainViewController {
    enum LocalizedString {
        static let settingsTitle =
            NSLocalizedString("Settings",
                              comment: "Button title that opens both the in-app settings screen and the iOS settings screen for WaterMe.")
        static let title =
            NSLocalizedString("Tip Jar",
                              comment: "Screen title for the settings screen. Also used for button titles to open the Settings screen.")
        static let cellTitleOpenSettings =
            NSLocalizedString("Open Settings",
                              comment: "Settings: Cell Title: Open Settings: When tapped this opens the iOS settings app to the WaterMe screen.")
        static let cellTitleEmailDeveloper =
            NSLocalizedString("Email Developer",
                              comment: "Settings: Cell Title: Email Developer: When tapped, this opens an email screen to email the developer.")
        static let cellTitleTipJarFree =
            NSLocalizedString("Write App Review",
                              comment: "Settings: Cell Title: Tip Jar Free: When tapped, this opens an screen to review the app.")
        static let cellPriceTipJarFree =
            NSLocalizedString("Free",
                              comment: "Settings: Cell Price: Price of leaving a review on the app store... Free")
        static let cellTitleInfo =
            NSLocalizedString("I'm Jeff, a professional iOS Developer and UX Designer. I like making small and polished apps in my spare time. If you find WaterMe useful and would like to fund its development, consider supporting the app with the buttons below.",
                              comment: "Settings: Info Cell: Title: Text in the tip jar area that explains why someone should give money.")

    }
}

extension EmojiPickerFooterCollectionReusableView {
    enum LocalizedString {
        static let providedBy =
            NSLocalizedString("Emoji Provided by EmojiOne",
                              comment: "EmojiPicker: Footer: Label: Explains the emoji are provided by EmojiOne. Must contain one and only one instance of the  string under key 'EmojiOne' because its given a different font treatment.")
        static let emojiOne =
            NSLocalizedString("EmojiOne",
                              comment: "EmojiPicker: Footer: Used to style the 'Emoji Provided by EmojiOne' key.")
    }
}

extension ReminderVesselEditViewController {
    enum LocalizedString {
        static let rowLabelInterval =
            NSLocalizedString("Every: ",
                              comment: "Data Label: Reminder Interval: Value of the text next to the label is how often the user wants to be reminded to tend to their plant.")
        static let rowLabelLocation =
            NSLocalizedString("Location: ",
                              comment: "Data Label: Location: Value of the text next to the label is the location where the user wants to be reminded to move their plant.")
        static let rowLabelDescription =
            NSLocalizedString("Description: ",
                              comment: "Data Label: Description: Value of the text next to the label is what the user wants to be reminded to do to their plant.")
        static let rowValueLabelLocationNoValue =
            NSLocalizedString("No Location Entered",
                              comment: "Data Value: Location not entered: This is the placeholder value if the user does not enter a location for their move plant reminder.")
        static let rowValueLabelDescriptionNoValue =
            NSLocalizedString("No Description Entered",
                              comment: "Data Value: Description not entered: This is the placeholder value if the user does not enter a description for what they want to be reminded to do to their plant.")
        static let alertTitleCameraRestricted =
            NSLocalizedString("Camera Restricted",
                              comment: "Alert Title: Camera Restricted: We can't access the camera because it is not allowed by an IT policy / parent control.")
        static let alertBodyCameraRestricted =
            NSLocalizedString("WaterMe cannot access your camera. This feature has been restricted by this device's administrator.",
                              comment: "Alert Body: Camera Restricted: We can't access the camera because it is not allowed by an IT policy / parent control. This text needs to explain the problem.")
        static let alertTitlePermissionDenied =
            NSLocalizedString("Permission Denied",
                              comment: "Alert Title: Permission Denied: We can't access a feature of the device because the user has denied permission.")
        static let alertBodyCameraDenied =
            NSLocalizedString("WaterMe cannot access your camera. You can grant access in Settings",
                              comment: "Alert Body: Camera Denied: We can't access the camera because it has been denied by the user. The text needs to explain they can fix this by tapping the Settings button on the alert.")
    }
}

extension EmojiPickerViewController {
    enum LocalizedString {
        static let title =
            NSLocalizedString("Choose an Emoji",
                              comment: "Title of the view controller that allows a user to choose an emoji for the photo of their plant. Is shown in navigation bar.")
    }
}

extension ReminderEditViewController {
    enum LocalizedString {
        static let sectionTitleKind =
            NSLocalizedString("Kind of Reminder",
                              comment: "Edit Reminder: Section Title: Describes the section that asks them pick the kind of reminder. Possibilities are Water, Fertilize, Move, Other.")
        static let sectionTitleDetails =
            NSLocalizedString("Details",
                              comment: "Edit Reminder: Section Title: Describes the section that asks the user to enter details for Move or Other reminder types.")
        static let sectionTitleInterval =
            NSLocalizedString("Remind Every",
                              comment: "Edit Reminder: Section Title: Describes the section that asks the user to enter how often they want to be reminded.")
        static let sectionTitleNotes =
            NSLocalizedString("Notes",
                              comment: "Edit Reminder: Section Title: Describes the section that asks the user to enter any optional notes.")
        static let sectionTitleLastPerformed =
            NSLocalizedString("Last Performed",
                              comment: "Edit Reminder: Section Title: Describes the section that displays when the reminder was last performed.")
        static let dataEntryLabelMove =
            NSLocalizedString("Move to",
                              comment: "Edit Reminder: Data Entry Label: The label to the left of a text field. The user should type where they want to move their plant to in the textfield.")
        static let dataEntryLabelDescription =
            NSLocalizedString("Description",
                              comment: "Edit Reminder: Data Entry Label: The label to the left of a text field. The user should type a description of what they want to be reminded to do to their plant.")
        static let dataEntryPlaceholderMove =
            NSLocalizedString("Other side of the yard.",
                              comment: "Edit Reminder: Data Entry Placeholder: Placeholder text in a textfield. The user should type in where they want to move their plant.")
        static let dataEntryPlaceholderDescription =
            NSLocalizedString("Trim the leaves and throw out the clippings.",
                              comment: "Edit Reminder: Data Entry Placeholder: Placeholder text in a textfield. The user should type in what they want to be reminded to do to their plant.")
    }
}

extension ReminderUserNotificationController {
    enum LocalizedString {
        static let bodyOneItem =
            NSLocalizedString("‘%@’ needs attention today.",
                              comment: "Notification Body: 1 Item: When 1 plant needs to be taken care of in a day, this is the body text of the notification.")
        static let bodyTwoItems =
            NSLocalizedString("‘%@’ and ‘%@’ need attention today.",
                              comment: "Notification Body: 2 Items: When 2 plants needs to be taken care of in a day, this is the body text of the notification.")
        static let bodyManyItems =
            NSLocalizedString("‘%@’ and %d more plants need attention today.",
                              comment: "Notification Body: Many Items: When more than 2 plants needs to be taken care of in a day, this is the body text of the notification.")
    }
}

extension CoreDataMigratorViewController {
    enum LocalizedString {
        static let title =
            NSLocalizedString("WaterMe 2",
                              comment: "MigratorScreen: Title: Name of the app.")
        static let subtitle =
            NSLocalizedString("Data Migration",
                              comment: "MigratorScreen: Subtitle: Explains what is happening on the screen.")
        static let body =
            NSLocalizedString("In order to upgrade to WaterMe 2, a one time data migration is required.",
                              comment: "MigratorScreen: Body: Body text that explains the one time migration needed to upgrade to the new WaterMe.")
        static let bodyMigrating =
            NSLocalizedString("Migrating… Don't switch to a different app or lock the screen.",
                              comment: "MigratorScreen: Body: Body text that explains that the user should not lock the screen or switch apps until the migration is complete.")
        static let bodySuccess =
            NSLocalizedString("Success! Your plants have been migrated.",
                              comment: "MigratorScreen: Body: Body text that explains that the migration succeeded.")
        static let bodyFailure =
            NSLocalizedString("Oh no. A problem ocurred while migrating your plants. Please double check that all your plants are in WaterMe.",
                              comment: "MigratorScreen: Body: Body text that explains that the migration failed.")
        static let migrateButtonTitle =
            NSLocalizedString("Start Migration",
                              comment: "MigratorScreen: Start Button Title: When the user clicks this button the migration starts.")
        static let migratingButtonTitle =
            NSLocalizedString("Migrating…",
                              comment: "MigratorScreen: Migrating Button Title: After the user starts the migration, the text of the button changes to this to show that migration is in progress.")
        static let cancelButtonTitle =
            NSLocalizedString("Skip for Now",
                              comment: "MigratorScreen: Cancel Button Title: When the user clicks this button the screen is dismissed and the migration does not happen, but next time the app is started, it will ask again.")
        static let doneButtonTitle =
            NSLocalizedString("Continue",
                              comment: "MigratorScreen: Done Button Title: After migrtion has failed or succeeded this button is shown to the user. When they tap it, it closes the migrator screen and brings them to the main app.")
        static let deleteButtonTitle =
            NSLocalizedString("Don't Migrate My Plants",
                              comment: "MigratorScreen: Delete Button Title: When the user clicks this button, the screen is dismissed and it will never appear again and they will not have access to their previous plants. This action is destructive.")
    }
}

extension BasicController {
    static let starterDBPlantName =
        NSLocalizedString("Tap on Me",
                          comment: "First Launch: When the user opens the app for the first time, there is one plant shown in the app. It is called something that will make the user tap on it.")
    static let starterDBNote =
        NSLocalizedString("Welcome to WaterMe! This is your first plant. Use the button below to edit this plant and make it your own. When you’re ready to add all your plants, tap the ‘Plants’ button at the top right of the screen.",
                          comment: "First Launch: When the user opens the app for the first time, there is one plant shown in the app. When the user taps on the plant, this is the note shown that tells them how to use the app.")
}

extension PurchaseThanksViewController {
    enum LocalizedString {
        static let title =
            NSLocalizedString("Thank You!",
                              comment: "Purchase Thanks: Title: A thank you to the user for supporting WaterMe via In-App Purchase.")
        static let subtitle =
            NSLocalizedString("In-App Purchase",
                              comment: "Purchase Thanks: Subtitle: Reminding the user what we're thanking them for.")
        static let body =
            NSLocalizedString("Thank you for your purchase. Your support is critical to the continued development of WaterMe.",
                              comment: "Purchase Thanks: Body: Body text thanking the user for their support.")
        static let errorAlertTitle =
            NSLocalizedString("Purchase Error",
                              comment: "Alert: Purchase Error: Title: The title for all purchase error alerts.")
        static let errorNetworkAlertMessage =
            NSLocalizedString("A network error ocurred. Check your data connection and try to purchase again.",
                              comment: "Alert: Purchase Network Error: Message: Message when there was a networking error during the purchase process.")
        static let errorNotAllowedAlertMessage =
            NSLocalizedString("You're not allowed to make purchases on this device. Thank you for the thought, though ❤️",
                              comment: "Alert: Purchase Not Allowed Error: Message: Message when the user was not allowed to make a purchase.")
        static let errorUnknownAlertMessage =
            NSLocalizedString("An unknown error ocurred during the purchase. Please try again later.",
                              comment: "Alert: Purchase Not Allowed Error: Message: Message when an unknown error ocurred during the purchase.")
    }
}

extension RealmError {
    enum LocalizedString {
        static let deleteTitle =
            NSLocalizedString("Error Deleting",
                              comment: "Realm Error: Delete: Title: Unable to delete the last reminder associated with a plant.")
        static let deleteMessage =
            NSLocalizedString("Unable to delete this reminder because its the only reminder for this plant. Each plant must have at least one reminder.",
                              comment: "Realm Error: Delete: Message: Unable to delete the last reminder associated with a plant.")
        static let loadTitle =
            NSLocalizedString("Error Loading",
                              comment: "Realm Error: Loading: Title: Error loading the database from disk. The app is probably not usable with this error.")
        static let loadMessage =
            NSLocalizedString("Error loading save file. Check to make sure there is free space available on this device.",
                              comment: "Realm Error: Loading: Message: Error loading the database from disk. The app is probably not usable with this error.")
        static let saveImageTitle =
            NSLocalizedString("Error Saving Photo",
                              comment: "Realm Error: Save Image: Title: Error saving the photo the user took of their plant. User has to take another photo.")
        static let saveImageMessage =
            NSLocalizedString("The selected photo couldn't be saved. Please take a different photo or choose an emoji.",
                              comment: "Realm Error: Save Image: Message: Error saving the photo the user took of their plant. User has to take another photo.")
        static let saveTitle =
            NSLocalizedString("Error Saving",
                              comment: "Realm Error: Save: Title: There was an error saving changes. The app is probably not usable if this error happens.")
        static let saveMessage =
            NSLocalizedString("Error saving changes. Check to make sure there is free space available on this device.",
                              comment: "Realm Error: Save: Message: There was an error saving changes. The app is probably not usable if this error happens.")
        static let objectDeletedMessage =
            NSLocalizedString("Unable to save changes because the item was deleted. Possibly from another device.",
                              comment: "Realm Error: Object Deleted: Message: Error saving because the object that is being saved has already been deleted.")
        static let buttonTitleManageStorage =
            NSLocalizedString("Manage Storage",
                              comment: "Realm Error: Button Title: Manage Store: Opens the setting app for the user.")
    }
}

extension Reminder.Section {
    enum LocalizedString {
        static let late =
            NSLocalizedString("Late",
                              comment: "Reminder Main List: Section Header: Title")
        static let today =
            NSLocalizedString("Today",
                              comment: "Reminder Main List: Section Header: Title")
        static let tomorrow =
            NSLocalizedString("Tomorrow",
                              comment: "Reminder Main List: Section Header: Title")
        static let thisWeek =
            NSLocalizedString("This Week",
                              comment: "Reminder Main List: Section Header: Title")
        static let later =
            NSLocalizedString("Later",
                              comment: "Reminder Main List: Section Header: Title")
    }
}

extension ReminderVessel.Error {
    enum LocalizedString {
        static let missingPhoto =
            NSLocalizedString("Missing Photo",
                              comment: "Error Saving: Plant: Missing Photo: If the user has not chosen a photo or an emoji for their plant and tries to save, an alert will warn them. This is the button title to fix the error.")
        static let missingName =
            NSLocalizedString("Missing Name",
                              comment: "Error Saving: Plant: Missing Name: If the user has not a name for their plant and tries to save, an alert will warn them. This is the button title to fix the error.")
        static let missingReminders =
            NSLocalizedString("Missing Reminders",
                              comment: "Error Saving: Plant: Missing Reminders: If the user has not added at least one reminder for their plant and tries to save, an alert will warn them. This is the button title to fix the error.")
    }
}

extension Reminder.Error {
    enum LocalizedString {
        static let missingLocation =
            NSLocalizedString("Missing Location",
                              comment: "Error Saving: Reminder: Missing Location: If the user has no entered a location for their move reminder and tries to save, an alert will warn them. This is the button title to fix the error.")
        static let missingDescription =
            NSLocalizedString("Missing Description",
                              comment: "Error Saving: Reminder: Missing Description: If the user has not entered a description for their other reminder and tries to save, an alert will warn them. This is the button title to fix the error.")
    }
}
