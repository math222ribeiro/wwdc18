import PlaygroundSupport
import SceneKit

extension RobotLabViewController: PlaygroundLiveViewMessageHandler {
  public func receive(_ message: PlaygroundValue) {
    let legPart: (name: RobotNode.Name, color: RobotNode.Color)
    let dict: [String: PlaygroundValue]
    switch message {
    case let .dictionary(dictionary):
      guard case let .string(leg)? = dictionary[RobotNode.Part.leg.rawValue] else {
        return
      }
      dict = dictionary
      let config = leg.components(separatedBy: ";")
      
      switch config[0] {
      case RobotNode.Name.liamBot.rawValue:
        legPart.name = .liamBot
      default:
        fatalError("Error")
      }
      
      switch config[1] {
      case RobotNode.Color.blue.rawValue:
        legPart.color = .blue
      default:
        fatalError("Error")
      }
      
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
        robotNode.setHead(robotName: .celBot, robotColor: .red)
        robotNode.setLeg(robotName: legPart.name, robotColor: legPart.color)
        robotNode.setBody(robotName: .liamBot, robotColor: .yellow)
        robotNode.setLeftArm(robotName: .boxBot, robotColor: .yellow)
        robotNode.setRightArm(robotName: .boxBot, robotColor: .yellow)
        RobotsManager.shared.setRobotNodeOnScene(robotNode) {
          self.miniBot.playAnimation(.happy)
          self.isRobotRotationEnabled = true
          self.mainView.isHidden = false
          self.successSoundEffectPlayer.play()
        }
      })]))
    
    PlaygroundKeyValueStore.current["robot"] = .dictionary(dict)
  }
}
