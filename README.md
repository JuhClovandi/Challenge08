# PacoteSoundAnalysis

Um pacote Swift para **detectar estalos de dedos (finger snapping) em tempo real** utilizando o microfone do dispositivo.  
Ideal para apps que precisam reagir a sons específicos com ações personalizadas.

---

## ✨ Recursos
- Captura áudio em tempo real via `AVAudioEngine`.
- Análise de sons usando `SoundAnalysis` (classificador padrão da Apple).
- Callback simples sempre que um estalo for detectado com confiança alta.
- Compatível com **SwiftUI** ou **UIKit**.

---

## 📋 Requisitos
[![Swift](https://img.shields.io/badge/Swift-5.5-orange?logo=swift)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0%2B-blue?logo=apple)](https://developer.apple.com/ios/)
[![Xcode](https://img.shields.io/badge/Xcode-13%2B-blue?logo=xcode)](https://developer.apple.com/xcode/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📦 Instalação
Adicione o pacote ao seu projeto via **Swift Package Manager**:  
`File > Add Packages...` e insira a URL do repositório.

---

## ⚠️ Permissão obrigatória
Seu app precisa da permissão de **microfone**.  
No arquivo `Info.plist`, adicione:

```
**NSMicrophoneUsageDescription**
Descrição: Este app utiliza o microfone para detectar sons e executar ações por comando de áudio.
```
---

## Como usar

Exemplo em **SwiftUI**:

```swift
import SwiftUI
import PacoteSoundAnalysis

struct SuaView: View {

    // Cria um objeto para monitorar o audio.
    @StateObject private var audioManager = AudioManager()

    var body: some View {
        VStack {
            Text("Aguardando som")
        }
        .onAppear {
            // Inicia o detector de som
             audioManager.iniciarMonitor(onDetection: {
                
                // 1. Muda a cor para verde
                self.backgroundColor = .green
                
                // 3. Agenda a cor para voltar ao normal após 3 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.backgroundColor = .gray
                }
            } , classification: "whistling")
        }
        .onDisappear {
            // A garantia de que o monitor para quando a tela fecha continua aqui.
            // Isso é muito importante para economizar bateria.
            audioManager.pararMonitor()
        }
}
```
## 🛠 Frameworks Utilizados

- 🎙 **AVFoundation** → captura de áudio em tempo real  
- 🧠 **SoundAnalysis** → análise e classificação de sons  
- 🔗 **Combine** → entrega segura de eventos para a UI na *main thread*  


