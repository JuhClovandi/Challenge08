// The Swift Programming Language
// https://docs.swift.org/swift-book
// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import AVFoundation // Importa o framework de Áudio e Vídeo
import SoundAnalysis 

public class SoundAnalyzer {
    // Propriedade para a "máquina de áudio"
    private let audioEngine = AVAudioEngine()
    
    public init(){}
    
    public func startAnalysing(){
        //implementar depois
        print("start chamando ainda sem audio..")
        //pedindo permissao para usar o microfone
        AVAudioSession.sharedInstance().requestRecordPermission { granted in //requestRecordPermission garante que vai ter o alerta de permissao
            DispatchQueue.main.async {
                if granted {
                    print("Permissão de microfone concedida.")
                } else {
                    print("Permissão de microfone negada.")
                }
            }
            
        }
    }
    
  
}
