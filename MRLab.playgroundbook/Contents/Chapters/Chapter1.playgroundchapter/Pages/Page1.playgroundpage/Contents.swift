import PlaygroundSupport

let page = PlaygroundPage.current

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
    robotDictionary[RobotNode.Part.arm.rawValue + "Left"] = PlaygroundValue.string("\(robot);\(color)")
  }
  
  public mutating func setRightArm(fromRobot robot: RobotName, ofColor color: RobotColor) {
    robotDictionary[RobotNode.Part.arm.rawValue + "Right"] = PlaygroundValue.string("\(robot);\(color)")
  }
  
  public mutating func setBody(fromRobot robot: RobotName, ofColor color: RobotColor) {
    robotDictionary[RobotNode.Part.body.rawValue] = PlaygroundValue.string("\(robot);\(color)")
  }
  
  public mutating func setHead(fromRobot robot: RobotName, ofColor color: RobotColor) {
    robotDictionary[RobotNode.Part.head.rawValue] = PlaygroundValue.string("\(robot);\(color)")
  }
}

func createRobot() {
  if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
    proxy.send(.dictionary(robot.robotDictionary))
  }
}

var robot = Robot()
robot.setHead(fromRobot: .boxBot, ofColor: .blue)
robot.setBody(fromRobot: .boxBot, ofColor: .blue)
robot.setLeftArm(fromRobot: .boxBot, ofColor: .blue)
robot.setRightArm(fromRobot: .boxBot, ofColor: .blue)
robot.setLeg(fromRobot: .boxBot, ofColor: .blue)
createRobot()
