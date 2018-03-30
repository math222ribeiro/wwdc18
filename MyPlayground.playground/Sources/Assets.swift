//
//  Assets.swift
//
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import SceneKit

public struct Assets {
  
  public static let path = "robots.scnassets/"
  
  public static let mainSceneName = "RobotScene/RobotLab.scn"

  public static func getScene(named name: String) -> SCNScene {
    guard let scene = SCNScene(named: path + name) else { fatalError("Unknow Scene Name: \(name).") }
    return scene
  }
}
