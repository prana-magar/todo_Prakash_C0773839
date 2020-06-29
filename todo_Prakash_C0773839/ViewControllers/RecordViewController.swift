//
//  RecordViewController.swift
//  SlickNotes
//
//  Created by Prakash on 2020-06-26.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit
import AVFoundation

protocol SendRecordingBack {
    func sendRecordingInfo(audioNames: [String])
}

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
    
    
    var delegate: SendRecordingBack? = nil
    
    // for recorder
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var currentAudioFileName: String = ""
    
    // for recorded view
    var audioStack: UIStackView!
    
    var audioNames: [String] = []
    var audioPlayers: [AudioPlayerView] = []
    
    var isRecording:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            print("error in audio")
            // failed to record!
        }
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
   
    
    func loadRecordingUI() {
        
        
        // control stack
        let controlStack = UIStackView()
        controlStack.axis = .vertical
        
        controlStack.translatesAutoresizingMaskIntoConstraints = false
        controlStack.backgroundColor = .red
        controlStack.alignment = .center
        controlStack.distribution = .equalCentering
        self.view.addSubview(controlStack)
        
     
        // button wrapper
        let wrapperView = UIView()
        wrapperView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        wrapperView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        controlStack.addArrangedSubview(wrapperView)
        
        
        // record btn
        let recordBtn = UIButton(type: .custom)
        recordBtn.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        recordBtn.layer.cornerRadius = 0.5 * recordBtn.bounds.size.width
        recordBtn.clipsToBounds = true
        recordBtn.layer.borderWidth = 5
        recordBtn.backgroundColor = .red
      
        recordBtn.addTarget(self, action: #selector(recordClicked(sender:)), for: .touchDown)
        
        
        wrapperView.addSubview(recordBtn)
        recordBtn.centerXAnchor.anchorWithOffset(to: wrapperView
            .centerXAnchor)

        
        // control stack constraints
        NSLayoutConstraint.activate([
            controlStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor ),
            
            controlStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            controlStack.heightAnchor.constraint(equalToConstant: 100)
            ,
            controlStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
            ]
        )
        
        
        
        // UI for saved audio
        
        
        // vertical stack
        audioStack = UIStackView()
        audioStack.translatesAutoresizingMaskIntoConstraints = false
        audioStack.axis = .vertical
        audioStack.alignment = .center
        audioStack.distribution = .fill
        
        view.addSubview(audioStack)
        
        NSLayoutConstraint.activate([
            audioStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            
            audioStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            
            audioStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            audioStack.heightAnchor.constraint(equalToConstant: 600)
            
        ])
        
        // audio view
   
        let spacer = UIView()
        spacer.backgroundColor = .blue
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        audioStack.addArrangedSubview(
            spacer
        )
       
        
        
     
    }
    
    
    @IBAction func doneBtnDown(_ sender: Any) {
        if delegate != nil {
            delegate?.sendRecordingInfo(audioNames: audioNames)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func recordClicked(sender: UIButton!){
        if(isRecording){
            // change btn ui
            UIView.animate(withDuration: 0.5, animations: {
                sender.setImage(nil, for: .normal)
                sender.backgroundColor  = .red
            }, completion: nil)
            
            sender.layer.removeAllAnimations()
            sender.alpha = 1
            // stop recording code and save
            recordTapped()
        }
        else{
            // start recording code
           recordTapped()
          
            // change btn ui
            UIView.animate(withDuration: 0.2, animations: {
                sender.backgroundColor  = .white
            },completion: {_ in
                UIView.animate(withDuration: 0.2, animations: {
                    let image = UIImage(named: "pausered") as UIImage?
                    sender.setImage(image, for: .normal)
                    sender.imageEdgeInsets = UIEdgeInsets(top: 20,left: 20,bottom: 20,right: 20)
                },completion: nil)
                
            })
            
            
            UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction, .curveEaseInOut], animations: {

                sender.alpha  = 0.5


            }, completion: nil)
     
        }
        
        // switch state
        isRecording = !isRecording
    }
    
    func startRecording() {
        
        var randomName = "\(UUID().uuidString).m4a"
        let audioFilename = getDocumentsDirectory().appendingPathComponent(randomName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            currentAudioFileName = randomName
           
            
        } catch {
            print(error)
            finishRecording(success: false)
        }
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        gesture.view?.shake()
           let alert = UIAlertController(
               title: "Confirm Delete",
               message: "",
               preferredStyle: .alert)
           
           
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in
                  print("Cancelled")
           })
           
           let okAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(alert: UIAlertAction!) in
                if let viewSwipped = gesture.view{
                    
                    let audioName = (viewSwipped as! AudioPlayerView).audioName
                    
                    self.audioNames.remove(at: self.audioNames.lastIndex(of: audioName)!)
                    
                    viewSwipped.removeFromSuperview()
                   
            }}
            )
           
           // add OK action
           alert.addAction(cancelAction)
           alert.addAction(okAction)

           // show alert
           self.present(alert, animated: true)
       
           
         
          
       }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        print("done recording")
        
        if success{
            audioNames.append(currentAudioFileName)
             let audioWrapper = AudioPlayerView()
             audioWrapper.setFileName(audioName: currentAudioFileName)
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
                    swipeLeft.direction = .left
            audioWrapper.addGestureRecognizer(swipeLeft)
             audioWrapper.isUserInteractionEnabled = true
             audioStack.addArrangedSubview(audioWrapper)
            audioStack.setCustomSpacing( 10, after: audioWrapper)
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
