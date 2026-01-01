import Foundation

typealias MTDeviceCreateDefault = @convention(c) () -> UnsafeMutableRawPointer?
typealias MTDeviceStart = @convention(c) (UnsafeMutableRawPointer, Int32) -> Void
typealias MTDeviceStop = @convention(c) (UnsafeMutableRawPointer) -> Void
typealias MTRegisterContactCallback = @convention(c) (UnsafeMutableRawPointer, @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer, Int32, Double, Int32) -> Int32) -> Int32

struct MTPoint {
    var x: Float
    var y: Float
}

struct MTContact {
    var frame: Int32
    var timestamp: Double
    var identifier: Int32
    var state: Int32
    var fingerID: Int32
    var handID: Int32
    var normalized: MTPoint
    var position: MTPoint
    var pressure: Float
    var diameter: Float
    var angle: Float
    var active: Int32
}

public class MultitouchBridge {
    private var device: UnsafeMutableRawPointer?
    private static var instance: MultitouchBridge?
    
    private var _MTDeviceCreateDefault: MTDeviceCreateDefault?
    private var _MTDeviceStart: MTDeviceStart?
    private var _MTDeviceStop: MTDeviceStop?
    private var _MTRegisterContactCallback: MTRegisterContactCallback?
    
    public var pressureHandler: ((Double) -> Void)?
    
    public init() {
        MultitouchBridge.instance = self
        loadFunctions()
        device = _MTDeviceCreateDefault?()
        
        if let device = device {
            _ = _MTRegisterContactCallback?(device) { (_, contactsPtr, numContacts, _, _) -> Int32 in
                var totalPressure: Float = 0
                if numContacts > 0 {
                    let contacts = contactsPtr.assumingMemoryBound(to: MTContact.self)
                    for i in 0..<Int(numContacts) {
                        let contact = contacts.advanced(by: i).pointee
                        totalPressure += contact.pressure
                    }
                    MultitouchBridge.instance?.pressureHandler?(Double(totalPressure))
                } else {
                    MultitouchBridge.instance?.pressureHandler?(0.0)
                }
                return 0
            }
        }
    }
    
    private func loadFunctions() {
        let handle = dlopen("/System/Library/PrivateFrameworks/MultitouchSupport.framework/MultitouchSupport", RTLD_NOW)
        guard handle != nil else {
            return
        }
        
        if let sym = dlsym(handle, "MTDeviceCreateDefault") {
            _MTDeviceCreateDefault = unsafeBitCast(sym, to: MTDeviceCreateDefault.self)
        }
        if let sym = dlsym(handle, "MTDeviceStart") {
            _MTDeviceStart = unsafeBitCast(sym, to: MTDeviceStart.self)
        }
        if let sym = dlsym(handle, "MTDeviceStop") {
            _MTDeviceStop = unsafeBitCast(sym, to: MTDeviceStop.self)
        }
        if let sym = dlsym(handle, "MTRegisterContactCallback") {
            _MTRegisterContactCallback = unsafeBitCast(sym, to: MTRegisterContactCallback.self)
        }
    }
    
    public func start() {
        if let device = device {
            _MTDeviceStart?(device, 0)
        }
    }
    
    public func stop() {
        if let device = device {
            _MTDeviceStop?(device)
        }
    }
}
