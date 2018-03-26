import UIKit
import SceneKit
import PlaygroundSupport

public class RobotLabViewController : UIViewController {
  let scene = SCNScene(named:"robots.scnassets/RobotScene/RobotLab.scn")!
  var sceneView: SCNView!
  
  public override func loadView() {
    let view = UIView()
    setupScene(view)
    self.view = view
  }
  
  func setupScene(_ view: UIView) {
    sceneView = SCNView(frame: view.bounds)
    sceneView.scene = scene
    sceneView.allowsCameraControl = true
    sceneView.showsStatistics = true
    view.addSubview(sceneView)
  }
  
  public override func viewWillLayoutSubviews() {
    print(self.view.frame)
    sceneView.frame = view.frame
  }
}
