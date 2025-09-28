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


/// Compatível com iOS 15+
@available(iOS 15.0, *)
public class AudioManager: ObservableObject {

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
    
    // As funções abaixo são detalhes internos do pacote.
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

    private func stopListening() {
   
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        streamAnalyzer?.removeAllRequests()
        streamAnalyzer = nil
        resultsObserver = nil
    }
}


@available(iOS 15.0, *)
private class ResultsObserver: NSObject, SNResultsObserving {
   
    let publisher: PassthroughSubject<Void, Never>
    init(publisher: PassthroughSubject<Void, Never>) { self.publisher = publisher }
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult, let best = result.classifications.first else { return }
        
        //confianca do som
        let confidence = String(format: "%.2f%%", best.confidence * 100)
        print(" Som detectado: \(best.identifier) | Confiança: \(confidence)")
        if best.identifier == "finger_snapping" && best.confidence > 0.6 {
            publisher.send()
        }
    }
    func request(_ request: SNRequest, didFailWithError error: Error) {}
    func requestDidComplete(_ request: SNRequest) {}
}
