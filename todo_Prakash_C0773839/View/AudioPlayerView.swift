//
//  AudioPlayerView.swift
//  SlickNotes
//
//  Created by Prakash on 2020-06-27.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit
import AVFoundation


class AudioPlayerView: UIView{
    
    var isPlaying: Bool = false
    var fileNamelabel: UILabel = {
        let fileNamelabel = UILabel()
       fileNamelabel.font = UIFont(name: "Montserrat-Black", size: 15)
       fileNamelabel.translatesAutoresizingMaskIntoConstraints = false
       fileNamelabel.textColor = .white
        return fileNamelabel
        
    }()
    var audioName: String = "recording.m4a" {
        didSet{
            fileNamelabel.text =  "\(audioName.prefix(5)).m4a"
            setUp()
        }
    }
    
    var player = AVAudioPlayer()
    
    var timer = Timer()
    
    var playBtn : UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(named: "play")
        btn.tintColor = .white
        btn.setImage(image, for: .normal)
//        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 70)
        btn.addTarget(self, action: #selector(playPauseClicked(sender:)), for: .touchDown)
        btn.translatesAutoresizingMaskIntoConstraints = false

        return btn
    }()
    
    
    var audioSlider : UISlider  = {
        let slider = UISlider()
        slider.thumbTintColor = .red
        let image = UIImage(named: "circle")
        slider.setThumbImage(image, for: .normal)
        slider.setThumbImage(image, for: .focused)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderMoved), for: .valueChanged)
        
        slider.minimumTrackTintColor = .red
        slider.maximumTrackTintColor = .white
        return slider
    }()
    
    var audioLengthLabel: UILabel = {
        let label =  UILabel()
        label.text = "00:00"
        label.font = UIFont(name: "Montserrat-Black", size: 13)
        label.textColor = .white
        return label
    }()
    
    var audioCurrentLabel: UILabel = {
        let label =  UILabel()
        label.text = "00:00"
        label.font = UIFont(name: "Montserrat-Black", size: 13)
        label.textColor = .white
        return label
    }()
    
    var vStackView: UIStackView  = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()
    
    var headerHStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.axis = .horizontal
        return view
    }()
    
    var seekHStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .center
        view.axis = .horizontal
        return view
    }()
    
    var controlsHStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .center
        view.axis = .horizontal
        return view
    }()
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    @objc func playPauseClicked(sender: UIButton!){
        if isPlaying{
            // pause the player
            player.pause()
            
            // pause the slider
            timer.invalidate()
            
            
            // update ui
            UIView.animate(withDuration: 0.4) {
                let image = UIImage(named: "play")
                self.playBtn.setImage(image, for: .normal)
            }
        }
        else{
            
            // play the player
            player.play()
            
            // play the slider
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateScrubber), userInfo: nil, repeats: true)

            
            // update ui
            
            UIView.animate(withDuration: 0.4) {
                   let image = UIImage(named: "pause")
                   self.playBtn.setImage(image, for: .normal)
            }
        }
        
        // flip state
        isPlaying = !isPlaying
    }
    
    
    
    func setUp(){
        let path  = getDocumentsDirectory().appendingPathComponent(audioName)
         print(path)
         do {
             try player = AVAudioPlayer(contentsOf: path)

             let duration = player.duration
             let seconds = Int(ceil(duration))
             audioLengthLabel.text = String(format: "%02d:%02d", ((Int)((seconds))) / 60, ((Int)((seconds))) % 60)
             
             audioSlider.maximumValue = Float(player.duration)
        } catch {
            print(error)
        }
        
        
        
    }
    
    
    func setFileName(audioName: String){
        self.audioName = audioName
        setUp()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
 
        setUp()
        
        
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = .init(width: 4, height: 4)
        self.layer.shadowRadius = 6

        // set the anchor
         backgroundColor = .black
         self.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
                  self.heightAnchor.constraint(equalToConstant: 120),
                  self.widthAnchor.constraint(equalToConstant: 350),
              
             ]
         )
         
         addSubview(vStackView)
         
         NSLayoutConstraint.activate([
         
             vStackView.topAnchor.constraint(equalTo: topAnchor),
             vStackView.bottomAnchor.constraint(equalTo: bottomAnchor
             ),
             vStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
             vStackView.leadingAnchor.constraint(equalTo: leadingAnchor
             )
        
         ])
         
         
         vStackView.addArrangedSubview(headerHStack)
         vStackView.addArrangedSubview(seekHStack)
         vStackView.addArrangedSubview(controlsHStack)
        
        vStackView.setCustomSpacing(10, after: headerHStack)
        vStackView.setCustomSpacing(10, after: seekHStack)
        vStackView.setCustomSpacing(10, after: controlsHStack)
        
        vStackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        vStackView.isLayoutMarginsRelativeArrangement = true
         
         // setup headers
        
        fileNamelabel.text = audioName
        headerHStack.addArrangedSubview(fileNamelabel)
        
         
         // setUp internal views
         
         seekHStack.addArrangedSubview(audioCurrentLabel)
         seekHStack.addArrangedSubview(audioSlider)
         seekHStack.addArrangedSubview(audioLengthLabel)
         seekHStack.setCustomSpacing(5, after: audioCurrentLabel)
         seekHStack.setCustomSpacing(5, after: audioSlider)
         seekHStack.setCustomSpacing(5, after: audioLengthLabel)
         
         
         
         // add controls
         controlsHStack.addArrangedSubview(playBtn)
        
        
       
        
    }
    
    @objc func updateScrubber() {
        audioSlider.value = Float(player.currentTime)
        audioCurrentLabel.text = String(format: "%02d:%02d", ((Int)(ceil((player.currentTime)))) / 60, ((Int)(ceil((player.currentTime)))) % 60)
        if audioSlider.value == audioSlider.minimumValue {
            isPlaying = false
            UIView.animate(withDuration: 0.4) {
                           let image = UIImage(named: "play")
                           self.playBtn.setImage(image, for: .normal)
                       }
            
        }
    }
    
    @objc func sliderMoved(_ sender: UISlider) {
        player.currentTime = TimeInterval(audioSlider.value)
        audioCurrentLabel.text = String(format: "%02d:%02d", ((Int)(ceil((player.currentTime)))) / 60, ((Int)(ceil((player.currentTime)))) % 60)
        if isPlaying {
            player.play()
        }
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
