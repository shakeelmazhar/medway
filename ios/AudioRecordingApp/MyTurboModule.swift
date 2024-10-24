import Foundation
import React

@objc(MyTurboModule)
class MyTurboModule: NSObject, RCTTurboModule {
    
    static func moduleName() -> String {
        return "MyTurboModule"
    }
    
    @objc
    func add(a: Double, b: Double, callback: @escaping RCTResponseSenderBlock) {
        let result = a + b
        callback([NSNull(), result])
    }
}

@objc(MyTurboModule)
class MyTurboModule: RCTTurboModule {
    static func moduleName() -> String {
        return "MyTurboModule"
    }
}
