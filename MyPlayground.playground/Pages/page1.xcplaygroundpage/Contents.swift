//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import SceneKit

// Present the view controller in the Live View window
let controller = RobotLabViewController()
controller.preferredContentSize = CGSize(width: 600, height: 600)
PlaygroundPage.current.liveView = controller
