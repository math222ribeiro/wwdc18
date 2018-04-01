//
//  Extensions.swift
//
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import SceneKit

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

extension CAAnimation {
  public class func animation(withSceneName name: String) -> CAAnimation {
    guard let scene = SCNScene(named: name) else {
      fatalError("Failed to find scene with name \(name).")
    }
    
    var animation: CAAnimation?
    scene.rootNode.enumerateChildNodes { (child, stop) in
      guard let firstKey = child.animationKeys.first else { return }
      animation = child.animation(forKey: firstKey)
      stop.initialize(to: true)
    }
    
    guard let foundAnimation = animation else {
      fatalError("Failed to find animation named \(name).")
    }
    
    foundAnimation.fadeInDuration = 0.5
    foundAnimation.fadeOutDuration = 0.5
    foundAnimation.usesSceneTimeBase = false
    foundAnimation.repeatCount = Float.infinity
    foundAnimation.isRemovedOnCompletion = true
    
    return foundAnimation
  }
}

public func convertToRadians(angle: Float) -> Float {
  let degreesPerRadians = Float(Double.pi / 180)
  return angle * degreesPerRadians
}

