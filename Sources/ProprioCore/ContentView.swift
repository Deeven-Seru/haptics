import SwiftUI
import ARKit

public struct ContentView: View {
    @StateObject private var motionAnalyzer = MotionAnalyzer()
    @StateObject private var haptics = HapticController()
    @State private var showingSettings = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // AR Background Layer
            ARViewContainer(analyzer: motionAnalyzer, haptics: haptics)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    // Check for Camera Access
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            DispatchQueue.main.async {
                                motionAnalyzer.startAnalysis()
                            }
                        } else {
                            // Handle Permission Denied (UI Alert needed)
                        }
                    }
                }
            
            // Clinical HUD Layer
            VStack {
                // Header (Status)
                HStack {
                    StatusIndicator(isActive: motionAnalyzer.isActive)
                    Spacer()
                    Button(action: { showingSettings.toggle() }) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding()
                .padding(.top, 40)
                
                Spacer()
                
                // Real-time Biofeedback Metrics
                HStack(spacing: 20) {
                    MetricCard(
                        title: "TREMOR",
                        value: String(format: "%.1f", motionAnalyzer.tremorAmplitude * 100), // Scale to %
                        unit: "%",
                        color: motionAnalyzer.tremorAmplitude > 0.5 ? .red : .green
                    )
                    
                    Divider()
                        .frame(height: 50)
                        .background(Color.white.opacity(0.3))
                    
                    MetricCard(
                        title: "STABILITY",
                        value: String(format: "%.0f", motionAnalyzer.gaitStabilityIndex * 100),
                        unit: "%",
                        color: motionAnalyzer.gaitStabilityIndex < 0.8 ? .yellow : .green
                    )
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .shadow(radius: 20)
                .padding(.bottom, 60)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(haptics: haptics)
        }
        .preferredColorScheme(.dark)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
                .kerning(1.2)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundColor(color)
                Text(unit)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.6))
                    .offset(y: -4)
            }
        }
    }
}

struct StatusIndicator: View {
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isActive ? Color.green : Color.red)
                .frame(width: 8, height: 8)
                .shadow(color: isActive ? .green : .red, radius: 4)
            
            Text(isActive ? "MONITORING ACTIVE" : "PAUSED")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.8))
                .kerning(1.0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

struct SettingsView: View {
    @ObservedObject var haptics: HapticController
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Haptic Entrainment")) {
                    Toggle("Enable Rhythmic Stimulation", isOn: Binding(
                        get: { haptics.isPlayingEntrainment },
                        set: { if $0 { haptics.playGaitEntrainment() } else { haptics.stopEntrainment() } }
                    ))
                    
                    if haptics.isPlayingEntrainment {
                        Stepper(value: $haptics.rhythmBpm, in: 40...120, step: 5) {
                            HStack {
                                Text("Tempo")
                                Spacer()
                                Text("\(Int(haptics.rhythmBpm)) BPM")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Section(header: Text("Calibration")) {
                    Button("Recalibrate Sensors") {
                        // Placeholder for calibration logic
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
