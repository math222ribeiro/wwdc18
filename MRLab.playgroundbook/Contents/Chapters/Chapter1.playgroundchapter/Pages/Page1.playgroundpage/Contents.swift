//#-hidden-code
import PlaygroundSupport

let page = PlaygroundPage.current

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
  if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
    proxy.send(.dictionary(robot.robotDictionary))
  }
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
