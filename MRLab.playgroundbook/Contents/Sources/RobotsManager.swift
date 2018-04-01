//
//  RobotsManager.swift
//
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import SceneKit
import PlaygroundSupport

// Singleton that handles the robot change on the scene.
public class RobotsManager {
  
  /// Singleton instance.
  public static let shared = RobotsManager()
  
  /// Node from the main scene that holds all robot parts nodes.
  public var rootRobotNode: SCNNode!
  
  /// All parts of the current robot on the scene.
  public var currentRobot: RobotNode!
  
  /// Delegate for animating the camera on robot change.
  public var cameraDelegate: CameraAnimationDelegate!
  
  public var canCreateRobot = true
  
  /// Sets the rootRobotNode and cameraDelegate,
  /// gets the current robot from the root node and sets it on currentRobot.
  public func configure(rootRobotNode: SCNNode, cameraDelegate: CameraAnimationDelegate?) {
    self.rootRobotNode = rootRobotNode
    let legNode = rootRobotNode.childNode(named: "leg")
    let leftArmNode = rootRobotNode.childNode(named: "arm_left")
    let rightArmNode = rootRobotNode.childNode(named: "arm_right")
    let bodyNode = rootRobotNode.childNode(named: "body")
    let headNode = rootRobotNode.childNode(named: "head")
    currentRobot = RobotNode(legNode: legNode, bodyNode: bodyNode, headNode: headNode, armsNodes: [leftArmNode, rightArmNode])
    if let delegate = cameraDelegate {
      self.cameraDelegate = delegate
    }
  }
  
  // MARK: Helper Methods
  
  public func customNodeCopy(_ nodeA: SCNNode, _ nodeB: SCNNode) {
    nodeA.position = nodeB.position
    nodeA.eulerAngles = nodeB.eulerAngles
    nodeA.name = nodeB.name!
  }
  
  /// Gets the robot part from scene with especific color
  public func getRobotPartNode(_ robotPart: RobotNode.Part, robotName: RobotNode.Name,  robotColor: RobotNode.Color) -> SCNNode {
    let capitalizedName = robotName.rawValue.firstLetterCapitalized()
    let capitalizedPart = robotPart.rawValue.firstLetterCapitalized()
    let partNode = Assets.getScene(named: "\(capitalizedName)/\(capitalizedName)_\(capitalizedPart).scn").rootNode.childNode(named: robotPart.rawValue)
    
    let diffuse = UIImage(named: "\(Assets.path)/RobotColors/\(robotColor.rawValue).png")
    
    // Liam body has two nodes the node to paint is the box node
    if robotPart == .body && robotName == .liamBot {
      partNode.childNode(named: "box").geometry?.materials.first?.diffuse.contents = diffuse
    } else {
      partNode.geometry?.materials.first?.diffuse.contents = diffuse
    }
    
    return partNode
  }
}

//////////////////////////////////
//
// MARK: Robot Change Methods
//
//////////////////////////////////
public extension RobotsManager {
  public func setRobotNodeOnScene(_ robotNode: RobotNode, completion: (() -> ())?) {
    if !canCreateRobot { return } else { canCreateRobot = false }
  
    // Copy the transform and name.
    customNodeCopy(robotNode.legNode, currentRobot.legNode)
    customNodeCopy(robotNode.bodyNode, currentRobot.bodyNode)
    customNodeCopy(robotNode.headNode, currentRobot.headNode)
    customNodeCopy(robotNode.armsNodes[0]!, currentRobot.armsNodes[0]!)
    customNodeCopy(robotNode.armsNodes[1]!, currentRobot.armsNodes[1]!)
    
    // Robot change animation, SCNAction chain.
    changeHead(currentRobot.headNode, to: robotNode.headNode) {
      self.changeBody(self.currentRobot.bodyNode, to: robotNode.bodyNode) {
        self.changeArms(self.currentRobot.armsNodes as! [SCNNode], to: robotNode.armsNodes as! [SCNNode]) {
          self.changeLegs(self.currentRobot.legNode, to: robotNode.legNode, completion: {
            // If nil is passed the camera is animated to the full robot position
            self.cameraDelegate.animateCameraToRobotPart(nil, completion: completion)
            self.currentRobot = robotNode
            self.canCreateRobot = true
          })
        }
      }
    }
  }
  
