//
//  ContentView.swift
//  Bridge
//
//  Created by Anthony Silvia on 8/9/24.
//
import SwiftUI
import AVFoundation
import Speech
import Combine

class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var captionedText = ""
    @Published var isListening = false
    @Published var isPersonalVoiceAvailable = false
    @Published var isSpeaking = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private let synthesizer = AVSpeechSynthesizer()
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupAudioSession()
        checkPersonalVoiceAvailability()
        synthesizer.delegate = self
        
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in self?.stopListening() }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in self?.startListening() }
            .store(in: &cancellables)
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func checkPersonalVoiceAvailability() {
        isPersonalVoiceAvailable = AVSpeechSynthesisVoice.speechVoices().contains(where: { $0.identifier == "com.apple.speech.synthesis.voice.premium.en-US" })
    }
    
    func speakText(_ text: String, voice: AVSpeechSynthesisVoice?) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice ?? AVSpeechSynthesisVoice(language: "en-US")
        
        // Pause recognition before speaking
        pauseRecognition()
        
        synthesizer.speak(utterance)
    }
    
    func startListening() {
        guard !isListening else { return }
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self, let result = result else {
                if let error = error {
                    print("Recognition error: \(error.localizedDescription)")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.captionedText = result.bestTranscription.formattedString
            }
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isListening = true
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
    }
    
    private func pauseRecognition() {
        audioEngine.pause()
    }
    
    private func resumeRecognition() {
        do {
            try audioEngine.start()
        } catch {
            print("Failed to resume audio engine: \(error.localizedDescription)")
        }
    }
    
    // AVSpeechSynthesizerDelegate methods
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.resumeRecognition()
        }
    }
}

struct ContentView: View {
    @StateObject private var speechManager = SpeechManager()
    @State private var inputText = ""
    @State private var selectedVoice: AVSpeechSynthesisVoice?
    
    var body: some View {
        VStack {
            Text("Captions:")
                .font(.headline)
                .padding(.top)
            
            Text(speechManager.captionedText)
                .padding()
        }
        .frame(height: 400)
        VStack {
            Text("Listening Status: \(speechManager.isListening ? "Active" : "Inactive")")
                .padding()
            HStack {
                Spacer()
                HStack {
                    TextField("Type to speak", text: $inputText)
                        .glassyTextFieldStyle()                    .padding()
                    
                    Button(action: { speechManager.speakText(inputText, voice: selectedVoice) }) {
                        Text("Speak")
                    }
                    .buttonStyle(CustomizableButtonStyle(style: .glassy, labelColor: .accentColor))
                }
                .padding()
                .disabled(speechManager.isSpeaking)
                Spacer()
            }
            
            if speechManager.isPersonalVoiceAvailable {
                Picker("Select Voice", selection: $selectedVoice) {
                    Text("System Voice").tag(nil as AVSpeechSynthesisVoice?)
                    Text("Personal Voice").tag(AVSpeechSynthesisVoice(identifier: "com.apple.speech.synthesis.voice.premium.en-US")!)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
        }
        .onAppear {
            requestSpeechAuthorization()
            speechManager.startListening()
        }
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Speech recognition authorized")
                    speechManager.startListening()
                } else {
                    print("Speech recognition not authorized")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
