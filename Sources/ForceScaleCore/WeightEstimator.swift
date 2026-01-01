import Foundation

public class WeightEstimator {
    private var slope: Double = 0.0
    private var intercept: Double = 0.0
    private var tareOffset: Double = 0.0
    
    public init(slope: Double = 0.0, intercept: Double = 0.0) {
        self.slope = slope
        self.intercept = intercept
    }
    
    public func updateCalibration(slope: Double, intercept: Double) {
        self.slope = slope
        self.intercept = intercept
    }
    
    public func tare(currentPressure: Double) {
        tareOffset = (currentPressure * slope) + intercept
    }
    
    public func resetTare() {
        tareOffset = 0.0
    }
    
    public func estimateWeight(pressure: Double) -> Double {
        let rawWeight = (pressure * slope) + intercept
        return max(0, rawWeight - tareOffset)
    }
}
