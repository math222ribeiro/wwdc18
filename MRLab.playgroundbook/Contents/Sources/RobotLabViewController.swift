//
//  GameViewController.swift
//
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import UIKit
import SceneKit
import AVFoundation

public class RobotLabViewController: UIViewController {
  // MARK: Properties
  
  var sceneView: SCNView!
  
  let scene = Assets.getScene(named: Assets.mainSceneName)
  
  /// The node which holds all robot parts.
  var rootRobotNode: SCNNode!
  
  /// Robot current rotation on Y-axis.
  var robotRotationY: Float!
  
  var initialRobotRotationY: Float!
  
  /// User initial touch on X-axis.
  var touchX: CGFloat = 1
  
  var isRobotRotationEnabled = true
  
  var miniBot: MiniBot!
  
  /// A flag to indicate if the user is on robot list view.
  var isOnRobotListView = false
  
  // MARK: UI Properties
  
  var leftButtonFrame: CGRect!
  var rightButtonFrame: CGRect!
  var centerCardFrame: CGRect!
  
  var cameraButton: UIButton!
  var robotListButton: UIButton!
  var mainView: UIView!
  var closeButton: UIButton!
  var robotsButton: UIButton!
  var lowOpacityView: UIView!
  var robotCardImageView: UIImageView!
  var robotsCardImages = [UIImage]()
  
  /// Index of the robot card that is being displayed.
  var currentRobotIndex = 0
  
  // MARK: Scene cameras references
  
  var mainCamera: SCNNode!
  var ortogonalCamera: SCNNode!
  var secondaryCamera: SCNNode!
  
  /// Current scene point of view.
  var currentCamera: SCNNode!
  
  // MARK: Players
  
  var backgrounMusicPlayer: AVAudioPlayer!
  var successSoundEffectPlayer: AVAudioPlayer!
  
  // MARK: Life Cycle
  
  public override func loadView() {
    let view = UIView()
    sceneView = SCNView(frame: view.bounds)
    sceneView.scene = scene
    view.addSubview(sceneView)
    
    self.view = view
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setupScene()
    setupViews()
    setRootRobotNode()
    Timer.scheduledTimer(withTimeInterval: 6, repeats: false) { (_) in
      self.createRobot()
    }
    setupAudio()
    playWelcomeAnimation()
    miniBot = MiniBot(rootNode: scene.rootNode.childNode(named: "mini-bot"), state: .normal)
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    initialRobotRotationY = rootRobotNode.eulerAngles.y
  }
  
  public override func viewWillLayoutSubviews() {
    updateFrames()
    
    sceneView.frame = view.frame
    lowOpacityView.frame = view.frame
    mainView.frame = view.frame
    closeButton.frame = leftButtonFrame
    robotCardImageView.frame = centerCardFrame
    robotsButton.frame = rightButtonFrame
    cameraButton.frame = leftButtonFrame
    robotListButton.frame = rightButtonFrame
  }
  
  public func setupScene() {
    sceneView.scene = scene
    sceneView.showsStatistics = true
    mainCamera = scene.rootNode.childNode(named: "camera_i_position")
    secondaryCamera = scene.rootNode.childNode(named: "camera_b")
    ortogonalCamera = scene.rootNode.childNode(named: "camera_o")
    currentCamera = mainCamera
    sceneView.pointOfView = currentCamera
  }
  
  /// Gets the root robot node from the scene and
  /// sets it to the Robot Manager.
  func setRootRobotNode() {
    rootRobotNode = scene.rootNode.childNode(named: "robot")
    RobotsManager.shared.configure(rootRobotNode: rootRobotNode, cameraDelegate: self)
  }
  
  func setupAudio() {
    do {
      var path = Bundle.main.path(forResource: "bg", ofType: "m4a")
      backgrounMusicPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path!))
      backgrounMusicPlayer.numberOfLoops = -1
      backgrounMusicPlayer.volume = 0.2
      backgrounMusicPlayer.play()
      
