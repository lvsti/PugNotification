import Foundation

protocol TypedNotification {
    var content: TypedNotificationContentType? { get }
}

protocol TypedNotificationContentType {
    init()
}

class ObserverToken {
    fileprivate let observer: NSObjectProtocol

    fileprivate init(observer: NSObjectProtocol) {
        self.observer = observer
    }
}

extension TypedNotification {
    private static func stringify(_ notification: Self) -> String {
        let m = Mirror(reflecting: notification)
        let caseName = m.children.isEmpty ? "\(notification)" : m.children.first!.label!
        let name = "\(type(of: notification))_\(caseName)"
        return name
    }

    static func post(_ notification: Self) {
        let name = Notification.Name(rawValue: stringify(notification))
        let userInfo = notification.content.map({ ["content": $0] })
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }

    static func addObserver(_ notification: Self, using block: @escaping () -> Void) -> ObserverToken {
        let name = Notification.Name(rawValue: stringify(notification))
        let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { _ in
            block()
        }
        return ObserverToken(observer: observer)
    }
    static func addObserver<T1: TypedNotificationContentType>
        (_ notification: (T1) -> Self, using block: @escaping (T1) -> Void) -> ObserverToken {
            let name = Notification.Name(rawValue: stringify(notification(T1())))
            let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
                if let content = notification.userInfo?["content"] as? T1 {
                    block(content)
                }
            }
            return ObserverToken(observer: observer)
    }

    static func removeObserver(_ observer: ObserverToken) {
        NotificationCenter.default.removeObserver(observer.observer)
    }
}
