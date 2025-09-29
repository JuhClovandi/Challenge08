import XCTest
@testable import PacoteSoundAnalysis

final class SoundAnalysisTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        
        print("iniciando teste de SoundAnalyzer")
        let analyser = SoundAnalyzer()
        analyser.startAnalysing()
        print("Teste finalizado")
        
    }
}
