//
//  AudioManager.swift
//  PacoteSoundAnalysis
//
//  Created by Keitiely Silva Viana on 26/09/25.
//

import Foundation
import AVFoundation


public class AudioManager {
    public let audioEngine = AVAudioEngine()
    
    public init() {}
    
    public func start() throws {
            let inputNode = audioEngine.inputNode
            let format = inputNode.inputFormat(forBus: 0)

            inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, when in
                print("Recebi buffer: \(buffer.frameLength) frames")
            }

            audioEngine.prepare()
            try audioEngine.start()
        }
    
}

