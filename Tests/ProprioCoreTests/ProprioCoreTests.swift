import XCTest
@testable import ProprioCore

final class ProprioCoreTests: XCTestCase {
    
    // MARK: - MotionAnalyzer Tests
    
    func testMotionAnalyzerInitialization() throws {
        let analyzer = MotionAnalyzer()
        XCTAssertNotNil(analyzer, "MotionAnalyzer should be initialized")
        XCTAssertEqual(analyzer.tremorAmplitude, 0.0, "Initial tremor amplitude should be 0.0")
        XCTAssertEqual(analyzer.gaitStabilityIndex, 1.0, "Initial gait stability should be 1.0")
        XCTAssertFalse(analyzer.isActive, "Analyzer should not be active initially")
        XCTAssertNil(analyzer.lastError, "No error should be present initially")
        XCTAssertEqual(analyzer.currentMode, .gait, "Default mode should be gait")
        XCTAssertEqual(analyzer.gaitSymmetryIndex, 1.0, "Initial symmetry should be 1.0")
        XCTAssertEqual(analyzer.sessionStepCount, 0, "Initial step count should be 0")
    }

    func testMotionAnalyzerStartStop() throws {
        let analyzer = MotionAnalyzer()

        analyzer.startAnalysis()
        let startExpectation = expectation(description: "Analyzer becomes active")
        DispatchQueue.main.async {
            startExpectation.fulfill()
        }
        wait(for: [startExpectation], timeout: 1.0)
        XCTAssertTrue(analyzer.isActive, "Analyzer should be active after startAnalysis()")

        analyzer.stopAnalysis()
        let stopExpectation = expectation(description: "Analyzer becomes inactive")
        DispatchQueue.main.async {
            stopExpectation.fulfill()
        }
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertFalse(analyzer.isActive, "Analyzer should be inactive after stopAnalysis()")
    }
    
    func testMotionAnalyzerModeSwitch() throws {
        let analyzer = MotionAnalyzer()
        XCTAssertEqual(analyzer.currentMode, .gait)
        analyzer.currentMode = .tremor
        XCTAssertEqual(analyzer.currentMode, .tremor)
    }
    
    func testMotionAnalyzerResetMetrics() throws {
        let analyzer = MotionAnalyzer()
        analyzer.currentMode = .tremor
        
        analyzer.resetMetrics()
        let resetExpectation = expectation(description: "Metrics reset")
        DispatchQueue.main.async {
            resetExpectation.fulfill()
        }
        wait(for: [resetExpectation], timeout: 1.0)
        
        XCTAssertEqual(analyzer.tremorAmplitude, 0.0)
        XCTAssertEqual(analyzer.gaitStabilityIndex, 1.0)
        XCTAssertEqual(analyzer.gaitSymmetryIndex, 1.0)
        XCTAssertEqual(analyzer.sessionStepCount, 0)
        XCTAssertNil(analyzer.lastError)
    }
    
    func testTremorTrendEnum() throws {
        XCTAssertEqual(MotionAnalyzer.TremorTrend.increasing.rawValue, "↑")
        XCTAssertEqual(MotionAnalyzer.TremorTrend.decreasing.rawValue, "↓")
        XCTAssertEqual(MotionAnalyzer.TremorTrend.stable.rawValue, "→")
    }
    
    func testAnalysisModeEnum() throws {
        XCTAssertEqual(AnalysisMode.gait.rawValue, "Gait Assistance")
        XCTAssertEqual(AnalysisMode.tremor.rawValue, "Fine Motor")
        XCTAssertEqual(AnalysisMode.allCases.count, 2)
    }

    // MARK: - HapticController Tests
    
    func testHapticControllerInitialization() throws {
        let controller = HapticController()
        XCTAssertNotNil(controller, "HapticController should be initialized")
        XCTAssertFalse(controller.isPlayingEntrainment, "Entrainment should not be playing initially")
        XCTAssertEqual(controller.rhythmBpm, 60.0, "Default BPM should be 60.0")
        XCTAssertEqual(controller.hapticIntensity, 1.0, "Default intensity should be 1.0")
    }

    func testHapticControllerBpmRange() throws {
        let controller = HapticController()
        controller.rhythmBpm = 120.0
        XCTAssertEqual(controller.rhythmBpm, 120.0, "BPM should be settable to 120")
        controller.rhythmBpm = 40.0
        XCTAssertEqual(controller.rhythmBpm, 40.0, "BPM should be settable to 40")
    }
    
    func testHapticControllerIntensity() throws {
        let controller = HapticController()
        controller.hapticIntensity = 0.5
        XCTAssertEqual(controller.hapticIntensity, 0.5, "Intensity should be settable")
        controller.hapticIntensity = 0.0
        XCTAssertEqual(controller.hapticIntensity, 0.0, "Intensity should be settable to 0")
    }
    
    func testHapticControllerEmergencyStop() throws {
        let controller = HapticController()
        // Should not crash when called before any playback
        controller.emergencyStop()
        XCTAssertFalse(controller.isPlayingEntrainment)
    }

    // MARK: - Error Description Tests
    
    func testHapticErrorDescriptions() throws {
        let engineError = HapticError.engineNotSupported
        XCTAssertNotNil(engineError.errorDescription, "Engine error should have a description")
        XCTAssertTrue(engineError.errorDescription!.contains("not supported"))

        let patternError = HapticError.patternFailed(NSError(domain: "test", code: 1))
        XCTAssertNotNil(patternError.errorDescription, "Pattern error should have a description")
        XCTAssertTrue(patternError.errorDescription!.contains("Failed to play"))
    }

    func testMotionAnalysisErrorDescriptions() throws {
        let cameraError = MotionAnalysisError.cameraUnavailable
        XCTAssertNotNil(cameraError.errorDescription)
        XCTAssertTrue(cameraError.errorDescription!.contains("Camera"))

        let lowConfidence = MotionAnalysisError.lowConfidence
        XCTAssertNotNil(lowConfidence.errorDescription)
        XCTAssertTrue(lowConfidence.errorDescription!.contains("confidence"))

        let visionError = MotionAnalysisError.visionRequestFailed(NSError(domain: "test", code: 1))
        XCTAssertNotNil(visionError.errorDescription)
        XCTAssertTrue(visionError.errorDescription!.contains("Vision"))
    }
}
