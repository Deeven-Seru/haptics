import CoreHaptics
import Foundation

public class HapticController: ObservableObject {
    private var engine: CHHapticEngine?
    private var timer: Timer?
    
    // Configurable parameters
    public var rhythmBpm: Double = 60.0 // Base metronome (steps per minute)
    
    public init() {
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // Re-enable engine if app resumes
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
        } catch {
            print("Haptic Engine Error: \(error.localizedDescription)")
        }
    }
    
    public func playGaitEntrainment() {
        // Start rhythmic pattern (Metronome)
        let interval = 60.0 / rhythmBpm
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playSharpTick()
        }
        
        print("Gait Entrainment Started: \(rhythmBpm) BPM")
    }
    
    public func stopEntrainment() {
        timer?.invalidate()
        timer = nil
        print("Gait Entrainment Stopped")
    }
    
    private func playSharpTick() {
        guard let engine = engine else { return }
        
        // Define a sharp, distinct transient event
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error)")
        }
    }
    
    // Dynamic feedback for tremor (continuous vibration inversely proportional to stability)
    public func playTremorCorrection(intensity: Float) {
        guard let engine = engine else { return }
        
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        
        // Use a continuous event for smooth feedback
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensityParam, sharpnessParam], relativeTime: 0, duration: 0.1)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play continuous feedback: \(error)")
        }
    }
}
