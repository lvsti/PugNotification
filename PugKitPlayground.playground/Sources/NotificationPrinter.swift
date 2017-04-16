public class NotificationPrinter {
    private var observers = [ObserverToken]()

    public init() {
        var token = PugNotification.addObserver(.arrive) {
            print("Stubbly is here!")
        }
        observers.append(token)

        token = PugNotification.addObserver(PugNotification.blep) { isBlepping in
            if isBlepping {
                print("Stubbly is blepping!")
            } else {
                print("Stubbly is not blepping…")
            }
        }
        observers.append(token)

        token = PugNotification.addObserver(PugNotification.boop) { count in
            print("Stubbly has been booped \(count) times!")
        }
        observers.append(token)

        token = PugNotification.addObserver(PugNotification.pet) { location in
            switch location {
            case .ear:
                print("Stubbly is being scratched on the ear!")
            case .back:
                print("Stubbly is being petted on the back!")
            case .tummy:
                print("Stubbly is being rubbed on the tummy!")
            }
        }
        observers.append(token)

        token = PugNotification.addObserver(PugNotification.leave) { snackName, snackCount in
            switch snackCount {
            case 0:
                print("Stubbly had to leave because it wants to eat 0 \(snackName)s. ¯\\_(ツ)_/¯")
            case 1:
                print("Stubbly had to leave because it wants to eat a \(snackName).")
            default:
                print("Stubbly had to leave because it wants to eat \(snackCount) \(snackName)s.")
            }
        }
        observers.append(token)
    }
}
