//
//  RobotNode.swift
//
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import SceneKit

public struct RobotNode {
  public var legNode: SCNNode
  public var bodyNode: SCNNode
  public var headNode: SCNNode
  public var armsNodes: [SCNNode?]
  
  public enum Part: String {
    case leg
    case arm
    case body
    case head
  }
  
  public enum Name: String {
    case boxBot
    case celBot
    case liamBot
    case voltBot
    case macBot
    static let all = [boxBot, celBot, liamBot, macBot, voltBot]
  }
  
  public enum Color: String {
    case red
    case yellow
    case blue
  }
  
  public enum Arm: Int {
    case left = 0
    case right
  }
  
  public init(legNode: SCNNode = SCNNode(), bodyNode: SCNNode = SCNNode(), headNode: SCNNode = SCNNode(), armsNodes: [SCNNode?] = [SCNNode?](repeating: nil, count: 2)) {
    self.legNode = legNode
    self.bodyNode = bodyNode
    self.headNode = headNode
    self.armsNodes = armsNodes
  }
  
  public mutating func setLeg(robotName: Name, robotColor: Color) {
    legNode = RobotsManager.shared.getRobotPartNode(.leg, robotName: robotName, robotColor: robotColor)
  }
  
  public mutating func setLeftArm(robotName: Name, robotColor: Color) {
    armsNodes[Arm.left.rawValue] = RobotsManager.shared.getRobotPartNode(.arm, robotName: robotName, robotColor: robotColor)
  }
  
  public mutating func setRightArm(robotName: Name, robotColor: Color) {
    armsNodes[Arm.right.rawValue] = RobotsManager.shared.getRobotPartNode(.arm, robotName: robotName, robotColor: robotColor)
  }
  
  public mutating func setBody(robotName: Name, robotColor: Color) {
    bodyNode = RobotsManager.shared.getRobotPartNode(.body, robotName: robotName, robotColor: robotColor)
  }
  
  public mutating func setHead(robotName: Name, robotColor: Color) {
    headNode = RobotsManager.shared.getRobotPartNode(.head, robotName: robotName, robotColor: robotColor)
  }
}
