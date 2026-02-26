import Foundation
import Vision
import ARKit
import Combine

public class MotionAnalyzer: ObservableObject {
    // Published properties for UI updates
    @Published public var tremorAmplitude: Double = 0.0
    @Published public var gaitStabilityIndex: Double = 1.0 // 1.0 = stable, < 0.8 = unstable
    @Published public var isActive: Bool = false
    
    // Vision request for pose detection
    private let poseRequest = VNDetectHumanBodyPoseRequest()
    
    // Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // Historical data for variance calculation (simple buffer)
    private var wristPositions: [CGPoint] = []
    private let maxHistorySize = 60 // ~1 second at 60fps
    
    public init() {
        // Configure Vision request
        // We focus on upper body for hand tremors, full body for gait
        // For this demo, let's assume a generalized approach
    }
    
    public func startAnalysis() {
        self.isActive = true
        // In a real app, this would hook into ARSessionDelegate or AVCaptureSession
        print("Motion Analysis Started")
    }
    
    public func stopAnalysis() {
        self.isActive = false
        print("Motion Analysis Stopped")
    }
    
    // Called by ARSession delegate with each frame
    public func processFrame(_ pixelBuffer: CVPixelBuffer) {
        guard isActive else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([poseRequest])
            
            guard let observation = poseRequest.results?.first else { return }
            
            // Extract keypoints (Right Wrist for tremor demo)
            let rightWrist = try observation.recognizedPoint(.rightWrist)
            
            if rightWrist.confidence > 0.3 {
                // Normalize coordinates and store
                let point = CGPoint(x: rightWrist.location.x, y: rightWrist.location.y)
                updateTremorMetrics(point)
            }
            
        } catch {
            print("Vision error: \(error)")
        }
    }
    
    private func updateTremorMetrics(_ point: CGPoint) {
        wristPositions.append(point)
        if wristPositions.count > maxHistorySize {
            wristPositions.removeFirst()
        }
        
        // Simple variance calculation (X-axis tremor)
        let xValues = wristPositions.map { $0.x }
        let mean = xValues.reduce(0, +) / Double(xValues.count)
        let variance = xValues.map { pow($0 - mean, 2) }.reduce(0, +) / Double(xValues.count)
        
        DispatchQueue.main.async {
            // Scale variance to a 0-1 amplitude for UI/Haptics
            self.tremorAmplitude = min(sqrt(variance) * 100, 1.0) 
        }
    }
}