      path = Bundle.main.path(forResource: "success", ofType: "m4a")
      successSoundEffectPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path!))
      successSoundEffectPlayer.volume = 1
    } catch {
      fatalError("Could not load the sounds.")
    }
  }
  
  func createRobot() {
    isRobotRotationEnabled = false
    mainView.isHidden = true
    lowOpacityView.isHidden = true
    
    rootRobotNode.runAction(SCNAction.sequence([
      // Makes the robot face the camera.
      SCNAction.rotateTo(x: 0, y: CGFloat(initialRobotRotationY), z: 0, duration: 0.3),
      SCNAction.run({ _ in
        var robotNode = RobotNode()
        robotNode.setHead(robotName: .celBot, robotColor: .red)
        robotNode.setLeg(robotName: .voltBot, robotColor: .blue)
        robotNode.setBody(robotName: .liamBot, robotColor: .yellow)
        robotNode.setLeftArm(robotName: .boxBot, robotColor: .yellow)
        robotNode.setRightArm(robotName: .boxBot, robotColor: .yellow)
        RobotsManager.shared.setRobotNodeOnScene(robotNode) {
          self.isRobotRotationEnabled = true
          self.mainView.isHidden = false
          self.successSoundEffectPlayer.play()
        }
      })]))
  }
}

