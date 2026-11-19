import Foundation
import UserNotifications

/// Local notifications: workout reminders, hydration, meals and weekly check-in.
enum NotificationManager {
    private static let prefix = "ironcadence."

    @discardableResult
    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func isAuthorized() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }

    static func removeAll() async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    static func reschedule(settings: AppSettings, nextWorkoutTitle: String?) async {
        await removeAll()
        guard await isAuthorized() else { return }
        let center = UNUserNotificationCenter.current()

        if settings.workoutRemindersOn {
            for weekday in settings.trainingWeekdays {
                var c = DateComponents()
                c.weekday = weekday
                c.hour = settings.workoutTime.hour
                c.minute = settings.workoutTime.minute
                let content = UNMutableNotificationContent()
                content.title = "Time to train"
                content.body = nextWorkoutTitle.map { "Today's session: \($0). Get after it." }
                    ?? "Your next session is ready. No excuses."
                content.sound = .default
                add(center, id: "workout.\(weekday)", content: content, components: c)
            }
        }

        if settings.hydrationRemindersOn {
            let step = max(1, settings.hydrationIntervalHours)
            for hour in stride(from: 9, through: 20, by: step) {
                let content = UNMutableNotificationContent()
                content.title = "Hydrate"
                content.body = "Drink a glass of water (~250 ml) and log it in Iron Cadence."
                content.sound = .default
                add(center, id: "water.\(hour)", content: content, components: DateComponents(hour: hour, minute: 0))
            }
        }

        if settings.mealRemindersOn {
            let names = ["Breakfast", "Lunch", "Dinner", "Snack", "Snack"]
            for (i, time) in settings.mealTimes.enumerated() {
                let content = UNMutableNotificationContent()
                content.title = i < names.count ? names[i] : "Meal"
                content.body = "Refuel: build the plate around a palm-sized portion of protein."
                content.sound = .default
                add(center, id: "meal.\(i)", content: content,
                    components: DateComponents(hour: time.hour, minute: time.minute))
            }
        }

        if settings.weeklyCheckInOn {
            let content = UNMutableNotificationContent()
            content.title = "Weekly check-in"
            content.body = "Weigh in, review your week and look at next week's plan."
            content.sound = .default
            add(center, id: "checkin", content: content, components: DateComponents(hour: 8, minute: 0, weekday: 1))
        }
    }

    private static func add(_ center: UNUserNotificationCenter, id: String,
                            content: UNMutableNotificationContent, components: DateComponents) {
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.add(UNNotificationRequest(identifier: prefix + id, content: content, trigger: trigger))
    }

    /// One-off nudge after a workout to remind about post-training nutrition.
    static func schedulePostWorkoutRefuel() {
        let content = UNMutableNotificationContent()
        content.title = "Refuel window"
        content.body = "Get 20–40 g of protein plus some carbs in the next couple of hours."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 60, repeats: false)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: prefix + "refuel", content: content, trigger: trigger))
    }
}
