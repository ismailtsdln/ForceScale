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
            self.currentWeight = self.estimator?.estimateWeight(pressure: pressure) ?? 0.0
        }
    }
}
