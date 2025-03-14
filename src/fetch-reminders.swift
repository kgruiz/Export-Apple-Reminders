import Foundation
import EventKit

// MARK: - JSON Structures

struct ReminderJSON: Codable {
    let calendarItemIdentifier: String
    let calendarItemExternalIdentifier: String?
    let calendarTitle: String?
    let title: String?
    let location: String?
    let creationDate: Date?
    let lastModifiedDate: Date?
    let timeZoneIdentifier: String?
    let url: String?
    let notes: String?
    let attendees: [String]?
    let alarms: [AlarmJSON]?
    let recurrenceRules: [RecurrenceRuleJSON]?
    let priority: Int
    let startDateComponents: DateComponentsJSON?
    let dueDateComponents: DateComponentsJSON?
    let isCompleted: Bool
    let completionDate: Date?
}

struct AlarmJSON: Codable {
    let absoluteDate: Date?
    let relativeOffset: TimeInterval
    let proximity: Int
    let structuredLocationTitle: String?
    let structuredLocationRadius: Double?
}

struct RecurrenceRuleJSON: Codable {
    let frequency: Int
    let interval: Int
    let recurrenceEndDate: Date?
    let occurrenceCount: Int?
}

// A helper struct to encode DateComponents
struct DateComponentsJSON: Codable {
    let year: Int?
    let month: Int?
    let day: Int?
    let hour: Int?
    let minute: Int?
    let second: Int?

    init(_ components: DateComponents) {
        self.year = components.year
        self.month = components.month
        self.day = components.day
        self.hour = components.hour
        self.minute = components.minute
        self.second = components.second
    }
}

// MARK: - Reminder Extractor

class ReminderExtractor {

    let eventStore = EKEventStore()
    let dispatchGroup = DispatchGroup()
    var remindersJSON: [ReminderJSON] = []

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

    /// Fetches all reminders (complete and incomplete) and converts them to JSON-serializable objects.
    func fetchAllReminders() {
        let predicate = eventStore.predicateForReminders(in: nil)
        eventStore.fetchReminders(matching: predicate) { reminders in
            guard let reminders = reminders else {
                print("No reminders found.")
                self.dispatchGroup.leave()
                return
            }
            for reminder in reminders {
                if let jsonReminder = self.createReminderJSON(from: reminder) {
                    self.remindersJSON.append(jsonReminder)
                }
            }
            self.dispatchGroup.leave()
        }
    }

    /// Converts an EKReminder to a ReminderJSON object.
    func createReminderJSON(from reminder: EKReminder) -> ReminderJSON? {
        let calendarTitle = reminder.calendar?.title
        let attendeesNames = reminder.attendees?.compactMap { $0.name }
        let alarmsJSON: [AlarmJSON]? = reminder.alarms?.map { alarm in
            let structuredTitle = alarm.structuredLocation?.title
            let structuredRadius = alarm.structuredLocation?.radius
            return AlarmJSON(absoluteDate: alarm.absoluteDate,
                             relativeOffset: alarm.relativeOffset,
                             proximity: alarm.proximity.rawValue,
                             structuredLocationTitle: structuredTitle,
                             structuredLocationRadius: structuredRadius)
        }
        let recurrenceRulesJSON: [RecurrenceRuleJSON]? = reminder.recurrenceRules?.map { rule in
            let recurrenceEndDate = rule.recurrenceEnd?.endDate
            let occurrenceCount = rule.recurrenceEnd?.occurrenceCount
            return RecurrenceRuleJSON(frequency: rule.frequency.rawValue,
                                      interval: rule.interval,
                                      recurrenceEndDate: recurrenceEndDate,
                                      occurrenceCount: occurrenceCount)
        }

        return ReminderJSON(
            calendarItemIdentifier: reminder.calendarItemIdentifier,
            calendarItemExternalIdentifier: reminder.calendarItemExternalIdentifier,
            calendarTitle: calendarTitle,
            title: reminder.title,
            location: reminder.location,
            creationDate: reminder.creationDate,
            lastModifiedDate: reminder.lastModifiedDate,
            timeZoneIdentifier: reminder.timeZone?.identifier,
            url: reminder.url?.absoluteString,
            notes: reminder.notes,
            attendees: attendeesNames,
            alarms: alarmsJSON,
            recurrenceRules: recurrenceRulesJSON,
            priority: reminder.priority,
            startDateComponents: reminder.startDateComponents.map { DateComponentsJSON($0) },
            dueDateComponents: reminder.dueDateComponents.map { DateComponentsJSON($0) },
            isCompleted: reminder.isCompleted,
            completionDate: reminder.completionDate
        )
    }

    /// Writes the remindersJSON array to a JSON file in the current directory.
    func writeRemindersToJSONFile() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(remindersJSON)
            let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                .appendingPathComponent("reminders.json")
            try data.write(to: fileURL)
            print("Reminders written to: \(fileURL.path)")
        } catch {
            print("Failed to write reminders to JSON: \(error)")
        }
    }
}

// MARK: - Main Execution

let extractor = ReminderExtractor()
extractor.requestAccessAndFetchAllReminders()

// Wait until asynchronous operations are complete, then write JSON and exit.
extractor.dispatchGroup.wait()
extractor.writeRemindersToJSONFile()
exit(0)