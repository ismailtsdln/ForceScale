import Foundation

public struct CalibrationPoint: Codable {
    public let grams: Double
    public let pressure: Double
    
    public init(grams: Double, pressure: Double) {
        self.grams = grams
        self.pressure = pressure
    }
}

public struct CalibrationProfile: Codable {
    public let deviceIdentifier: String
    public var points: [CalibrationPoint]
    
    public init(deviceIdentifier: String, points: [CalibrationPoint] = []) {
        self.deviceIdentifier = deviceIdentifier
        self.points = points
    }
}

public class CalibrationEngine {
    public private(set) var profile: CalibrationProfile
    
    public init(profile: CalibrationProfile) {
        self.profile = profile
    }
    
    public func addPoint(grams: Double, pressure: Double) {
        profile.points.append(CalibrationPoint(grams: grams, pressure: pressure))
    }
    
    public func clearPoints() {
        profile.points.removeAll()
    }
    
    public func calculateRegression() -> (slope: Double, intercept: Double)? {
        let n = Double(profile.points.count)
        guard n >= 2 else { return nil }
        
        var sumX = 0.0
        var sumY = 0.0
        var sumXY = 0.0
        var sumX2 = 0.0
        
        for point in profile.points {
            sumX += point.pressure
            sumY += point.grams
            sumXY += point.pressure * point.grams
            sumX2 += point.pressure * point.pressure
        }
        
        let denominator = n * sumX2 - sumX * sumX
        if denominator == 0 { return nil }
        
        let slope = (n * sumXY - sumX * sumY) / denominator
        let intercept = (sumY - slope * sumX) / n
        
        return (slope, intercept)
    }
}
