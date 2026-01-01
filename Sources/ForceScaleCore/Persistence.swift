import Foundation

public class Persistence {
    private static let folderName = ".forcescale"
    private static let fileName = "calibration.json"
    
    private static var storageURL: URL {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        return homeDirectory.appendingPathComponent(folderName).appendingPathComponent(fileName)
    }
    
    public static func saveProfile(_ profile: CalibrationProfile) throws {
        let folderURL = storageURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(profile)
        try data.write(to: storageURL)
    }
    
    public static func loadProfile() throws -> CalibrationProfile? {
        guard FileManager.default.fileExists(atPath: storageURL.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: storageURL)
        let decoder = JSONDecoder()
        return try decoder.decode(CalibrationProfile.self, from: data)
    }
    
    public static func deleteProfile() throws {
        if FileManager.default.fileExists(atPath: storageURL.path) {
            try FileManager.default.removeItem(at: storageURL)
        }
    }
}
