//
//  RobotLabViewController+PlaygroundLiveViewMessageHandler.swift
//
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import PlaygroundSupport
import SceneKit

extension RobotLabViewController: PlaygroundLiveViewMessageHandler {
  public func receive(_ message: PlaygroundValue) {
    guard let robotNode = RobotsManager.shared.getRobotNode(fromPlaygroundMessage: message) else {
      var error = [String: PlaygroundValue]()
      error["fail"] = .boolean(true)
      send(.dictionary(error))
      return
    }
    
    isRobotRotationEnabled = false
    mainView.isHidden = true
    lowOpacityView.isHidden = true
    miniBotTimerAnimation.invalidate()
    
    rootRobotNode.runAction(SCNAction.sequence([
      // Makes the robot face the camera.
      SCNAction.rotateTo(x: 0, y: CGFloat(initialRobotRotationY), z: 0, duration: 0.3),
      SCNAction.run({ _ in
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
  }
}
