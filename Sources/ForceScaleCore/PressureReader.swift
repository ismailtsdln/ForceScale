import Foundation

public protocol PressureReaderDelegate: AnyObject {
    func pressureReader(_ reader: PressureReader, didUpdatePressure pressure: Double)
}

public class PressureReader {
    public weak var delegate: PressureReaderDelegate?
    
    private let bridge = MultitouchBridge()
    private var lastPressure: Double = 0.0
    
    public init() {
        bridge.pressureHandler = { [weak self] pressure in
            guard let self = self else { return }
            self.lastPressure = pressure
            self.delegate?.pressureReader(self, didUpdatePressure: pressure)
        }
    }
    
    public func start() {
        bridge.start()
    }
    
    public func stop() {
        bridge.stop()
    }
    
    public func getSnapshot() -> Double {
        return lastPressure
    }
}
