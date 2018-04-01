
//
//  RobotARViewController.swift
//
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import UIKit
import ARKit
import PlaygroundSupport

public class RobotARViewController: UIViewController {
  
  var sceneView: ARSCNView!
  var planeNodes = [SCNNode]()
  
  var feedbackView: UIView!
  var feedbackLabel: UILabel!
  var feedbackViewFrame: CGRect!
  var alphaPlaneOnScene = false
  var canPlaneNodeShow = true
  var miniBot: MiniBot!
  var tablesNodes = [SCNNode]()
  var a = 0
  
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
    setRootRobotNode()
    loadMiniBot()
    loadTablesNodes()
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
    
    AVCaptureDevice.requestAccess(for: .video) { (_) in }
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

  func setRootRobotNode() {
    RobotsManager.shared.configure(rootRobotNode: Assets.getScene(named: Assets.mainSceneName).rootNode.childNode(named: "robot"), cameraDelegate: nil)
  }
  
  func loadMiniBot() {
    let node = SCNNode()
    miniBot = MiniBot(rootNode: node, state: .dance)
    node.scale = SCNVector3(0.008, 0.008, 0.008)
  }
  
  func loadTablesNodes() {
    for i in 1...3 {
     tablesNodes.append(Assets.getScene(named: "RobotScene/Table_\(i).scn").rootNode.childNode(named: "Table_\(i)"))
    }
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
  
  private func createRobot(_ position: SCNVector3) -> SCNNode? {
    if a == 0 {
      if let robotNode = RobotsManager.shared.getRobotNode(fromPlaygroundMessage: PlaygroundKeyValueStore.current["robot"]) {
        RobotsManager.shared.setRobot(robotNode)
      }
      
//      let node = RobotsManager.shared.rootRobotNode!
//      // Position scene
//      node.position = position
//      node.scale = SCNVector3(0.36, 0.36, 0.36)
//      node.eulerAngles.y = convertToRadians(angle: 0)
//      a += 1
//      return node
      let node = tablesNodes[2]
      // Position scene
      node.position = position
      node.scale = SCNVector3(0.36, 0.36, 0.36)
      node.eulerAngles.y = convertToRadians(angle: 0)
      a += 1
      return node
    } else if a == 1{
      a += 1
      return nil
    } else {
      a += 1
      miniBot.rootNode.position = position
      return miniBot.rootNode
    }
  }

  func placeRobot(_ result: ARHitTestResult) {
    let transform = result.worldTransform
    let planePosition = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    guard let robotNode = createRobot(planePosition) else {
      resetTracking()
      return
    }
    sceneView.scene.rootNode.addChildNode(robotNode)
    isPlaneNodesHidden(true)
    canPlaneNodeShow = false
  }
  
  public func resetTracking() {
    for node in sceneView.scene.rootNode.childNodes {
      node.removeFromParentNode()
    }
    
    canPlaneNodeShow = true
    planeNodes = [SCNNode]()
    
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
  }
}

