import Foundation
import React

@objc(SimpleModule)
class SimpleModule: NSObject {

  @objc
  func testNativeMethod() {
    print("Simple native method called!")
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
