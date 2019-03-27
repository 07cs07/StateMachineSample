import UIKit

protocol SecuritySystem {
    func arm()
    func disarm(usingCode: String)
    func breach()
    func panic()
    func reset(usingCode: String)
}

protocol Events {
    func arm(_: System)
    func disarm(usingCode: String, _: System)
    func breach(_: System)
    func panic(_: System)
    func reset(usingCode: String, _: System)
}

extension Events {
    func arm(_: System) {}
    func disarm(usingCode: String, _: System) {}
    func breach(_: System) {}
    func panic(_: System) {}
    func reset(usingCode: String, _: System) {}
}

protocol Activities {
    func enter(_: System)
    func exit(_: System)
}

extension Activities {
    func enter(_: System) {}
    func exit(_: System) {}
}

typealias State = Events & Activities

class System: SecuritySystem {
    
    private var state: State
    private let code: String

    init(code: String, initialState: State) {
        self.code = code
        state = initialState
    }
    
    func arm() {
        state.arm(self)
    }
    
    func disarm(usingCode code: String) {
        state.disarm(usingCode: code, self)
    }
    
    func breach() {
        state.breach(self)
    }
    
    func panic() {
        state.panic(self)
    }
    
    func reset(usingCode code: String) {
        state.reset(usingCode: code, self)
    }
}

extension System {
    
    func transition(to newState: State) {
        state.exit(self)
        state = newState
        state.enter(self)
    }
    
    func isValid(code: String) -> Bool {
        let isValid = code == self.code
        print(isValid ? "Code accepted" : "Invalid code")
        return isValid
    }
}

class DisarmedState: State {
    
    func enter(_: System) {
        print("System disarmed")
    }
    
    func panic(_ system: System) {
        system.transition(to: AlarmState.instance)
    }
    
    func breach(_ system: System) {
        system.transition(to: SilentAlarmState.instance)
    }
    
    func arm(_ system: System) {
        system.transition(to: ArmedState.instance)
    }
    
    static let instance = DisarmedState()
}

class ArmedState: State {
    
    private var disarmAttempts = 0
    private let maxDisarmAttempts = 3
    
    func enter(_: System) {
        print("System armed")
    }
    
    func disarm(usingCode code: String, _ system: System) {
        disarmAttempts += 1
        if system.isValid(code: code) {
            system.transition(to: DisarmedState.instance)
        } else if disarmAttempts <= maxDisarmAttempts {
            return
        } else {
            system.transition(to: AlarmState.instance)
        }
    }
    
    func breach(_ system: System) {
        system.transition(to: AlarmState.instance)
    }
    
    func panic(_ system: System) {
        system.transition(to: AlarmState.instance)
    }
    
    static var instance: State {
        return ArmedState()
    }
}

class AlarmState: State {
    
    func enter(_: System) {
        print("Alarm sounded")
    }
    
    func exit(_: System) {
        print("Alarm stopped")
    }
    
    func reset(usingCode code: String, _ system: System) {
        guard system.isValid(code: code) else { return }
        system.transition(to: DisarmedState.instance)
    }
    
    static let instance = AlarmState()
}

class SilentAlarmState: State {
    
    func enter(_: System) {
        print("Call Police")
    }
    
    static let instance = SilentAlarmState()
}

class SecuritySystemFactory {
    static func create(withCode code: String) -> SecuritySystem {
        return System(code: code, initialState: DisarmedState.instance)
    }
}


let system = SecuritySystemFactory.create(withCode: "1234")
system.reset(usingCode: "3333")

system.arm()
system.disarm(usingCode: "23232")
system.disarm(usingCode: "1234")
system.arm()
system.panic()
system.reset(usingCode: "1234")
system.breach()
