// bin/safari-js-check が使う通知用のアプリ。
//
//   safari-js-check notify   通知を出してすぐに終わる
//   (引数なし)               通知のクリックで macOS に起動されたとき。Safari の
//                            設定画面を開いて終わる
//
// osascript の display notification はクリックしてもスクリプトエディタが開く
// だけなので、クリックを受け取るためにアプリとして通知を出す。通知を出した
// プロセスが終わっていても、クリックされると macOS がこのアプリを起動し直して
// UNUserNotificationCenter のデリゲートに伝える。

import AppKit
import UserNotifications

final class Handler: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var handled = false

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            openSafariSettings()
        }
        handled = true
        completionHandler()
    }
}

// Safari の AppleScript に設定画面を直接開くコマンドは無い。隠しコマンドの
// show extensions preferences で「機能拡張」タブが開くので、それを使う。
// 「デベロッパ」タブへの切り替えは UI 操作 (アクセシビリティの許可) が要るので
// しない。
func openSafariSettings() {
    let source = """
        tell application "Safari"
            activate
            show extensions preferences ""
        end tell
        """
    var error: NSDictionary?
    NSAppleScript(source: source)?.executeAndReturnError(&error)
    if let error {
        fputs("failed to open Safari settings: \(error)\n", stderr)
    }
}

func notify(center: UNUserNotificationCenter) {
    let sema = DispatchSemaphore(value: 0)
    var granted = false
    center.requestAuthorization(options: [.alert, .sound]) { ok, error in
        granted = ok
        if let error {
            fputs("notification authorization error: \(error.localizedDescription)\n", stderr)
        }
        sema.signal()
    }
    sema.wait()
    guard granted else {
        fputs("notifications not authorized; enable in System Settings > Notifications\n", stderr)
        exit(1)
    }

    let content = UNMutableNotificationContent()
    content.title = "Safari: Apple Events からの JavaScript が ON のままです"
    content.body = "クリックで Safari の設定を開きます。デベロッパタブで OFF に戻してください"
    content.sound = .default

    // 識別子を固定して、前の通知が残っていれば置き換える
    let request = UNNotificationRequest(identifier: "safari-js-check", content: content, trigger: nil)
    var failed = false
    center.add(request) { error in
        if let error {
            fputs("notification delivery error: \(error.localizedDescription)\n", stderr)
            failed = true
        }
        sema.signal()
    }
    sema.wait()
    exit(failed ? 1 : 0)
}

// クリックで起動されたときは、デリゲートに届くまでイベントを回して待つ
func waitForClick(handler: Handler, timeout: TimeInterval) {
    let deadline = Date(timeIntervalSinceNow: timeout)
    while !handler.handled && Date() < deadline {
        if let event = NSApp.nextEvent(
            matching: .any,
            until: Date(timeIntervalSinceNow: 0.1),
            inMode: .default,
            dequeue: true
        ) {
            NSApp.sendEvent(event)
        }
    }
}

let handler = Handler()
_ = NSApplication.shared
NSApp.setActivationPolicy(.accessory)
NSApp.delegate = handler
let center = UNUserNotificationCenter.current()
center.delegate = handler
NSApp.finishLaunching()

if CommandLine.arguments.dropFirst().first == "notify" {
    notify(center: center)
} else {
    waitForClick(handler: handler, timeout: 5)
}
