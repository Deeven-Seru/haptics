import SwiftUI
import ARKit

public struct ContentView: View {
    @StateObject private var motionAnalyzer = MotionAnalyzer()
    @StateObject private var haptics = HapticController()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // AR Background
            ARViewContainer(analyzer: motionAnalyzer, haptics: haptics)
                .edgesIgnoringSafeArea(.all)
            
            // HUD Overlay
            VStack {
                Spacer()
                
                // Real-time Metrics
                HStack(spacing: 20) {
                    MetricView(title: "TREMOR", value: String(format: "%.1f", motionAnalyzer.tremorAmplitude), unit: "%")
                        .foregroundColor(motionAnalyzer.tremorAmplitude > 0.5 ? .red : .green)
                    
                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.3))
                    
                    MetricView(title: "STABILITY", value: String(format: "%.0f", motionAnalyzer.gaitStabilityIndex * 100), unit: "%")
                        .foregroundColor(motionAnalyzer.gaitStabilityIndex < 0.8 ? .yellow : .green)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MetricView: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                Text(unit)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

#Preview {
    ContentView()
}
