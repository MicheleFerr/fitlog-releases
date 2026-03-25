import XCTest
@testable import Runner

class RunnerTests: XCTestCase {

  func testInfoPlistRemovesTimerBackgroundDeclarations() throws {
    let plist = try loadRunnerInfoPlist()

    let backgroundModes = plist["UIBackgroundModes"] as? [String] ?? []
    let permittedTasks = plist["BGTaskSchedulerPermittedIdentifiers"] as? [String] ?? []

    XCTAssertFalse(backgroundModes.contains("audio"))
    XCTAssertNil(plist["NSAlarmKitUsageDescription"])
    XCTAssertFalse(permittedTasks.contains("com.gymbro.timer.refresh"))
    XCTAssertFalse(permittedTasks.contains("com.gymbro.timer.processing"))
  }

  func testDirectNotificationManagerFindsBundledTimerSound() {
    XCTAssertTrue(DirectNotificationManager.shared.verifyAudioFile("timer_complete"))
    XCTAssertEqual(
      DirectNotificationManager.timerCategoryIdentifier,
      RestTimerNotificationSupport.categoryIdentifier
    )
    XCTAssertEqual(
      DirectNotificationManager.restTimerNotificationIdentifier,
      RestTimerNotificationSupport.notificationIdentifier
    )
  }

  private func loadRunnerInfoPlist() throws -> [String: Any] {
    let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let plistURL = testsDirectory
      .deletingLastPathComponent()
      .appendingPathComponent("Runner/Info.plist")

    let plistData = try Data(contentsOf: plistURL)
    let plist = try XCTUnwrap(
      PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any]
    )
    return plist
  }
}
