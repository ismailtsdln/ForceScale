import Foundation
import ArgumentParser
import ForceScaleCore

@main
struct ForceScale: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "forcescale",
        abstract: "Force Touch-Based Weight Estimation Tool",
        subcommands: [Calibrate.self, Measure.self, Tare.self, Export.self],
        defaultSubcommand: Measure.self
    )
}

struct Calibrate: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Add a calibration point with a known weight.")
    
    @Option(name: .shortAndLong, help: "Known weight in grams.")
    var weight: Double
    
    func run() throws {
        print("Calibrating with \(weight)g...")
        let reader = PressureReader()
        reader.start()
        
        print("Place the \(weight)g object on the trackpad and press Enter.")
        _ = readLine()
        
        let pressure = reader.getSnapshot()
        reader.stop()
        
        print("Captured pressure: \(pressure)")
        
        let profile = try Persistence.loadProfile() ?? CalibrationProfile(deviceIdentifier: "Default")
        let engine = CalibrationEngine(profile: profile)
        engine.addPoint(grams: weight, pressure: pressure)
        
        try Persistence.saveProfile(engine.profile)
        print("Calibration point saved.")
        
        if let regression = engine.calculateRegression() {
            print("Current Calibration: Slope=\(regression.slope), Intercept=\(regression.intercept)")
        }
    }
}

struct Measure: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Estimate weight of an object on the trackpad.")
    
    @Flag(name: .shortAndLong, help: "Enable live updates.")
    var live: Bool = false
    
    private static var activeDelegate: MeasurementDelegate?
    
    func run() throws {
        guard let profile = try Persistence.loadProfile(),
              let engine = CalibrationEngine(profile: profile).calculateRegression() else {
            print("Error: Device not calibrated. Please run 'forcescale calibrate --weight <grams>' first.")
            return
        }
        
        let estimator = WeightEstimator(slope: engine.slope, intercept: engine.intercept)
        let reader = PressureReader()
        
        if live {
            print("Live measurement (Press Ctrl+C to stop)...")
            let delegate = MeasurementDelegate(estimator: estimator)
            Measure.activeDelegate = delegate
            reader.delegate = delegate
            reader.start()
            RunLoop.main.run()
        } else {
            reader.start()
            Thread.sleep(forTimeInterval: 0.5) // Allow sensor to stabilize
            let pressure = reader.getSnapshot()
            let weight = estimator.estimateWeight(pressure: pressure)
            print(String(format: "Estimated Weight: %.2fg", weight))
            reader.stop()
        }
    }
}

class MeasurementDelegate: PressureReaderDelegate {
    let estimator: WeightEstimator
    
    init(estimator: WeightEstimator) {
        self.estimator = estimator
    }
    
    func pressureReader(_ reader: PressureReader, didUpdatePressure pressure: Double) {
        let weight = estimator.estimateWeight(pressure: pressure)
        print(String(format: "\rEstimated Weight: %.2fg", weight), terminator: "")
        fflush(stdout)
    }
}

struct Tare: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Zero the scale with current weight.")
    
    func run() throws {
        print("Taring scale...")
        print("Tare not fully implemented for transient CLI yet. Use in UI for best results.")
    }
}

struct Export: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Export calibration data.")
    
    @Option(name: .shortAndLong, help: "Output format (json).")
    var format: String = "json"
    
    func run() throws {
        if let profile = try Persistence.loadProfile() {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(profile)
            if let json = String(data: data, encoding: .utf8) {
                print(json)
            }
        } else {
            print("No profile found.")
        }
    }
}
