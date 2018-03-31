//
//  MiniBot.swift
//
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import SceneKit

public struct MiniBot {
  private var rootNode: SCNNode
  
  public enum Animation {
    case idleVariation
    case excited
    case waving
    case danceVariation
    case clapping
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
      sceneName = "MiniBot/dance"
    case .normal:
      sceneName = "MiniBot/idle"
    }
    
//    guard let url = Bundle.main.url(forResource: "robots.scnassets/MiniBot/idle", withExtension: "scn") else {
//      return
//    }
//    var idleScene = SCNScene()
//
//    do {
//      let scene: SCNScene
//      scene = try SCNScene(url: url, options: [:])
//      idleScene = scene
//    }
//    catch {
//      fatalError("sdhfdshf")
//    }
    
    let idleScene = SCNScene(named: "idle.scn", inDirectory: "robots.scnassets/MiniBot/")!
    for node in idleScene.rootNode.childNodes {
      rootNode.addChildNode(node)
    }

    // Fixes the node scale on the scene.
    rootNode.scale = SCNVector3(0.011, 0.011, 0.011)
    rootNode.addAnimation(CAAnimation.animation(withSceneName: "robots.scnassets/MiniBot/idle.scn"), forKey: "idle")
//    animation(named: "idle.scn")
  }
  
//  func animation(named animationName: String) -> SCNAnimation? {
//    let animScene = SCNScene(named: animationName, inDirectory: "robots.scnassets/MiniBot")
//    var animation: SCNAnimation?
//    animScene?.rootNode.enumerateChildNodes({ (child, stop) in
//      if !child.animationKeys.isEmpty {
//        let player = child.animationPlayer(forKey: child.animationKeys[0])
//        animation = player?.animation
//        stop.initialize(to: true)
//      }
//    })
//
//    return animation
//  }
  
  // MARK: Animations
  
//  public func playAnimation(_ animation: Animation) {
//    switch animation {
//    case .idleVariation:
//      playIdleVariationAnimation()
//    case .danceVariation:
//      playDanceVariationAnimation()
//    case .excited:
//      playExcitedAnimation()
//    case .waving:
//      playWavingAnimation()
//    case .clapping:
//      playClappingAnimation()
//    }
//  }
//
//  private func playIdleVariationAnimation() {
//    let idleVariation = SCNAnimationPlayer.loadAnimation(fromScene: Assets.getScene(named: "MiniBot/idle_var"))
//    idleVariation.play()
//    idleVariation.animation.repeatCount = 1
//    idleVariation.animation.blendOutDuration = 0.5
//    idleVariation.animation.blendInDuration = 0.3
//    rootNode.addAnimationPlayer(idleVariation, forKey: "idle_var")
//  }
//
//  private func playDanceVariationAnimation() {
//    let danceVariation = SCNAnimationPlayer.loadAnimation(fromScene: Assets.getScene(named: "MiniBot/dance_var"))
//    danceVariation.play()
//    danceVariation.animation.repeatCount = 1
//    danceVariation.animation.blendOutDuration = 0.5
//    danceVariation.animation.blendInDuration = 0.3
//    rootNode.addAnimationPlayer(danceVariation, forKey: "dance_var")
//  }
//
//  private func playClappingAnimation() {
//    let clapping = SCNAnimationPlayer.loadAnimation(fromScene: Assets.getScene(named: "MiniBot/clapping"))
//    clapping.play()
//    clapping.animation.repeatCount = 4
//    clapping.animation.blendOutDuration = 0.5
//    clapping.animation.blendInDuration = 0.3
//    rootNode.addAnimationPlayer(clapping, forKey: "clapping")
//  }
//
//  private func playExcitedAnimation() {
//    let happy = SCNAnimationPlayer.loadAnimation(fromScene: Assets.getScene(named: "MiniBot/excited"))
//    happy.play()
//    happy.animation.repeatCount = CGFloat.infinity
//    happy.animation.blendOutDuration = 0.8
//    happy.animation.blendInDuration = 0.3
//    rootNode.addAnimationPlayer(happy, forKey: "excited")
//  }
//
//  private func playWavingAnimation() {
//    let waving = SCNAnimationPlayer.loadAnimation(fromScene: Assets.getScene(named: "MiniBot/waving"))
//    waving.play()
//    waving.animation.repeatCount = 2
//    waving.animation.blendOutDuration = 0.2
//    waving.animation.blendInDuration = 0.8
//    rootNode.addAnimationPlayer(waving, forKey: "happy")
//  }
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
    
    foundAnimation.fadeInDuration = 0.3
    foundAnimation.fadeOutDuration = 0.3
    foundAnimation.repeatCount = 1
    foundAnimation.usesSceneTimeBase = false
    foundAnimation.repeatCount = Float.infinity
    
    return foundAnimation
  }
}

