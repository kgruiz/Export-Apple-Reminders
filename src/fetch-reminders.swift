import Foundation
import EventKit

class ReminderExtractor {

    let eventStore = EKEventStore()
    let dispatchGroup = DispatchGroup()

    /// Requests full access to reminders and, if granted, fetches all reminders.
    func requestAccessAndFetchAllReminders() {
        dispatchGroup.enter()
        // Use the newer full-access method for reminders (macOS 14+)
        eventStore.requestFullAccessToReminders { granted, error in
            if granted {
                self.fetchAllReminders()
            } else {
                if let error = error {
                    print("Error requesting access: \(error)")
                } else {
                    print("Access to reminders was not granted.")
                }
                self.dispatchGroup.leave()
            }
        }
    }

    /// Fetches all reminders (complete and incomplete) and prints all available attributes.
    func fetchAllReminders() {
        let predicate = eventStore.predicateForReminders(in: nil)
        eventStore.fetchReminders(matching: predicate) { reminders in
            guard let reminders = reminders else {
                print("No reminders found.")
                self.dispatchGroup.leave()
                return
            }
            for reminder in reminders {
                self.printReminderAttributes(reminder)
            }
            self.dispatchGroup.leave()
        }
    }

    /// Prints all accessible attributes for a given EKReminder.
    func printReminderAttributes(_ reminder: EKReminder) {
        print("========================================")
        print("Calendar Item Identifier: \(reminder.calendarItemIdentifier)")
        print("Calendar Item External Identifier: \(reminder.calendarItemExternalIdentifier ?? "N/A")")
        // The 'uuid' property is unavailable on macOS; omitted.
        if let calendar = reminder.calendar {
            print("Calendar: \(calendar.title)")
        } else {
            print("Calendar: N/A")
        }
        print("Title: \(reminder.title ?? "No Title")")
        print("Location: \(reminder.location ?? "N/A")")
        if let creationDate = reminder.creationDate {
            print("Creation Date: \(creationDate)")
        } else {
            print("Creation Date: N/A")
        }
        if let lastModifiedDate = reminder.lastModifiedDate {
            print("Last Modified Date: \(lastModifiedDate)")
        } else {
            print("Last Modified Date: N/A")
        }
        if let timeZone = reminder.timeZone {
            print("Time Zone: \(timeZone.identifier)")
        } else {
            print("Time Zone: N/A")
        }
        if let url = reminder.url {
            print("URL: \(url)")
        } else {
            print("URL: N/A")
        }
        print("Has Notes: \(reminder.hasNotes)")
        print("Notes: \(reminder.notes ?? "N/A")")
        print("Has Attendees: \(reminder.hasAttendees)")
        if let attendees = reminder.attendees {
            print("Attendees Count: \(attendees.count)")
            for attendee in attendees {
                print(" - Attendee: \(attendee.name ?? "Unknown")")
            }
        } else {
            print("Attendees: N/A")
        }
        print("Has Alarms: \(reminder.hasAlarms)")
        if let alarms = reminder.alarms {
            print("Alarms Count: \(alarms.count)")
            for alarm in alarms {
                if let absoluteDate = alarm.absoluteDate {
                    print(" - Alarm Absolute Date: \(absoluteDate)")
                }
                print(" - Relative Offset: \(alarm.relativeOffset)")
                print(" - Proximity: \(alarm.proximity)")
                if let structuredLocation = alarm.structuredLocation {
                    print(" - Structured Location Title: \(structuredLocation.title ?? "N/A")")
                    print(" - Radius: \(structuredLocation.radius)")
                }
            }
        } else {
            print("Alarms: N/A")
        }
        print("Has Recurrence Rules: \(reminder.hasRecurrenceRules)")
        if let rules = reminder.recurrenceRules {
            print("Recurrence Rules Count: \(rules.count)")
            for rule in rules {
                print(" - Frequency: \(rule.frequency)")
                print(" - Interval: \(rule.interval)")
                if let recurrenceEnd = rule.recurrenceEnd {
                    if let endDate = recurrenceEnd.endDate {
                        print(" - Recurrence Ends on: \(endDate)")
                    } else {
                        print(" - Occurrence Count: \(recurrenceEnd.occurrenceCount)")
                    }
                }
            }
        } else {
            print("Recurrence Rules: N/A")
        }
        print("Priority: \(reminder.priority)")
        if let startDateComponents = reminder.startDateComponents {
            print("Start Date Components: \(startDateComponents)")
        } else {
            print("Start Date Components: N/A")
        }
        if let dueDateComponents = reminder.dueDateComponents {
            print("Due Date Components: \(dueDateComponents)")
        } else {
            print("Due Date Components: N/A")
        }
        print("Is Completed: \(reminder.isCompleted)")
        if let completionDate = reminder.completionDate {
            print("Completion Date: \(completionDate)")
        } else {
            print("Completion Date: N/A")
        }
        print("========================================")
    }
}

// Create an instance and start the extraction process.
let extractor = ReminderExtractor()
extractor.requestAccessAndFetchAllReminders()

// Wait until asynchronous operations are complete, then exit.
extractor.dispatchGroup.wait()
exit(0)
