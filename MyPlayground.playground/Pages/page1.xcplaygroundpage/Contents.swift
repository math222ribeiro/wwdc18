//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import SceneKit

public class RobotLabController : UIViewController {
  let scene = SCNScene(named:"robots.scnassets/RobotScene/RobotLab.scn")!
  var sceneView: SCNView!
    public override func loadView() {
      let view = UIView()
        view.backgroundColor = .blue
      sceneView = SCNView(frame: view.bounds)
      sceneView.scene = scene
      sceneView.allowsCameraControl = true
      
      view.addSubview(sceneView)

        self.view = view
      print(self.view.frame)
    }
  public override func viewWillLayoutSubviews() {
    print(self.view.frame)
    sceneView.frame = view.frame
  }
}
// Present the view controller in the Live View window
let controller = RobotLabController()
controller.preferredContentSize = CGSize(width: 600, height: 600)
PlaygroundPage.current.liveView = controller
