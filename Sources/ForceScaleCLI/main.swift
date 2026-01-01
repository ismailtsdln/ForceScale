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
        guard MultitouchBridge.isAvailable else {
            print("Error: Force Touch sensor not found on this device.")
            return
        }
        
        print("Calibrating with \(weight)g...")
        let reader = PressureReader()
        reader.start()
        
        print("Place the \(weight)g object on the trackpad and press Enter.")
        _ = readLine()
        
        let pressure = reader.getSnapshot()
        reader.stop()
        
        print("Captured pressure: \(String(format: "%.4f", pressure))")
        
        let profile = try Persistence.loadProfile() ?? CalibrationProfile(deviceIdentifier: "Default")
        let engine = CalibrationEngine(profile: profile)
        engine.addPoint(grams: weight, pressure: pressure)
        
        try Persistence.saveProfile(engine.profile)
        print("Calibration point saved.")
        
        if let regression = engine.calculateRegression() {
            print("Current Calibration: Slope=\(String(format: "%.2f", regression.slope)), Intercept=\(String(format: "%.2f", regression.intercept))")
        }
    }
}

struct Measure: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Estimate weight of an object on the trackpad.")
    
    @Flag(name: .shortAndLong, help: "Enable live updates.")
    var live: Bool = false
    
    private static var activeReader: PressureReader?
    private static var activeDelegate: MeasurementDelegate?
    
    func run() throws {
        guard MultitouchBridge.isAvailable else {
            print("Error: Force Touch sensor not found.")
            return
        }
        
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
            Measure.activeReader = reader
            Measure.activeDelegate = delegate
            reader.delegate = delegate
            reader.start()
            
            // Set up signal handler for clean exit
            signal(SIGINT) { _ in
                print("\nStopping...")
                Measure.activeReader?.stop()
                Darwin.exit(0)
            }
            
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
        
        // Simple ASCII bar for pressure
        let barLength = 20
        let filled = Int(min(pressure, 1.0) * Double(barLength))
        let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: barLength - filled)
        
        // Use ANSI to clear line and return to start
        print("\r\u{1B}[K", terminator: "") 
        print(String(format: "Weight: %.2fg | [%@] P:%.3f", weight, bar, pressure), terminator: "")
        fflush(stdout)
    }
}

struct Tare: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Zero the scale with current weight.")
    
    func run() throws {
        print("Tare is best handled in the UI app or during live 'measure' sessions.")
        print("Headless tare state is not currently persisted between CLI calls.")
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
