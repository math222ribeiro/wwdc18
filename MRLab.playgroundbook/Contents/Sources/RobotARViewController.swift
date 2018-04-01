
//
//  RobotARViewController.swift
//
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import UIKit
import ARKit

public class RobotARViewController: UIViewController {
  
  var sceneView: ARSCNView!
  private var planeNode: SCNNode?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    view.addGestureRecognizer(tap)
    
    let ambientLightNode = SCNNode()
    ambientLightNode.light = SCNLight()
    ambientLightNode.light?.type = .ambient
    ambientLightNode.light?.intensity = 500
    sceneView.scene.rootNode.addChildNode(ambientLightNode)
    
    let omniLightNode = SCNNode()
    omniLightNode.light = SCNLight()
    omniLightNode.light?.type = .omni
    omniLightNode.light?.color = UIColor.white
    omniLightNode.light?.intensity = 500
    sceneView.scene.rootNode.addChildNode(omniLightNode)
  }
  
  @objc
  func handleTap(_ sender: UITapGestureRecognizer) {
    let tapLocation = sender.location(in: sceneView)
    
    let results = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
    
    if let result = results.first {
      placeRobot(result)
    }
  }
  
  func placeRobot(_ result: ARHitTestResult) {
    let transform = result.worldTransform
    let planePosition = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    let robotNode = createRobotFromScene(planePosition)!
    sceneView.scene.rootNode.addChildNode(robotNode)
  }
  
  private func createRobotFromScene(_ position: SCNVector3) -> SCNNode? {
    let scene = Assets.getScene(named: Assets.mainSceneName)
    let node = scene.rootNode.childNode(named: "robot")
    // Position scene
    node.position = position
    node.scale = SCNVector3(0.36, 0.36, 0.36)
    node.eulerAngles.y = convertToRadians(angle: 0)
    return node
  }
  
  public override func viewDidAppear(_ animated: Bool) {
     guard ARWorldTrackingConfiguration.isSupported else { return }
    
    AVCaptureDevice.requestAccess(for: .video) { (granted) in
    
    }
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    sceneView.session.pause()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard ARWorldTrackingConfiguration.isSupported else { return }
    
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    // Run the view's session
    self.sceneView.session.run(configuration)
    
  }
  
  public override func viewWillLayoutSubviews() {
    sceneView.frame = view.frame
  }
  
  public override func loadView() {
    let view = UIView()
    sceneView = ARSCNView(frame: view.bounds)
    sceneView.delegate = self
    sceneView.scene = SCNScene()
    view.addSubview(sceneView)
    
    self.view = view
  }
}

extension RobotARViewController: ARSessionDelegate {
  
  public func session(_ session: ARSession, didFailWithError error: Error) {
    
  }
  
  public func sessionWasInterrupted(_ session: ARSession) {
    
  }
  
  public func sessionInterruptionEnded(_ session: ARSession) {
    
  }
  
  public func session(_ session: ARSession, didUpdate frame: ARFrame) {
    
  }
}


extension RobotARViewController: ARSCNViewDelegate {
  public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    
  }
  
  public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    if anchor is ARPlaneAnchor {
      planeNode = SCNNode()
      return planeNode
    }
    
    return nil
  }
  
  public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else {
      return
    }
    
    let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
    
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
    plane.materials = [planeMaterial]
    
    let alphaPlane = SCNNode(geometry: plane)
    alphaPlane.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
    alphaPlane.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    let shape = SCNPhysicsShape(geometry: plane, options: nil)
    alphaPlane.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
    
    node.addChildNode(alphaPlane)
  }
  
  public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor,
      let alphaPlane = node.childNodes.first,
      let plane = alphaPlane.geometry as? SCNPlane
      else { return }
    
    plane.width = CGFloat(planeAnchor.extent.x)
    plane.height = CGFloat(planeAnchor.extent.z)
    alphaPlane.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
    let shape = SCNPhysicsShape(geometry: plane, options: nil)
    alphaPlane.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
  }
  
}


