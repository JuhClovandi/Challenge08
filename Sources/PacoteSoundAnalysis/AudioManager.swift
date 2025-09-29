//
//  AudioManager.swift
//  PacoteSoundAnalysis
//
//  Created by Keitiely Silva Viana on 26/09/25.
//


import Foundation
@preconcurrency import AVFoundation
@preconcurrency import SoundAnalysis
import Combine

/// Classe principal que permite escutar e classificar os sons.
/// Compatível com iOS 15+
@available(iOS 15.0, *)
public class AudioManager: ObservableObject {
    
    /// Objeto q permite o relay de informação do Observador de som.
    private let snapPublisher = PassthroughSubject<Void, Never>()
    private var snapSubscription: AnyCancellable?

    private let audioEngine = AVAudioEngine()
    private var streamAnalyzer: SNAudioStreamAnalyzer?
    private let analysisQueue = DispatchQueue(label: "com.pacote.analysisQueue")
    private var resultsObserver: ResultsObserver?

    public init() {}

    
    /// Inicia a captura e análise de áudio
    /// Inicia o monitor de estalos. O monitor continuará ativo até que `pararMonitor()` seja chamado.
    /// - Parameter onEstalo: O bloco de código a ser executado a CADA estalo detectado.
    public func iniciarMonitor(onEstalo: @escaping () -> Void) {
        do {
            try startListening()
        } catch {
            print("Falha ao iniciar o motor de áudio: \(error.localizedDescription)")
            return
        }
        
        snapSubscription = snapPublisher
            .receive(on: RunLoop.main)
            .sink {
                // Apenas executa a ação do usuário. O monitor NÃO para.
                onEstalo()
            }
        
        print(" Monitor de estalos iniciado. Ficará ativo até ser parado.")
    }
     
    /// Para completamente o monitor de estalos e desliga o microfone.
    public func pararMonitor() {
        stopListening()
        snapSubscription?.cancel()
        snapSubscription = nil
        print(" Monitor de estalos finalizado.")
    }
    
    /// Inicia o microfone e começa a analisar o som.
    private func startListening() throws {
      
        resultsObserver = ResultsObserver(publisher: snapPublisher)
        let inputNode = audioEngine.inputNode
        let format = inputNode.inputFormat(forBus: 0)
        let streamAnalyzer = SNAudioStreamAnalyzer(format: format)
        self.streamAnalyzer = streamAnalyzer
        do {
            let request = try SNClassifySoundRequest(classifierIdentifier: .version1) //utilizando o SNClassifySoundRequest
            try streamAnalyzer.add(request, withObserver: resultsObserver!)
        } catch { throw error }
        let analysisQueue = self.analysisQueue
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, time in
            analysisQueue.async {
                streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }
        audioEngine.prepare()
        try audioEngine.start()
    }

    /// Desliga o microfone e subsequentemente o monitor de som.
    private func stopListening() {
   
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        streamAnalyzer?.removeAllRequests()
        streamAnalyzer = nil
        resultsObserver = nil
    }
}

/// Observador de resultados utilizado pelo sound analyzer para reportar os sons detectados
@available(iOS 15.0, *)
private class ResultsObserver: NSObject, SNResultsObserving {
   
    let publisher: PassthroughSubject<Void, Never>
    init(publisher: PassthroughSubject<Void, Never>) { self.publisher = publisher }
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult, let best = result.classifications.first else { return }
        
        /// Define qual som e com qual confianca deve ser reportado como "sucesso"
        let confidence = String(format: "%.2f%%", best.confidence * 100)
        print(" Som detectado: \(best.identifier) | Confiança: \(confidence)")
        
        /// Verifica se o nome do som identificado é igual ao desejado, alem de verificar com qual confianca o som foi identificado.
        if best.identifier == "finger_snapping" && best.confidence > 0.7 {
            /// Reporta que escutou x som para o publisher
            publisher.send()
        }
    }
    func request(_ request: SNRequest, didFailWithError error: Error) {}
    func requestDidComplete(_ request: SNRequest) {}
}
