import SwiftUI
import ForceScaleCore
import Combine

class MeasureViewModel: ObservableObject, PressureReaderDelegate {
    @Published var currentWeight: Double = 0.0
    @Published var currentPressure: Double = 0.0
    @Published var isStable: Bool = true
    @Published var isCalibrated: Bool = false
    @Published var calibrationError: String?
    
    private let reader = PressureReader()
    private var estimator: WeightEstimator?
    private var profile: CalibrationProfile?
    
    // Smoothing & Stability
    private var pressureHistory: [Double] = []
    private let smoothingWindow = 10
    private let stabilityThreshold = 0.05 // Grams variance
    
    init() {
        reader.delegate = self
        loadCalibration()
    }
    
    func loadCalibration() {
        do {
            if let profile = try Persistence.loadProfile(),
               let engine = CalibrationEngine(profile: profile).calculateRegression() {
                self.profile = profile
                self.estimator = WeightEstimator(slope: engine.slope, intercept: engine.intercept)
                self.isCalibrated = true
                self.calibrationError = nil
            } else {
                self.isCalibrated = false
                self.calibrationError = "Not calibrated"
            }
        } catch {
            self.calibrationError = "Error loading calibration: \(error.localizedDescription)"
        }
    }
    
    func start() {
        reader.start()
    }
    
    func stop() {
        reader.stop()
    }
    
    func tare() {
        estimator?.tare(currentPressure: reader.getSnapshot())
    }
    
    func resetTare() {
        estimator?.resetTare()
    }
    
    // MARK: - PressureReaderDelegate
    
    func pressureReader(_ reader: PressureReader, didUpdatePressure pressure: Double) {
        DispatchQueue.main.async {
            self.currentPressure = pressure
            let weight = self.estimator?.estimateWeight(pressure: pressure) ?? 0.0
            
            // Apply smoothing
            self.pressureHistory.append(weight)
            if self.pressureHistory.count > self.smoothingWindow {
                self.pressureHistory.removeFirst()
            }
            
            let smoothWeight = self.pressureHistory.reduce(0, +) / Double(self.pressureHistory.count)
            self.currentWeight = smoothWeight
            
            // Check stability
            if self.pressureHistory.count == self.smoothingWindow {
                let mean = smoothWeight
                let variance = self.pressureHistory.map { pow($0 - mean, 2) }.reduce(0, +) / Double(self.smoothingWindow)
                let stdDev = sqrt(variance)
                self.isStable = stdDev < self.stabilityThreshold
            } else {
                self.isStable = false
            }
        }
    }
}
