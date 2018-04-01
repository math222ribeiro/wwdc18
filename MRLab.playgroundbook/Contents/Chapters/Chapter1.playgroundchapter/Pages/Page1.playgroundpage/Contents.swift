/*:
 **Challenge:** Create your own custom robot.
 
 Welcome to the MR Lab, this is Matheus' Laboratory, here he creates a lot of awesome stuff! Lately he has been working on some robots 🤖. Cool, right?
 
 Unfortunately he just left, but I'm here to show everything you need to create your own robot 😄.
 
 Let's get started. First on the LiveView you can see his awesome lab, the robot on the center is **blue Box Bot**, one of the creations of Matheus, and on the right, of course, it is me.
 
 On the live view you can:
 
 * callout(Live View):
 
     - Rotate the robot on the center (touching and dragging on the screen).
     - Change between cameras located on the lab, (bottom left button).
     - See all the robots created by Matheus, (bottom right button).
 
 To create a robot Matheus uses a robot Struct, and then configure every single part of the robot with Enums.
 
 The main enums are RobotName and RobotColor.
 * callout(Enums):
 
    - RobotName
      - boxBot
      - celBot
      - liamBot
      - macBot
      - voltBot
    - RobotColor
      - blue
      - red
      - yellow
 
 Here is the code he used to create this Box Bot, try to change it to create your own custom robot, you can chose any robot and any color! When you finish, run your code and see your brand new robot.
*/
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
  Simple user interface to interact with the playground.
 */
public typealias RobotName = RobotNode.Name
public typealias RobotColor = RobotNode.Color

public struct Robot {
  public var robotDictionary = [String: PlaygroundValue]()
  
  public init() {
    
  }
  
  public mutating func leg(fromRobot robot: RobotName, ofColor color: RobotColor) {
    robotDictionary[RobotNode.Part.leg.rawValue] = PlaygroundValue.string("\(robot);\(color)")
  }
  
  public mutating func leftArm(fromRobot robot: RobotName, ofColor color: RobotColor) {
    robotDictionary[RobotNode.Part.arm.rawValue + "\(RobotNode.Arm.left.rawValue)"] = PlaygroundValue.string("\(robot);\(color)")
  }
  
  public mutating func rightArm(fromRobot robot: RobotName, ofColor color: RobotColor) {
    robotDictionary[RobotNode.Part.arm.rawValue + "\(RobotNode.Arm.right.rawValue)"] = PlaygroundValue.string("\(robot);\(color)")
  }
  
  public mutating func body(fromRobot robot: RobotName, ofColor color: RobotColor) {
    robotDictionary[RobotNode.Part.body.rawValue] = PlaygroundValue.string("\(robot);\(color)")
  }
  
  public mutating func head(fromRobot robot: RobotName, ofColor color: RobotColor) {
    robotDictionary[RobotNode.Part.head.rawValue] = PlaygroundValue.string("\(robot);\(color)")
  }
}

func createRobot() {
  if !RobotsManager.shared.canCreateRobot { return }
  proxy.send(.dictionary(robot.robotDictionary))
}
//#-end-hidden-code
// Creating a robot variable from the Robot Struct
var robot = Robot()

// This was the code used to create the blue Box Bot you see on the screen. Try changing these values to create your own robot.
robot.head(
  fromRobot: /*#-editable-code*/.boxBot/*#-end-editable-code*/,
  ofColor: /*#-editable-code*/.blue/*#-end-editable-code*/
)
robot.body(
  fromRobot: /*#-editable-code*/.boxBot/*#-end-editable-code*/,
  ofColor: /*#-editable-code*/.blue/*#-end-editable-code*/
)
robot.leftArm(
  fromRobot: /*#-editable-code*/.boxBot/*#-end-editable-code*/,
  ofColor: /*#-editable-code*/.blue/*#-end-editable-code*/
)
robot.rightArm(
  fromRobot: /*#-editable-code*/.boxBot/*#-end-editable-code*/,
  ofColor: /*#-editable-code*/.blue/*#-end-editable-code*/
)
robot.leg(
  fromRobot: /*#-editable-code*/.boxBot/*#-end-editable-code*/,
  ofColor: /*#-editable-code*/.blue/*#-end-editable-code*/
)

// Creating your brand new robot
createRobot()
