//#-hidden-code
import PlaygroundSupport

class LiveViewMessageListener: PlaygroundRemoteLiveViewProxyDelegate {
  var page: PlaygroundPage!
  
  func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {
    guard case let .dictionary(dict) = message else { return }
    
    if case let .boolean(fail)? = dict["fail"] {
      if fail {
        page.assessmentStatus = .fail(hints: [Messages.main.rawValue, Messages.customization.rawValue], solution: Messages.example.rawValue)
      } else {
        page.assessmentStatus = .pass(message: Messages.pass.rawValue)
        page.finishExecution()
      }
    }
  }
  
  func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
    
  }
}


public enum Messages: String {
  case main = "Try changing everything on your new robot."
  case customization = """
Your robot needs to be completely different from blue Box Bot.
  **Initial configuration is not allowed:**
- callout(Example):
  `robot.setHead(fromRobot: .boxBot, ofColor: .blue)`
"""
  case example = """
  `robot.setHead(fromRobot: .boxBot, ofColor: .yellow)
  robot.setBody(fromRobot: .liamBot, ofColor: .blue)
  robot.setLeftArm(fromRobot: .macBot, ofColor: .blue)
  robot.setRightArm(fromRobot: .macBot, ofColor: .blue)
  robot.setLeg(fromRobot: .boxBot, ofColor: .yellow)`
"""
  case pass = """
  ## Nice! That is a good looking robot!
  Now you have your own robot, congratulations. It is time to give life to it.
  [Next Page](@next)
"""
}

let page = PlaygroundPage.current
page.needsIndefiniteExecution = true

let proxy = page.liveView as! PlaygroundRemoteLiveViewProxy
let listener = LiveViewMessageListener()
listener.page = page
proxy.delegate = listener


/*
  User interface to interact with the playground.
 */
public typealias RobotName = RobotNode.Name
public typealias RobotColor = RobotNode.Color

public struct Robot {
  public var robotDictionary = [String: PlaygroundValue]()
  
  public init() {
    
  }
  
  public mutating func setLeg(fromRobot robot: RobotName, ofColor color: RobotColor) {
    robotDictionary[RobotNode.Part.leg.rawValue] = PlaygroundValue.string("\(robot);\(color)")
  }
  
  public mutating func setLeftArm(fromRobot robot: RobotName, ofColor color: RobotColor) {
    robotDictionary[RobotNode.Part.arm.rawValue + "\(RobotNode.Arm.left.rawValue)"] = PlaygroundValue.string("\(robot);\(color)")
  }
  
  public mutating func setRightArm(fromRobot robot: RobotName, ofColor color: RobotColor) {
    robotDictionary[RobotNode.Part.arm.rawValue + "\(RobotNode.Arm.right.rawValue)"] = PlaygroundValue.string("\(robot);\(color)")
  }
  
  public mutating func setBody(fromRobot robot: RobotName, ofColor color: RobotColor) {
    robotDictionary[RobotNode.Part.body.rawValue] = PlaygroundValue.string("\(robot);\(color)")
  }
  
  public mutating func setHead(fromRobot robot: RobotName, ofColor color: RobotColor) {
    robotDictionary[RobotNode.Part.head.rawValue] = PlaygroundValue.string("\(robot);\(color)")
  }
}

func createRobot() {
  if !RobotsManager.shared.canCreateRobot { return }
  proxy.send(.dictionary(robot.robotDictionary))
}
//#-end-hidden-code

// Creating a robot variable
var robot = Robot()

// This was the code used to create the blue Box Bot you see on the screen. Try changing these values to create your own robot.
robot.setHead(
  fromRobot: /*#-editable-code*/.boxBot/*#-end-editable-code*/,
  ofColor: /*#-editable-code*/.blue/*#-end-editable-code*/
)
robot.setBody(
  fromRobot: /*#-editable-code*/.boxBot/*#-end-editable-code*/,
  ofColor: /*#-editable-code*/.blue/*#-end-editable-code*/
)
robot.setLeftArm(
  fromRobot: /*#-editable-code*/.boxBot/*#-end-editable-code*/,
  ofColor: /*#-editable-code*/.blue/*#-end-editable-code*/
)
robot.setRightArm(
  fromRobot: /*#-editable-code*/.boxBot/*#-end-editable-code*/,
  ofColor: /*#-editable-code*/.blue/*#-end-editable-code*/
)
robot.setLeg(
  fromRobot: /*#-editable-code*/.boxBot/*#-end-editable-code*/,
  ofColor: /*#-editable-code*/.blue/*#-end-editable-code*/
)

// Creating your brand new robot
createRobot()
