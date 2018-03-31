//#-hidden-code
import PlaygroundSupport

class Listener: PlaygroundRemoteLiveViewProxyDelegate {
  var page: PlaygroundPage!
  
  func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {
    guard case let .dictionary(dict) = message else { return }
    if case let .string(hint)? = dict["fail"] {
      page.assessmentStatus = .fail(hints: [hint, hint], solution: nil)
    } else {
      page.assessmentStatus = .pass(message: "**Great** job!")
      page.finishExecution()
    }
  
  }
  
  func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
    
  }
}

let page = PlaygroundPage.current
let proxy = page.liveView as! PlaygroundRemoteLiveViewProxy
let listener = Listener()
listener.page = page
proxy.delegate = listener


/*
  User Interface to interact with the playground.
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

// Creating a robot Object
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
