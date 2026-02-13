import Foundation
import UIKit

/// Manages background task execution for iOS apps.
/// Handles requesting and managing background task time extensions.
@MainActor
final class BackgroundTaskManager {

    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    /// Begins a background task with the given expiration handler.
    /// - Parameters:
    ///   - expirationHandler: Called when the system is about to terminate the background task
    /// - Returns: The background task identifier
    @discardableResult
    func beginBackgroundTask(expirationHandler: @escaping () -> Void) -> UIBackgroundTaskIdentifier {
        // End any existing background task first
        endCurrentTask()

        // Begin new background task
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            // System is about to terminate the background task
            expirationHandler()
            self?.endCurrentTask()
        }

        return backgroundTask
    }

    /// Ends the current background task if one is active.
    func endCurrentTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    /// The remaining time (in seconds) that the app has to run in the background.
    /// Returns a very large number if background execution is not limited.
    var remainingTime: TimeInterval {
        UIApplication.shared.backgroundTimeRemaining
    }

    /// Whether a background task is currently active.
    var isBackgroundTaskActive: Bool {
        backgroundTask != .invalid
    }
}
