//
//  AudioManager.swift
//  PacoteSoundAnalysis
//
//  Created by Keitiely Silva Viana on 26/09/25.
//

import Foundation
import SoundAnalysis


@available(iOS 15.0, *)
@MainActor
public class AudioManager {
    public let audioEngine = AVAudioEngine()
    private var streamAnalyzer: SNAudioStreamAnalyzer? // Analisador de áudio
    private let analysisQueue = DispatchQueue(label: "com.pacote.analysisQueue") // Fila para análise
    
    private let observer = AudioAnalysisObserver() // Observador de resultados
    
    
    
    public init() {}
    
    /// Inicia a captura e análise de áudio
    /// Compatível com iOS 13+
    @available(iOS 15.0, *)
    public func startListeningForEstalos(callback: @escaping () -> Void) throws {
        self.observer.onSnapDetected = callback
        
        let inputNode = audioEngine.inputNode //inputNode esse é omicrofone
        let format = inputNode.inputFormat(forBus: 0)
        
        //checagem de versao pois o snaudiostremanalyzer so existe pra o ios 13
        // Checagem de versão
        // Inicializa o analisador de áudio
        let analyzer = SNAudioStreamAnalyzer(format: format)
        streamAnalyzer = analyzer
            
        // Cria o pedido de classificação de som
        do {
            let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
            try analyzer.add(request, withObserver: observer)
        } catch {
            print("Erro ao adicionar request: \(error.localizedDescription)")
        }
        // Guarda a fila de análise em uma variável local para evitar capturar 'self'
        let analysisQueue = self.analysisQueue
        // Instala um "tap" no microfone para capturar buffers de áudio
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) {buffer, when in
                analyzer.analyze(buffer, atAudioFramePosition: when.sampleTime)
        }
        // Prepara e inicia o motor de áudio
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    /// Para a captura de áudio
    public func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        streamAnalyzer = nil
    }
}

@available(iOS 15.0, *)
@MainActor
final class AudioAnalysisObserver: NSObject, SNResultsObserving {
    
    var onSnapDetected: (() -> Void)?
    
    nonisolated func request(_ request: SNRequest, didProduce result: SNResult) {
        
        guard let result = result as? SNClassificationResult,
              let bestClassification = result.classifications.first else { return }
        
        // Exemplo de como você vai usar o callback no próximo passo:
        if bestClassification.identifier == "FingerSnap" && bestClassification.confidence > 0.7 {
            print("Estalo detectado com confiança alta!")
            // Chama a função que foi passada!
            DispatchQueue.main.async {
                self.onSnapDetected?()
            }
        }
    }
    nonisolated  func request(_ request: SNRequest, didFailWithError error: Error) {
        print("A análise falhou com o erro: \(error.localizedDescription)")
    }
    
    nonisolated  func requestDidComplete(_ request: SNRequest) {
        print("A análise foi completada.")
    }
}
