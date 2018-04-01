//
//  MiniBot.swift
//
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import SceneKit

public struct MiniBot: AnimationPlayer {
  private var rootNode: SCNNode
  
  public enum Animation {
    case idleVariation
    case excited
    case waving
    case danceVariation
    case clapping
    case happy
  }
  
  public enum InitialState {
    case normal
    case dance
  }
  
  public init(rootNode: SCNNode, state: InitialState) {
    self.rootNode = rootNode
    
    var sceneName: String
    switch state {
    case .dance:
      sceneName = "dance.scn"
    case .normal:
      sceneName = "idle.scn"
    }
    
    let idleScene = SCNScene(named: sceneName, inDirectory: "robots.scnassets/MiniBot/")!
    for node in idleScene.rootNode.childNodes {
      rootNode.addChildNode(node)
    }

    // Fixes the node scale on the scene.
    rootNode.scale = SCNVector3(0.011, 0.011, 0.011)
    rootNode.addAnimation(CAAnimation.animation(withSceneName: "robots.scnassets/MiniBot/idle.scn"), forKey: "idle")
  }
  
  // MARK: Animations
  
  public func playAnimation(_ animation: Animation) {
    switch animation {
    case .idleVariation:
      playIdleVariationAnimation()
    case .danceVariation:
      playDanceVariationAnimation()
    case .excited:
      playExcitedAnimation()
    case .waving:
      playWavingAnimation()
    case .clapping:
      playClappingAnimation()
    case .happy:
      playHappyAnimation()
    }
  }

  private func playIdleVariationAnimation() {
    let idleVariation = CAAnimation.animation(withSceneName: "robots.scnassets/MiniBot/idle_var.scn")
    idleVariation.repeatCount = 1
    rootNode.addAnimation(idleVariation, forKey: "danceVariation")
  }

  private func playDanceVariationAnimation() {
    let danceVariation = CAAnimation.animation(withSceneName: "robots.scnassets/MiniBot/dance_var.scn")
    danceVariation.repeatCount = 1
    rootNode.addAnimation(danceVariation, forKey: "danceVariation")
  }

  private func playClappingAnimation() {
    let clapping = CAAnimation.animation(withSceneName: "robots.scnassets/MiniBot/clapping.scn")
    clapping.repeatCount = 2
    rootNode.addAnimation(clapping, forKey: "clapping")
  }

  private func playExcitedAnimation() {
    let excited = CAAnimation.animation(withSceneName: "robots.scnassets/MiniBot/excited.scn")
    rootNode.addAnimation(excited, forKey: "excited")
  }

  private func playWavingAnimation() {
    let waving = CAAnimation.animation(withSceneName: "robots.scnassets/MiniBot/waving.scn")
    waving.repeatCount = 2
    rootNode.addAnimation(waving, forKey: "waving")
  }
  
  /// "Clapping" animation and "Excited" animaiton together.
  private func playHappyAnimation() {
    let clapping = CAAnimation.animation(withSceneName: "robots.scnassets/MiniBot/clapping.scn")
    clapping.repeatCount = 3
    clapping.speed = 1.4
    let delegate = MiniBotHappyAnimationDelegate()
    delegate.animationPlayer = self
    clapping.delegate = delegate
    rootNode.addAnimation(clapping, forKey: "clapping")
  }
}

/// Delegate for happy animation.
class MiniBotHappyAnimationDelegate: NSObject, CAAnimationDelegate {
  
  var animationPlayer: AnimationPlayer!
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    animationPlayer.playAnimation(.excited)
  }
}

protocol AnimationPlayer {
  func playAnimation(_ animation: MiniBot.Animation)
}