  public func changeHead(_ oldHead: SCNNode, to newHead: SCNNode, completion: (() -> ())?) {
    let rotateHead = SCNAction.rotateBy(x: 0, y: CGFloat(convertToRadians(angle: 1080)), z: 0, duration: 1.5)
    let rotateNewHead = SCNAction.rotateBy(x: 0, y: CGFloat(convertToRadians(angle: 360)), z: 0, duration: 0.5)
    let changeHead = SCNAction.run { (_) in
      oldHead.removeFromParentNode()
      self.rootRobotNode.addChildNode(newHead)
      newHead.runAction(SCNAction.sequence([rotateNewHead, SCNAction.run({ (_) in
        completion?()
      })]))
    }
    
    cameraDelegate.animateCameraToRobotPart(.head) {
      oldHead.runAction(SCNAction.sequence([rotateHead, changeHead]))
    }
  }
  
  public func changeBody(_ oldBody: SCNNode, to newBody: SCNNode, completion: (() -> ())?) {
    let scaleOldBody = SCNAction.scale(to: 0, duration: 1)
    let fadeInNewBody = SCNAction.fadeIn(duration: 0.2)
    let changeBody = SCNAction.run { (_) in
      newBody.opacity = 0
      oldBody.removeFromParentNode()
      self.rootRobotNode.addChildNode(newBody)
      newBody.runAction(SCNAction.sequence([fadeInNewBody, SCNAction.run({ (_) in
        completion?()
      })]))
    }
    
    cameraDelegate.animateCameraToRobotPart(.body, completion: {
      oldBody.runAction(SCNAction.sequence([scaleOldBody, changeBody]))
    })
  }
  
  public func changeArms(_ oldArms: [SCNNode], to newArms: [SCNNode], completion: (() -> ())?) {
    let moveLeftArm = SCNAction.sequence([
      SCNAction.moveBy(x: 0.5, y: 0, z: 0, duration: 1),
      SCNAction.moveBy(x: 5, y: 0, z: 0, duration: 0.5)
      ])
    
    let moveRightArm = SCNAction.sequence([
      SCNAction.moveBy(x: -0.5, y: 0, z: 0, duration: 1),
      SCNAction.moveBy(x: -5, y: 0, z: 0, duration: 0.5)
      ])
    
    let moveOldArms = SCNAction.sequence([
      SCNAction.run({ _ in oldArms[0].runAction(moveLeftArm); oldArms[1].runAction(moveRightArm)}),
      SCNAction.wait(duration: 1.8)
      ])
    
    let moveNewArms = SCNAction.sequence([
      SCNAction.run({ _ in newArms[0].runAction(moveLeftArm.reversed()); newArms[1].runAction(moveRightArm.reversed())}),
      SCNAction.wait(duration: 1.8)
      ])
    
    let changeArm = SCNAction.run { (_) in
      oldArms[0].removeFromParentNode()
      oldArms[1].removeFromParentNode()
      newArms[0].position.x = newArms[0].position.x + 5.5
      newArms[1].position.x = newArms[1].position.x - 5.5
      self.rootRobotNode.addChildNode(newArms[0])
      self.rootRobotNode.addChildNode(newArms[1])
      self.rootRobotNode.runAction(SCNAction.sequence([moveNewArms, SCNAction.run({ _ in
        completion?()
      })]))
    }

    cameraDelegate.animateCameraToRobotPart(.arm) {
      self.rootRobotNode.runAction(SCNAction.sequence([moveOldArms, changeArm]))
    }
  }
  