//////////////////////////////////
//
// MARK: View Setup Methods
//
//////////////////////////////////
extension RobotLabViewController {
  func setupViews() {
    updateFrames()
    getRobotsImages()
    
    mainView = UIView(frame: view.frame)
    
    robotListButton = UIButton(frame: rightButtonFrame)
    robotListButton.setImage(UIImage(named: "robot_icon"), for: .normal)
    robotListButton.addTarget(self, action: #selector(toggleViews), for: .touchUpInside)
    
    cameraButton = UIButton(frame: leftButtonFrame)
    cameraButton.setBackgroundImage(UIImage(named: "camera_icon"), for: .normal)
    cameraButton.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
    
    lowOpacityView = UIView(frame: view.frame)
    lowOpacityView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    
    closeButton = UIButton(frame: leftButtonFrame)
    closeButton.setImage(UIImage(named: "close_icon"), for: .normal)
    closeButton.addTarget(self, action: #selector(toggleViews), for: .touchUpInside)
    
    robotsButton = UIButton(frame: rightButtonFrame)
    robotsButton.setImage(UIImage(named: "arrow_icon"), for: .normal)
    robotsButton.addTarget(self, action: #selector(didTapRobotButton), for: .touchUpInside)
    
    robotCardImageView = UIImageView(frame: centerCardFrame)
    robotCardImageView.image = robotsCardImages[0]
    
    mainView.addSubview(cameraButton)
    mainView.addSubview(robotListButton)
    mainView.isHidden = true
    view.addSubview(mainView)
    
    lowOpacityView.addSubview(closeButton)
    lowOpacityView.addSubview(robotsButton)
    lowOpacityView.addSubview(robotCardImageView)
    lowOpacityView.isHidden = true
    view.addSubview(lowOpacityView)
  }
  
  /// Gets the frame of the UI elements relative to the view position,
  /// used for updating the UI when the user change the scene size.
  func updateFrames() {
    rightButtonFrame = CGRect(
      x: view.bounds.maxX - 30 - 120,
      y: view.bounds.maxY - 30 - 90,
      width: 120,
      height: 90
    )
    leftButtonFrame = CGRect(
      x: 30,
      y: view.bounds.maxY - 30 - 90,
      width: 120,
      height: 90
    )
    centerCardFrame = CGRect(
      x: view.bounds.maxX / 2 - 150,
      y: view.bounds.maxY / 2 - 240,
      width: 300,
      height: 479
    )
  }
  
  func getRobotsImages() {
    for robot in RobotNode.Name.all {
      robotsCardImages.append(UIImage(
        named: robot.rawValue.firstLetterCapitalized() + "_card_icon")!
      )
    }
  }
  
  @objc
  func toggleViews(sender: UIButton) {
    animateButton(sender) {
      self.lowOpacityView.isHidden = self.isOnRobotListView
      self.mainView.isHidden = !self.isOnRobotListView
      self.isRobotRotationEnabled = self.isOnRobotListView
      self.isOnRobotListView = !self.isOnRobotListView
    }
    
  }
  
  @objc
  func didTapRobotButton(sender: UIButton) {
    animateButton(sender) {
      self.showNextRobotCard()
    }
  }
  
  func showNextRobotCard() {
    currentRobotIndex += 1
    if currentRobotIndex == RobotNode.Name.all.count {
      currentRobotIndex = 0
    }

    animateCardImageView(robotCardImageView)
    robotCardImageView.image = robotsCardImages[currentRobotIndex]
  }
  
  @objc
  func didTapCameraButton(sender: UIButton) {
    animateButton(sender) {
      self.switchCamera()
    }
  }
  
  func switchCamera() {
    switch currentCamera {
    case mainCamera:
      currentCamera = secondaryCamera
      cameraButton.setImage(UIImage(named: "camera_b_icon"), for: .normal)
    case secondaryCamera:
      currentCamera = ortogonalCamera
      cameraButton.setImage(UIImage(named: "camera_o_icon"), for: .normal)
    default:
      currentCamera = mainCamera
      cameraButton.setImage(UIImage(named: "camera_icon"), for: .normal)
    }
    
    sceneView.pointOfView = currentCamera
    
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
  
  func animateCardImageView(_ cardImageView: UIImageView) {
    UIView.transition(with: cardImageView, duration: 0.2, options: .transitionFlipFromRight, animations: nil, completion: nil)
  }
}

//////////////////////////////////
//
// MARK: Handling Input
//
//////////////////////////////////
extension RobotLabViewController {
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if isRobotRotationEnabled {
      for touch in touches {
        let location = touch.location(in: sceneView)
        touchX = location.x
        robotRotationY = RobotsManager.shared.rootRobotNode.eulerAngles.y
      }
    }
  }
  
  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if isRobotRotationEnabled {
      for touch in touches {
        let location = touch.location(in: sceneView)
        RobotsManager.shared.rootRobotNode.eulerAngles.y = robotRotationY + (Float(location.x - touchX)  * 0.015)
      }
    }
  }
}

//////////////////////////////////
//
// MARK: Animations
//
//////////////////////////////////
extension RobotLabViewController: CameraAnimationDelegate {
  public func animateCurrentCameraTransform(to transform: SCNMatrix4, completion: (() -> ())? = nil) {
    SCNTransaction.begin()
    SCNTransaction.animationDuration = 1
    SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    currentCamera.transform = transform
    SCNTransaction.completionBlock = completion
    SCNTransaction.commit()
  }
  
  public func animateCameraToRobotPart(_ part: RobotNode.Part?, completion: (() -> ())?) {
    currentCamera = mainCamera
    sceneView.pointOfView = currentCamera
    
    var nodeName: String
    
    if let robotPart = part {
      switch robotPart {
      case .head:
        nodeName = "camera_h_position"
      case .body:
        nodeName = "camera_b_position"
      case .arm:
        nodeName = "camera_a_position"
      case .leg:
        nodeName = "camera_l_position"
      }
    } else {
      nodeName = "camera"
    }
    
    animateCurrentCameraTransform(to: scene.rootNode.childNode(named: nodeName).transform, completion: completion)
  }
  
  func playWelcomeAnimation() {
    let cameraAnimationAction = SCNAction.sequence(
      [SCNAction.wait(duration: 2),
       SCNAction.run({ (_) in
        self.animateCurrentCameraTransform(to:  self.scene.rootNode.childNode(named: "camera").transform)
       })
      ]
    )
    
    // Initial camera animaiton
    scene.rootNode.runAction(cameraAnimationAction)
    Timer.scheduledTimer(withTimeInterval: 3.1, repeats: false) { (_) in
      self.mainView.isHidden = false
    }
  }
}

public protocol CameraAnimationDelegate {
  func animateCameraToRobotPart(_ part: RobotNode.Part?, completion: (() -> ())?)
}
