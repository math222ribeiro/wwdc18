
//
//  RobotARViewController.swift
//
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import UIKit
import ARKit
import PlaygroundSupport

public class RobotARViewController: UIViewController {
  
  enum ObjectAR: Int {
    case robot = 0
    case miniBot
    case table
    case table2
    case table3
  }
  
  var sceneView: ARSCNView!
  var planeNodes = [SCNNode?]()
  
  var feedbackViewFrame: CGRect!
  var resetButtonFrame: CGRect!
  var leftButtonFrame: CGRect!
  var rightButtonFrame: CGRect!
  var topButtonFrame: CGRect!
  
  var resetButton: UIButton!
  var robotButton: UIButton!
  var miniBotButton: UIButton!
  var currentTableButton: UIButton!
  
  var feedbackView: UIView!
  var feedbackLabel: UILabel!
  
  var alphaPlaneOnScene = false
  var canPlaneNodeShow = true
  var miniBot: MiniBot!
  
  var currentObjectARNode: SCNNode!
  /// Timer that plays the danceVariation animation
  var miniBotTimerAnimation: Timer!
  
  var miniBotMusicPlayer: AVAudioPlayer!
  var tablesNodes = [SCNNode]()
  var currentTableIndex = 0
  
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
    setupAudio()
    didTapSelectCurrentObjectAR(sender: robotButton)
  }
  
  public override func viewWillLayoutSubviews() {
    updateFrames()
    
    sceneView.frame = view.frame
    feedbackView.frame = feedbackViewFrame
    resetButton.frame = resetButtonFrame
    robotButton.frame = topButtonFrame
    miniBotButton.frame = rightButtonFrame
    currentTableButton.frame = leftButtonFrame
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
  
  func setupAudio() {
    do {
      let path = Bundle.main.path(forResource: "beat", ofType: "mp3")
      miniBotMusicPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path!))
      miniBotMusicPlayer.numberOfLoops = -1
      miniBotMusicPlayer.volume = 0.3
      
      // Stop the background music when swift playground app is on background
      NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
      // Play the background music when swift playground app is on background
      NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    } catch {
      fatalError("Failed to load the sounds.")
    }
  }

  @objc
  public func appWillResignActive() {
    miniBotMusicPlayer.stop()
  }
  
  @objc
  public func appDidBecomeActive() {
//    miniBotMusicPlayer.play()
  }
  
  func updateFrames() {
    feedbackViewFrame = CGRect(x: 25, y: 75, width: 400, height: 30)
    
    resetButtonFrame = CGRect(
      x: 25,
      y: 115,
      width: 70,
      height: 52
    )
    
    topButtonFrame = CGRect(
      x: view.bounds.maxX - 25 - 70,
      y: 125,
      width: 70,
      height: 52
    )
    
    rightButtonFrame = CGRect(
      x: view.bounds.maxX - 25 - 70,
      y: view.bounds.maxY - 67 - 52,
      width: 70,
      height: 52
    )
    
    leftButtonFrame = CGRect(
      x: 25,
      y: view.bounds.maxY - 67 - 52,
      width: 70,
      height: 52
    )
  }
  
  public func animateButton(_ button: UIButton, completion: @escaping () -> ()) {
    UIView.animateKeyframes(
      withDuration: 0.2,
      delay: 0,
      options: .calculationModeLinear,
      animations: {
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
          button.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        })
        
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
          button.transform = CGAffineTransform.identity
        })
    },
      completion: { _ in
        completion()
    })
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
    
    resetButton = UIButton(frame: resetButtonFrame)
    resetButton.setImage(UIImage(named: "reset_icon"), for: .normal)
    resetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
    view.addSubview(resetButton)
    
    robotButton = UIButton(frame: topButtonFrame)
    robotButton.setImage(UIImage(named: "bot_ar_icon"), for: .normal)
    robotButton.addTarget(self, action: #selector(didTapSelectCurrentObjectAR), for: .touchUpInside)
    robotButton.tag = 0
    robotButton.alpha = 0.6
    view.addSubview(robotButton)
    
    miniBotButton = UIButton(frame: rightButtonFrame)
    miniBotButton.setImage(UIImage(named: "mini_ar_icon"), for: .normal)
    miniBotButton.addTarget(self, action: #selector(didTapSelectCurrentObjectAR), for: .touchUpInside)
    miniBotButton.tag = 1
    miniBotButton.alpha = 0.6
    view.addSubview(miniBotButton)
    
    currentTableButton = UIButton(frame: leftButtonFrame)
    currentTableButton.setImage(UIImage(named: "table_\(currentTableIndex + 1)"), for: .normal)
    currentTableButton.addTarget(self, action: #selector(didTapSelectCurrentObjectAR), for: .touchUpInside)
    currentTableButton.tag = 2
    currentTableButton.alpha = 0.6
    view.addSubview(currentTableButton)
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    view.addGestureRecognizer(tap)
  }
  
  @objc
  public func didTapSelectCurrentObjectAR(sender: UIButton) {
    animateButton(sender) {
      if sender.tag == 2 {
        self.selectCurrentObjectAR(sender.tag + self.currentTableIndex, sender)
      } else {
        self.selectCurrentObjectAR(sender.tag, sender)
      }
      
    }
  }
  
  func selectTable() {
    
  }
  
  func selectCurrentObjectAR(_ object: Int,_ sender: UIButton) {
    var isTable = false
    canPlaneNodeShow = true

    switch object {
    case ObjectAR.robot.rawValue:
      currentObjectARNode = RobotsManager.shared.rootRobotNode!
      currentObjectARNode.scale = SCNVector3(0.36, 0.36, 0.36)
      currentObjectARNode.eulerAngles = SCNVector3(0, convertToRadians(angle: 90), 0)
    case ObjectAR.miniBot.rawValue:
      currentObjectARNode = miniBot.rootNode
      currentObjectARNode.eulerAngles = SCNVector3(0, 0, 0)
      currentObjectARNode.eulerAngles = SCNVector3(0, convertToRadians(angle: 90), 0)
    case ObjectAR.table.rawValue:
      currentObjectARNode = tablesNodes[0]
      currentObjectARNode.scale = SCNVector3(0.5, 0.5, 0.5)
      isTable = true
    case ObjectAR.table2.rawValue:
      currentObjectARNode = tablesNodes[1]
      currentObjectARNode.scale = SCNVector3(0.5, 0.5, 0.5)
      isTable = true
    case ObjectAR.table3.rawValue:
      currentObjectARNode = tablesNodes[2]
      currentObjectARNode.scale = SCNVector3(0.5, 0.5, 0.5)
      isTable = true
    default:
      currentObjectARNode = SCNNode()
    }
    
    if isTable {
      buttonToggle(tag: object - currentTableIndex)
    } else {
      buttonToggle(tag: object)
    }
    
  }
  
  func buttonToggle(tag: Int) {
    if tag == 2 {
      currentTableIndex += 1
      if currentTableIndex > 2 { currentTableIndex = 0 }
    }
    
    let robotButtonImageName = "bot_ar_icon"
    let miniBotButtonImageName = "mini_ar_icon"
    let tableButtonImageName = "table_\(currentTableIndex + 1)"
    let selected = "_selected"
    
    robotButton.setImage(UIImage(named: robotButtonImageName), for: .normal)
    robotButton.alpha = 0.6
    
    miniBotButton.setImage(UIImage(named: miniBotButtonImageName), for: .normal)
    miniBotButton.alpha = 0.6
    
    currentTableButton.setImage(UIImage(named: tableButtonImageName), for: .normal)
    currentTableButton.alpha = 0.6
    
    switch tag {
    case 0:
      robotButton.alpha = 1
      robotButton.setImage(UIImage(named: robotButtonImageName + selected), for: .normal)
    case 1:
      miniBotButton.setImage(UIImage(named: miniBotButtonImageName + selected), for: .normal)
      miniBotButton.alpha = 1
    case 2:
      currentTableButton.alpha = 1
      currentTableButton.setImage(UIImage(named: tableButtonImageName + selected), for: .normal)
    default:
      fatalError("invalid button tag")
    }
  }
  
  @objc
  public func didTapResetButton(sender: UIButton) {
    animateButton(sender) {
      self.resetTracking()
    }
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
    if let robot = RobotsManager.shared.getRobotNode(fromPlaygroundMessage: PlaygroundKeyValueStore.current["robot"]) {
      RobotsManager.shared.setRobot(robot)
    }
  }
  
  func loadMiniBot() {
    let node = SCNNode()
    miniBot = MiniBot(rootNode: node, state: .dance)
    node.scale = SCNVector3(0.008, 0.008, 0.008)
    miniBotTimerAnimation = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { (_) in
      self.miniBot.playAnimation(.danceVariation)
    }
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
      node?.isHidden = hidden
    }
  }
  
  private func createRobot(_ position: SCNVector3) -> SCNNode? {
      let node = currentObjectARNode!
      if node == miniBot.rootNode {
        miniBotMusicPlayer.play()
      }
      node.position = position
      return node
  }

  func placeRobot(_ result: ARHitTestResult) {
    let result = result.worldTransform
    let planePosition = SCNVector3Make(result.columns.3.x, result.columns.3.y, result.columns.3.z)
    guard let robotNode = createRobot(planePosition) else { return }
    sceneView.scene.rootNode.addChildNode(robotNode)
    isPlaneNodesHidden(true)
    canPlaneNodeShow = false
  }
  
  @objc
  public func resetTracking() {
    for node in sceneView.scene.rootNode.childNodes {
      node.removeFromParentNode()
    }
    
    canPlaneNodeShow = true
    planeNodes = [SCNNode]()
    miniBotMusicPlayer.stop()
    
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
  }
}

