import PlaygroundSupport
import SceneKit

extension RobotLabViewController: PlaygroundLiveViewMessageHandler {
  public func receive(_ message: PlaygroundValue) {
    let robotDictionary: [String: PlaygroundValue]
    
    let robotHead: (name: RobotNode.Name, color: RobotNode.Color)
    let robotBody: (name: RobotNode.Name, color: RobotNode.Color)
    let robotArmLeft: (name: RobotNode.Name, color: RobotNode.Color)
    let robotArmRight: (name: RobotNode.Name, color: RobotNode.Color)
    let robotLeg: (name: RobotNode.Name, color: RobotNode.Color)
    
    switch message {
    case let .dictionary(dictionary):
      guard case let .string(head)? = dictionary[RobotNode.Part.head.rawValue],
            case let .string(body)? = dictionary[RobotNode.Part.body.rawValue],
            case let .string(armLeft)? = dictionary[RobotNode.Part.arm.rawValue + "\(RobotNode.Arm.left.rawValue)"],
            case let .string(armRight)? = dictionary[RobotNode.Part.arm.rawValue + "\(RobotNode.Arm.right.rawValue)"],
            case let .string(leg)? = dictionary[RobotNode.Part.leg.rawValue]
      else {
        fatalError("Error on the dictionary")
      }
      
      // Save the dictionary value to store on PlaygroundKeyValueStore later.
      robotDictionary = dictionary
      
      guard let headConfig = parseRobotConfig(head), let bodyConfig = parseRobotConfig(body), let armLeftConfig = parseRobotConfig(armLeft),
        let armRightConfig = parseRobotConfig(armRight), let legConfig = parseRobotConfig(leg) else {
          var error = [String: PlaygroundValue]()
          error["fail"] = .boolean(true)
          send(.dictionary(error))
          return
      }
      
      robotHead = headConfig
      robotBody = bodyConfig
      robotArmLeft = armLeftConfig
      robotArmRight = armRightConfig
      robotLeg = legConfig
      
    default:
      fatalError("NO DICTIONARY")
    }
    
    isRobotRotationEnabled = false
    mainView.isHidden = true
    lowOpacityView.isHidden = true
    miniBotTimerAnimation.invalidate()
    
    rootRobotNode.runAction(SCNAction.sequence([
      // Makes the robot face the camera.
      SCNAction.rotateTo(x: 0, y: CGFloat(initialRobotRotationY), z: 0, duration: 0.3),
      SCNAction.run({ _ in
        var robotNode = RobotNode()
        robotNode.setHead(robotName: robotHead.name, robotColor: robotHead.color)
        robotNode.setLeg(robotName: robotLeg.name, robotColor: robotLeg.color)
        robotNode.setBody(robotName: robotBody.name, robotColor: robotBody.color)
        robotNode.setLeftArm(robotName: robotArmLeft.name, robotColor: robotArmLeft.color)
        robotNode.setRightArm(robotName: robotArmRight.name, robotColor: robotArmRight.color)
        RobotsManager.shared.setRobotNodeOnScene(robotNode) {
          self.miniBot.playAnimation(.happy)
          self.isRobotRotationEnabled = true
          self.mainView.isHidden = false
          self.successSoundEffectPlayer.play()
          var error = [String: PlaygroundValue]()
          error["fail"] = .boolean(false)
          self.send(.dictionary(error))
        }
      })]))
    
    PlaygroundKeyValueStore.current["robot"] = .dictionary(robotDictionary)
  }
  
  public func parseRobotConfig(_ config: String) -> (name: RobotNode.Name, color: RobotNode.Color)? {
    let components = config.components(separatedBy: ";")
    
    if components.count != 2 {
      fatalError("Robot weird size")
    }
    
    let name: RobotNode.Name
    let color: RobotNode.Color
    
    switch components[0] {
    case RobotNode.Name.boxBot.rawValue:
      name = .boxBot
    case RobotNode.Name.celBot.rawValue:
      name = .celBot
    case RobotNode.Name.macBot.rawValue:
      name = .macBot
    case RobotNode.Name.liamBot.rawValue:
      name = .liamBot
    case RobotNode.Name.voltBot.rawValue:
      name = .voltBot
    default:
      fatalError("NAME WHAT?")
    }
    
    switch components[1] {
    case RobotNode.Color.blue.rawValue:
      color = .blue
    case RobotNode.Color.yellow.rawValue:
      color = .yellow
    case RobotNode.Color.red.rawValue:
      color = .red
    default:
      fatalError("NAME WHAT?")
    }
    
    if name == .boxBot && color == .blue {
      return nil
    }
    return (name, color)
  }

}
