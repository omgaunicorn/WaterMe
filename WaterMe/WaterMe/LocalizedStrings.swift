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

extension AppDelegate {
    enum LocalizedString {
        static let appTitle =
            NSLocalizedString("WaterMe",
                              comment: "Name of the app. Shows in various places like Navigation Bars and Alerts.")
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
        static let buttonTitleReminderEdit =
            NSLocalizedString("Edit Reminder",
                              comment: "Button Title in an Alert. Shows when the user taps on a reminder. After being selected, this will allow the user to edit the details of the reminder.")
        static let buttonTitleReminderVesselEdit =
            NSLocalizedString("Edit Plant",
                              comment: "Button Title in an Alert. Shows when the user taps on a reminder. After being selected, this will allow the user to edit the details of the plant that owns the reminder.")
        static let buttonTitleReminderPerform =
            NSLocalizedString("Mark Reminder as Done",
                              comment: "Button Title in an Alert. Shows when the user taps on a reminder. After being selected, this will mark the reminder as performed.")
    }
}

extension UIAlertController {
    enum LocalizedString {
        static let buttonTitleEmoji =
            NSLocalizedString("Emoji",
                              comment: "Button Title in an Alert that allows the user to open a screen where they can choose from various emoji instead of a photo for their plant.")
        static let buttonTitlePhotos =
            NSLocalizedString("Photos",
                              comment: "Button Title in an Alert that allows the user to open the photo library on their phone to choose a photo.")
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
        static let buttonTitleCancel =
            NSLocalizedString("Cancel",
                              comment: "Button Title in an Alert to close the alert without saving any changes.")
        static let buttonTitleSaveAnyway =
            NSLocalizedString("Save Anyway",
                              comment: "Button Title in an Alert to save the reminder or plant even though all of the fields have not been filled in yet. Fields not yet filled in could include Name, Photo, Reminders.")
        static let buttonTitleSettings =
            NSLocalizedString("Settings",
                              comment: "Button Title in an Alert to take the user to the Settings page for WaterMe and change permissions and notification preferences.")
        static let titleUnsolvedIssues =
            NSLocalizedString("There are some issues you might want to resolve.",
                              comment: "Title of an Alert that tells the user that they are trying to save a Plant or Reminder and they have not filled in all the fields. They may want to cancel the save and go back and fill them in. Or they may want to Save the changes anyway. Fields not filled in could include, Name, Photo, Reminders.")
    }
}

extension ReminderVesselMainViewController {
    enum LocalizedString {
        static let title =
            NSLocalizedString("Plants",
                              comment: "Title of the screen where the user can manage their plants.")
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

extension Reminder.Kind {
    enum LocalizedString {
        static let water =
            NSLocalizedString("Water",
                              comment: "Reminder Kind: This type reminds the user to water their plant.")
        static let fertilize =
            NSLocalizedString("Fertilize",
                              comment: "Reminder Kind: This type reminds the user to fertilize their plant.")
        static let move =
            NSLocalizedString("Move",
                              comment: "Reminder Kind: This type reminds the user to move their plant.")
        static let other =
            NSLocalizedString("Other",
                              comment: "Reminder Kind: This type reminds the user to do something the user entered.")
    }
}

// TODO: Convert to Localized String with Format
extension ReminderUserNotificationController {
    enum LocalizedStrings {
        static func notificationBodyWithPlantNames(plantNames: [String?]) -> String {
            switch plantNames.count {
            case 0:
                fatalError("Tried to create a notification for no plants")
            case 1:
                let name1 = plantNames[0] ?? ReminderVessel.LocalizedString.untitledPlant
                return "\(name1) needs attention today."
            case 2:
                let name1 = plantNames[0] ?? ReminderVessel.LocalizedString.untitledPlant
                let name2 = plantNames[1] ?? ReminderVessel.LocalizedString.untitledPlant
                return "\(name1) & \(name2) need attention today."
            default:
                let name1 = plantNames[0] ?? ReminderVessel.LocalizedString.untitledPlant
                return "\(name1) & \(plantNames.count) more need attention today."
            }
        }
    }
}
