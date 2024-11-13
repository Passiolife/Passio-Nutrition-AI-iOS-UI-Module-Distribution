//
//  VoiceLoggingViewController.swift
//  
//
//  Created by Nikunj Prajapati on 07/06/24.
//

import UIKit
import Lottie
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol VoiceLoggingDelegate: AnyObject {
    func goToSearch()
}

class VoiceLoggingViewController: InstantiableViewController {

    @IBOutlet weak var generatingResultsLabel: UILabel!
    @IBOutlet weak var voiceLoggingLottieView: LottieAnimationView!
    @IBOutlet weak var speechTextView: UITextView!
    @IBOutlet weak var generatingResultsStackView: UIStackView!
    @IBOutlet weak var speechActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var startListeningLabel: UILabel!
    @IBOutlet weak var startListeningStackView: UIStackView!
    @IBOutlet weak var startListeningButton: UIButton!

    private var speechRecognizer = SpeechRecognizer()
    private var isRecording = false
    private var isRecognitionUnavailable = false
    private var resultsLoggingView: ResultsLoggingView!

    var goToSearch: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func onStartListening(_ sender: UIButton) {

        let image: String
        let title: String

        if sender.isSelected { // hide lottie
            voiceLoggingLottieView.stop()
            voiceLoggingLottieView.isHidden = true
            startListeningButton.isHidden = true
            speechActivityIndicator.startAnimating()
            generatingResultsStackView.isHidden = false
            onRecognise()
            speechRecognizer.stopTranscribing()
            isRecording = false
            speechTextView.text = speechRecognizer.transcript
            image = "mic.fill"
            title = "Start Listening"

        } else { // show lottie
            startListeningStackView.isHidden = true
            clearVoiceTextView()
            speechRecognizer.transcript = ""
            speechRecognizer.startTranscribing()
            isRecording = true
            loadVoiceLoggingLottie()
            title = "Stop Listening"
            image = "stop.circle.fill"
        }

        sender.setImage(UIImage(systemName: image), for: .normal)
        sender.setTitle(title, for: .normal)
        sender.isSelected = !sender.isSelected
    }

    // MARK: Helper
    private func configureUI() {

        title = "Voice Logging"
        generatingResultsLabel.font = UIFont.inter(type: .medium, size: 15)

        speechTextView.delegate = self
        speechRecognizer.listener = self

        setupBackButton()
        startListeningButton.backgroundColor = .primaryColor
        let normalText = "Tap Start Listening, then say something like:".toMutableAttributedString
        normalText.apply(font: UIFont.inter(type: .regular, size: 18), subString: "Start Listening")
        normalText.apply(attribute: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.gray900
        ], subString: "Start Listening")
        startListeningLabel.attributedText = normalText
    }

    private func loadVoiceLoggingLottie() {
        voiceLoggingLottieView.isHidden = false
        voiceLoggingLottieView.animation =  LottieAnimation.named("VoiceLogging", bundle: .module)
        voiceLoggingLottieView.contentMode = .scaleToFill
        voiceLoggingLottieView.loopMode = .autoReverse
        voiceLoggingLottieView.play()
    }

    private func clearVoiceTextView() {
        speechTextView.resignFirstResponder()
        speechTextView.text = ""
    }

    private func onRecognise() {

        let text = speechTextView.text!
        if text == "" {
            clearVoiceTextView()
            hideActivityIndicator()
            return
        }

        PassioNutritionAI.shared.recognizeSpeechRemote(from: text) { [weak self] recognitionResult in
            guard let self else { return }
            self.hideActivityIndicator()
            self.loadResultLoggingView(recognitionData: recognitionResult)
        }
        clearVoiceTextView()
    }

    private func loadResultLoggingView(recognitionData: [PassioSpeechRecognitionModel]) {

        DispatchQueue.main.async { [self] in

            resultsLoggingView = ResultsLoggingView.fromNib(bundle: .module)
            resultsLoggingView.resultLoggingDelegate = self
            resultsLoggingView.recognitionData = recognitionData
            view.addSubview(resultsLoggingView)
            resultsLoggingView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints(to: resultsLoggingView, attribute: .leading, constant: 0)
            view.addConstraints(to: resultsLoggingView, attribute: .trailing, constant: 0)
            view.addConstraints(to: resultsLoggingView, attribute: .bottom, constant: 0)
        }
    }

    private func hideActivityIndicator() {
        DispatchQueue.main.async { [self] in
            speechActivityIndicator.stopAnimating()
            generatingResultsStackView.isHidden = true
        }
    }
}

// MARK: - SpeechListener Delegate
extension VoiceLoggingViewController: ResultsLoggingDelegate {

    func onTryAgainTapped() {
        resultsLoggingView?.removeFromSuperview()
        clearVoiceTextView()
        startListeningButton.isHidden = false
        startListeningStackView.isHidden = false
        speechTextView.isHidden = true
    }

    func onLogSelectedTapped() {
        NutritionUICoordinator.navigateToDairyAfterAction(navigationController: navigationController)
    }

    func onSearchManuallyTapped() {
        navigationController?.popViewController(animated: true) { [weak self] in
            self?.goToSearch?()
        }
    }
}

// MARK: - SpeechListener Delegate
extension VoiceLoggingViewController: SpeechListener {

    func didError(error: any Error) {
        showAlertWith(titleKey: "Recognition error: \(error.localizedDescription)", view: self)
        onTryAgainTapped()
    }

    func didChange(availability available: Bool) {
        isRecognitionUnavailable = !available
        if !available && isRecording {
            isRecording = false
            speechRecognizer.stopTranscribing()
        }
    }

    func hear(words: String) {
        if words != "" {
            speechTextView.isHidden = false
            speechTextView.text = words
        }
    }
}

// MARK: - UITextViewDelegate
extension VoiceLoggingViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        speechTextView.text = ""
    }
}
