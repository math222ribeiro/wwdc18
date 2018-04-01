import ARKit

extension RobotARViewController: ARSCNViewDelegate {
  public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    if anchor is ARPlaneAnchor {
      let node = SCNNode()
      node.isHidden = !canPlaneNodeShow
      planeNodes.append(node)
      return planeNodes.last!
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
    
    setFeedbackText(forCameraTrackingState: .normal)
    
    plane.width = CGFloat(planeAnchor.extent.x)
    plane.height = CGFloat(planeAnchor.extent.z)
    alphaPlane.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
    let shape = SCNPhysicsShape(geometry: plane, options: nil)
    alphaPlane.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
  }
  
  public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    guard let _ = anchor as? ARPlaneAnchor,
      let alphaPlane = node.childNodes.first,
      let _ = alphaPlane.geometry as? SCNPlane
      else { return }
    
  }
}

