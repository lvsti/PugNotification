import Foundation

protocol TypedNotification {}

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
        var userInfo: [String: Any]? = nil
        
        let notifMirror = Mirror(reflecting: notification)
        if !notifMirror.children.isEmpty {
            // has associated value
            let value = notifMirror.children.first!.value
            
            // check what we've got
            let valueMirror = Mirror(reflecting: value)
            
            if valueMirror.children.isEmpty {
                // unary case, value is scalar
                userInfo = ["arg1": value]
            } else {
                // n-ary case, walk the tuple
                userInfo = [:]
                for (i, item) in valueMirror.children.enumerated() {
                    userInfo?["arg\(i + 1)"] = item.value
                }
            }
        }
        
        NotificationCenter.default.post(name: name,
                                        object: nil,
                                        userInfo: userInfo)
    }

    static func addObserver(_ notification: Self, using block: @escaping () -> Void) -> ObserverToken {
        let name = Notification.Name(rawValue: stringify(notification))
        let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { _ in
            block()
        }
        return ObserverToken(observer: observer)
    }

    static func addObserver<T1>(_ notification: (T1) -> Self,
                                using block: @escaping (T1) -> Void) -> ObserverToken
        where T1 : TypedNotificationContentType {
        let name = Notification.Name(rawValue: stringify(notification(T1())))
        let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            if let arg1 = notification.userInfo?["arg1"] as? T1 {
                block(arg1)
            }
        }
        return ObserverToken(observer: observer)
    }

    static func addObserver<T1, T2>(_ notification: (T1, T2) -> Self,
                                    using block: @escaping (T1, T2) -> Void) -> ObserverToken
        where T1 : TypedNotificationContentType, T2 : TypedNotificationContentType {
        
        let name = Notification.Name(rawValue: stringify(notification(T1(), T2())))
        let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            if let arg1 = notification.userInfo?["arg1"] as? T1,
               let arg2 = notification.userInfo?["arg2"] as? T2 {
                block(arg1, arg2)
            }
        }
        return ObserverToken(observer: observer)
    }

    static func removeObserver(_ observer: ObserverToken) {
        NotificationCenter.default.removeObserver(observer.observer)
    }
}
