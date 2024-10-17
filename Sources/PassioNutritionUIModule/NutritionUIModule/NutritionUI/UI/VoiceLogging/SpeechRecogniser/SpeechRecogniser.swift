//
//  SpeechRecogniser.swift
//  BaseApp
//
//  Created by Mind on 01/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
import AVFoundation
import Speech

public protocol SpeechListener {
    func didError(error: Error)
    func didChange(availability available: Bool)
    func hear(words: String)
}

class SpeechRecognizerDelegationRetroreflector: NSObject, SFSpeechRecognizerDelegate {

    let recognizer: SpeechRecognizer

    init(recognizer: SpeechRecognizer) {
        self.recognizer = recognizer
    }

    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer,
                                 availabilityDidChange available: Bool) {
        Task {
            await recognizer.didChange(availability: available)
        }
    }
}

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
public actor SpeechRecognizer: ObservableObject {

    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable

        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }

    @MainActor public var transcript: String = ""
    @MainActor public var listener: (any SpeechListener)?

    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    private var delegationRetroreflector: SpeechRecognizerDelegationRetroreflector?
    
    /**
     Initializes a new speech recognizer. If this is the first time you've used the class, it
     requests access to the speech recognizer and the microphone.
     */
    public init(isLocalisable: Bool = false) {
        delegationRetroreflector = nil
        
        if isLocalisable, let language = PassioUserDefaults.getLanguage() {
            let locale = Locale.init(identifier: language.ISOCode)
            recognizer = SFSpeechRecognizer(locale: locale)
        } else {
            recognizer = SFSpeechRecognizer()
        }
        
        guard recognizer != nil else {
            transcribe(RecognizerError.nilRecognizer)
            return
        }

        Task {
            await initDelegate()
            do {
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                transcribe(error)
            }
        }
    }

    @MainActor public func startTranscribing() {
        Task {
            await transcribe()
        }
    }

    @MainActor public func resetTranscript() {
        Task {
            await reset()
        }
    }

    @MainActor public func stopTranscribing() {
        Task {
            await reset()
        }
    }

    /**
     Begin transcribing audio.

     Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
     The resulting transcription is continuously written to the published `transcript` property.
     */
    private func transcribe() {
        guard let recognizer, recognizer.isAvailable else {
            transcribe(RecognizerError.recognizerIsUnavailable)
            return
        }

        do {
            let (audioEngine, request) = try prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            self.task = recognizer.recognitionTask(with: request) {
                [weak self] result, error in
                self?.recognitionHandler(audioEngine: audioEngine,
                                         result: result,
                                         error: error)
            }
        } catch {
            self.reset()
            self.transcribe(error)
        }
    }

    /// Reset the speech recognizer.
    private func reset() {
        task?.finish()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }

    private func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(
            .record,  // https://developer.apple.com/documentation/avfaudio/avaudiosession/category
            mode: .measurement,  // https://developer.apple.com/documentation/avfaudio/avaudiosession/mode
            options: [.allowBluetooth]  // https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions
        )
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let audioEngine = AVAudioEngine()
        let inputBus = 0
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: inputBus)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if #available(iOS 16, *) {
            request.addsPunctuation = true
        } else {
            // Fallback on earlier versions
        }
        request.contextualStrings = ["merguez"]    // Unusual food names, <100; https://developer.apple.com/documentation/speech/sfspeechrecognitionrequest/1649391-contextualstrings
        if let recognizer = recognizer {
            if recognizer.supportsOnDeviceRecognition {  // https://developer.apple.com/documentation/speech/sfspeechrecognizer/3152604-supportsondevicerecognition
                // Beware https://forums.developer.apple.com/forums/thread/739006
                request.requiresOnDeviceRecognition = true  // https://developer.apple.com/documentation/speech/sfspeechrecognitionrequest/3152603-requiresondevicerecognition
            } else {
                print("On-device recognition is not supported on this device/OS.")
            }
        }

        inputNode.installTap(onBus: inputBus,
                             bufferSize: 1024,
                             format: recordingFormat) { (buffer: AVAudioPCMBuffer,
                                                         when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()

        return (audioEngine, request)
    }

    private func initDelegate() {
        Task {
            delegationRetroreflector = SpeechRecognizerDelegationRetroreflector(recognizer: self)
            recognizer?.delegate = delegationRetroreflector
        }
    }

    public func didChange(availability available: Bool) {
        Task { @MainActor in
            if let listener = listener {
                listener.didChange(availability: available)
            }
        }
    }

    nonisolated private func recognitionHandler(audioEngine: AVAudioEngine,
                                                result: SFSpeechRecognitionResult?,
                                                error: Error?) {

        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil

        if receivedFinalResult || receivedError {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        if let error = error {
            let errorString = String(describing: error)
            if errorString.contains("Domain=kLSRErrorDomain")
                && errorString.contains("Code=201") {
                // https://forums.developer.apple.com/forums/thread/739006
                Task { @MainActor in
                    if let listener = listener {
                        listener.didChange(availability: false)
                    }
                }
            } else {
                Task { @MainActor in
                    if let listener = listener {
                        listener.didError(error: error)
                    }
                }
            }
        } else if let result {
            transcribe(result.bestTranscription.formattedString)
        }
    }


    nonisolated private func transcribe(_ message: String) {
        Task { @MainActor in
            transcript = message
            if let listener = listener  {
                listener.hear(words: message)
            }
        }
    }

    nonisolated private func transcribe(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        Task { @MainActor [errorMessage] in
            transcript = "<< \(errorMessage) >>"
            if let listener = listener  {
                listener.didError(error: error)
            }
        }
    }
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
