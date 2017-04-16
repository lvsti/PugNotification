enum PugNotification {
    case arrive
    case blep(isBlepping: Bool)
    case boop(count: UInt)
    case pet(location: PetLocation)
    case leave(snackName: String, snackCount: UInt)
}

public enum PetLocation {
    case ear
    case back
    case tummy
}

extension PugNotification: TypedNotification {}

extension Bool: TypedNotificationContentType {}
extension UInt: TypedNotificationContentType {}
extension PetLocation: TypedNotificationContentType {
    public init() {
        self = .ear
    }
}
extension String: TypedNotificationContentType {}
