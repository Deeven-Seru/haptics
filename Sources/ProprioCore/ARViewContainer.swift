import Foundation
import ARKit
import RealityKit
import SwiftUI

public struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var analyzer: MotionAnalyzer
    @ObservedObject var haptics: HapticController
    
    public init(analyzer: MotionAnalyzer, haptics: HapticController) {
        self.analyzer = analyzer
        self.haptics = haptics
    }
    
    public func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure AR Session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
        
        // Add Coordinator as Delegate
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator
        
        // Start Analysis
        analyzer.startAnalysis()
        haptics.playGaitEntrainment() // Start metronome immediately for demo
        
        return arView
    }
    
    public func updateUIView(_ uiView: ARView, context: Context) {
        // UI updates (e.g., guide path visibility based on stability)
        if analyzer.gaitStabilityIndex < 0.8 {
            // Show guide path if unstable
            context.coordinator.showGuidePath()
        } else {
            // Hide guide path
            context.coordinator.hideGuidePath()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        var arView: ARView?
        var guidePathAnchor: AnchorEntity?
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        // MARK: - ARSessionDelegate
        
        public func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Pass frame to Motion Analyzer
            parent.analyzer.processFrame(frame.capturedImage)
            
            // Adjust Guide Path position (keep it ahead of user)
            updateGuidePathPosition(frame)
        }
        
        // MARK: - Guide Path Logic
        
        func showGuidePath() {
            guard let arView = arView, guidePathAnchor == nil else { return }
            
            // Create a simple guide line (long green rectangle on floor)
            let mesh = MeshResource.generateBox(size: [0.1, 0.01, 2.0]) // 2m long path
            let material = SimpleMaterial(color: .green, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            
            // Create anchor
            let anchor = AnchorEntity(plane: .horizontal)
            anchor.addChild(entity)
            
            arView.scene.addAnchor(anchor)
            guidePathAnchor = anchor
        }
        
        func hideGuidePath() {
            guard let anchor = guidePathAnchor else { return }
            arView?.scene.removeAnchor(anchor)
            guidePathAnchor = nil
        }
        
        func updateGuidePathPosition(_ frame: ARFrame) {
            guard let anchor = guidePathAnchor else { return }
            
            // Project forward from camera position
            // (Simplified logic: place anchor 1m in front on floor)
            let transform = frame.camera.transform
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -1.0 // 1m forward
            
            // Apply transform (this is simplified; real implementation needs plane detection)
            // anchor.transform.matrix = transform * translation
        }
    }
}
