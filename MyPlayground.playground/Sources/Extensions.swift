//
//  Extensions.swift
//
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import SceneKit

public func convertToRadians(angle: Float) -> Float {
  let degreesPerRadians = Float(Double.pi / 180)
  return angle * degreesPerRadians
}

public extension SCNNode {
  public func childNode(named name: String) -> SCNNode {
    guard let child = self.childNode(withName: name, recursively: true) else { fatalError("Child node name \(name) not found on parent node \(self.name ?? "NO NAME").") }
    return child
  }
}

public extension String  {
  public func firstLetterCapitalized() -> String {
    return self.prefix(1).uppercased() + self.dropFirst()
  }
}

extension SCNAnimationPlayer {
  public class func loadAnimation(fromScene scene: SCNScene) -> SCNAnimationPlayer {
    var animationPlayer: SCNAnimationPlayer! = nil
    
    scene.rootNode.enumerateChildNodes { (child, stop) in
      if !child.animationKeys.isEmpty {
        animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
        stop.pointee = true
      }
    }
    
    return animationPlayer
  }
}