  public func changeLegs(_ oldLegs: SCNNode, to newLegs: SCNNode, completion: (() -> ())?) {
    let blinkOldLeg = SCNAction.repeat(
      SCNAction.sequence([SCNAction.fadeOut(duration: 0.2), SCNAction.fadeIn(duration: 0.2)]),
      count: 4
    )
    
    let rotateNewLeg = SCNAction.rotateBy(x: 0, y: CGFloat(convertToRadians(angle: 360)), z: 0, duration: 0.2)
    
    let changeLeg = SCNAction.run { (_) in
      oldLegs.removeFromParentNode()
      self.rootRobotNode.addChildNode(newLegs)
      newLegs.runAction(SCNAction.sequence([rotateNewLeg, SCNAction.run({ _ in
        completion?()
      })]))
    }
    
    cameraDelegate.animateCameraToRobotPart(.leg) {
      oldLegs.runAction(SCNAction.sequence([blinkOldLeg, changeLeg]))
    }
  }
  
  /// Converts a robot part config from a string to the correct types
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
      fatalError("Invalid string.")
    }
    
    switch components[1] {
    case RobotNode.Color.blue.rawValue:
      color = .blue
    case RobotNode.Color.yellow.rawValue:
      color = .yellow
    case RobotNode.Color.red.rawValue:
      color = .red
    default:
      fatalError("Invalid string.")
    }
    
    // Checks if the user has customized the robot.
    if name == .boxBot && color == .blue {
      return nil
    }
    
    return (name, color)
  }
  
  public func getRobotNode(fromPlaygroundMessage value: PlaygroundValue?) -> RobotNode? {
    guard let message = value else { return nil }
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
          fatalError("Error on the dictionary.")
      }
      
      guard let headConfig = parseRobotConfig(head), let bodyConfig = parseRobotConfig(body), let armLeftConfig = parseRobotConfig(armLeft),
        let armRightConfig = parseRobotConfig(armRight), let legConfig = parseRobotConfig(leg) else {
          return nil
      }
      
      // Save the robot config for the next page.
      PlaygroundKeyValueStore.current["robot"] = .dictionary(dictionary)
      
      robotHead = headConfig
      robotBody = bodyConfig
      robotArmLeft = armLeftConfig
      robotArmRight = armRightConfig
      robotLeg = legConfig
      
    default:
      fatalError("No dictionary")
    }
    
    var robotNode = RobotNode()
    robotNode.setHead(robotName: robotHead.name, robotColor: robotHead.color)
    robotNode.setLeg(robotName: robotLeg.name, robotColor: robotLeg.color)
    robotNode.setBody(robotName: robotBody.name, robotColor: robotBody.color)
    robotNode.setLeftArm(robotName: robotArmLeft.name, robotColor: robotArmLeft.color)
    robotNode.setRightArm(robotName: robotArmRight.name, robotColor: robotArmRight.color)
    return robotNode
  }
  
  public func setRobot(_ robotNode: RobotNode) {
    customNodeCopy(robotNode.legNode, currentRobot.legNode)
    customNodeCopy(robotNode.bodyNode, currentRobot.bodyNode)
    customNodeCopy(robotNode.headNode, currentRobot.headNode)
    customNodeCopy(robotNode.armsNodes[0]!, currentRobot.armsNodes[0]!)
    customNodeCopy(robotNode.armsNodes[1]!, currentRobot.armsNodes[1]!)
    
    currentRobot.headNode.removeFromParentNode()
    currentRobot.bodyNode.removeFromParentNode()
    currentRobot.legNode.removeFromParentNode()
    currentRobot.armsNodes[0]!.removeFromParentNode()
    currentRobot.armsNodes[1]!.removeFromParentNode()
    
    rootRobotNode.addChildNode(robotNode.headNode)
    rootRobotNode.addChildNode(robotNode.bodyNode)
    rootRobotNode.addChildNode(robotNode.legNode)
    rootRobotNode.addChildNode(robotNode.armsNodes[0]!)
    rootRobotNode.addChildNode(robotNode.armsNodes[1]!)
    
    currentRobot = robotNode
  }
}
