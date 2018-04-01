
//
//  RobotARViewController.swift
//
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import UIKit
import ARKit

public class RobotARViewController: UIViewController {
  
  var sceneView: ARSCNView!
  var planeNodes = [SCNNode]()
  
  var feedbackView: UIView!
  var feedbackLabel: UILabel!
  var feedbackViewFrame: CGRect!
  var alphaPlaneOnScene = false
  var canPlaneNodeShow = true
  
  // MARK: Life Cycle
  
  public override func loadView() {
    let view = UIView()
    sceneView = ARSCNView(frame: view.bounds)
    sceneView.delegate = self
    sceneView.scene = SCNScene()
    view.addSubview(sceneView)
    
    self.view = view
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
    setupLights()
  }
  
  public override func viewWillLayoutSubviews() {
    updateFrames()
    
    sceneView.frame = view.frame
    feedbackView.frame = feedbackViewFrame
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard ARWorldTrackingConfiguration.isSupported else { return }
    
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    sceneView.session.run(configuration)
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    guard ARWorldTrackingConfiguration.isSupported else { return }
    
    AVCaptureDevice.requestAccess(for: .video) { (granted) in }
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    sceneView.session.pause()
  }

  func updateFrames() {
    feedbackViewFrame = CGRect(x: 25, y: 75, width: 400, height: 30)
  }
  
  func setupViews() {
    updateFrames()
    
    feedbackView = UIView(frame: feedbackViewFrame)
    feedbackView.backgroundColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 0.5)
    feedbackView.layer.cornerRadius = 3
    feedbackView.layer.masksToBounds = true
    view.addSubview(feedbackView)
    
    feedbackLabel = UILabel(frame: CGRect(x: 5, y: 0, width: 390, height: 30))
    feedbackLabel.text = "STARTING MAGIC..."
    feedbackView.addSubview(feedbackLabel)
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    view.addGestureRecognizer(tap)
  }
  
  func setupLights() {
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
  
  
  func isPlaneNodesHidden(_ hidden: Bool) {
    for node in planeNodes {
      node.isHidden = hidden
    }
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

  func placeRobot(_ result: ARHitTestResult) {
    let transform = result.worldTransform
    let planePosition = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    let robotNode = createRobotFromScene(planePosition)!
    sceneView.scene.rootNode.addChildNode(robotNode)
    isPlaneNodesHidden(true)
    canPlaneNodeShow = false
  }
  
  public func resetTracking() {
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
  }
}

