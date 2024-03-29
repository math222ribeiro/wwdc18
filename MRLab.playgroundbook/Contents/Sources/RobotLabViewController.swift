//
//  RobotLabViewController.swift
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
  var robotRotationY: Float = 0
  
  var initialRobotRotationY: Float!
  
  /// User initial touch on X-axis.
  var touchX: CGFloat = 1
  
  var isRobotRotationEnabled = true
  
  var miniBot: MiniBot!
  
  /// A flag to indicate if the user is on robot list view.
  var isOnRobotListView = false
  
  // MARK: UI Properties
  
  // Frames
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
  
  /// Timer that plays the idleVariation animation
  var miniBotTimerAnimation: Timer!
  
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
    setupAudio()
    loadMiniBot()
    playWelcomeAnimation()
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
  
  // MARK: Scene Setups
  
  public func setupScene() {
    sceneView.scene = scene
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
    backgrounMusicPlayer.stop()
  }
  
  @objc
  public func appDidBecomeActive() {
    backgrounMusicPlayer.play()
  }
  
  func loadMiniBot() {
    miniBot = MiniBot(rootNode: scene.rootNode.childNode(named: "mini-bot"), state: .normal)
    miniBotTimerAnimation = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { (_) in
      self.miniBot.playAnimation(.idleVariation)
    }
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
      x: view.bounds.maxX - 25 - 90,
      y: view.bounds.maxY - 67 - 125,
      width: 90,
      height: 67
    )
    
    leftButtonFrame = CGRect(
      x: 25,
      y: view.bounds.maxY - 67 - 125,
      width: 90,
      height: 67
    )
    
    centerCardFrame = CGRect(
      x: view.bounds.maxX / 2 - 137,
      y: view.bounds.maxY / 2 - 218,
      width: 274,
      height: 437
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
    let waveAction = SCNAction.run { (_) in
      self.miniBot.playAnimation(.waving)
    }
    
    let cameraAnimationAction = SCNAction.sequence(
      [SCNAction.wait(duration: 2),
       SCNAction.run({ (_) in
        self.animateCurrentCameraTransform(to:  self.scene.rootNode.childNode(named: "camera").transform)
       })
      ]
    )
    
    // Initial camera animaiton
    scene.rootNode.runAction(SCNAction.group([waveAction, cameraAnimationAction]))
    Timer.scheduledTimer(withTimeInterval: 3.1, repeats: false) { (_) in
      self.mainView.isHidden = false
    }
  }
}

public protocol CameraAnimationDelegate {
  func animateCameraToRobotPart(_ part: RobotNode.Part?, completion: (() -> ())?)
}
