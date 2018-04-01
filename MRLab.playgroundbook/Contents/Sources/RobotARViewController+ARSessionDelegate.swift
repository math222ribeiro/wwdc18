import ARKit
extension RobotARViewController: ARSessionDelegate {
  
  public func session(_ session: ARSession, didFailWithError error: Error) {
    guard let arError = error as? ARError else { return }
    
    let isRecoverable = (arError.code == .worldTrackingFailed)
    if isRecoverable {
      feedbackLabel.text = "ERROR, TRY RESETTING THE SESSION"
    } else {
      feedbackLabel.text = "ERROR, CAMERA ACCESS DENIED"
    }
  }
  
  public func sessionWasInterrupted(_ session: ARSession) {
    feedbackLabel.text = "Session Interrupted..."
  }
  
  public func sessionInterruptionEnded(_ session: ARSession) {
    resetTracking()
  }
  
  public func session(_ session: ARSession, didUpdate frame: ARFrame) {
    
  }
  
  public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    setFeedbackText(forCameraTrackingState: camera.trackingState)
  }
  
  public func setFeedbackText(forCameraTrackingState state: ARCamera.TrackingState) {
    switch state {
    case .normal:
      feedbackLabel.text = "TRACKING NORMAL"
    case .notAvailable:
      feedbackLabel.text = "TRACKING NOT AVAILABLE"
    case .limited(.excessiveMotion):
      feedbackLabel.text = "TRY MOVING SLOWLY"
    case .limited(.initializing):
      feedbackLabel.text = "STARTING MAGIC..."
    case .limited(.insufficientFeatures):
      feedbackLabel.text = "TRY MOVE AROUND TO DETECT PLANES"
    default:
      feedbackLabel.text = "TRY MOVE AROUND TO DETECT PLANES"
    }
  }
}
