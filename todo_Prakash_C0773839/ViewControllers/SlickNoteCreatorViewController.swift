//
//  SlickNoteCreatorViewController.swift
//  SlickNotes
//
//  Created by user166476 on 6/20/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation
import CoreData


class SlickNoteCreatorViewController : UIViewController, UITextViewDelegate,UINavigationControllerDelegate,  UIImagePickerControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    var managedContext: NSManagedObjectContext!

    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteTextTextView: UITextView!
    @IBOutlet weak var noteDoneButton: UIButton!
    @IBOutlet weak var noteDateLabel: UILabel!
    let locationManager = CLLocationManager()
    var userLocation: CLLocation!
    let categoryPicker = UIPickerView()
    var imagePicker: ImagePicker!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var isAudioRecordingGranted: Bool!
    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!

    
    private let noteCreationTimeStamp : Int64 = Date().toSeconds()
     var changingReallySimpleNote : SlickNotes?
    var folderSelectedName: String? 
    
    // MARK: note tile changed
    @IBAction func noteTitleChanged(_ sender: UITextField, forEvent event: UIEvent) {
        if self.changingReallySimpleNote != nil {
            // change mode
            noteDoneButton.isEnabled = true
        } else {
            // create mode
            if ( sender.text?.isEmpty ?? true ) || ( noteTextTextView.text?.isEmpty ?? true ) {
                noteDoneButton.isEnabled = false
            } else {
                noteDoneButton.isEnabled = true
            }
        }
    }
    
    
    // MARK: DoneBtnClicked
    @IBAction func doneButtonClicked(_ sender: UIButton, forEvent event: UIEvent) {
        // distinguish change mode and create mode
        if self.changingReallySimpleNote != nil {
            // change mode - change the item
            changeItem()
        } else {
            // create mode - create the item
            addItem()
        }
    }
    
    // MARK: Changing Simple Note
    func setChangingReallySimpleNote(changingReallySimpleNote : SlickNotes) {
        self.changingReallySimpleNote = changingReallySimpleNote
    }
    
    
    
    // MARK: addItem
    private func addItem() -> Void {
        
        let lat = userLocation.coordinate.latitude
        let long  = userLocation.coordinate.longitude
        
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: lat, longitude: long)){
            
            placemark, error in
            
            
            if let error = error as? CLError
            {
                print("CLError:", error)
                return
            }
                
            else if let placemark = placemark?[0]
            {
                
                
                var placeName = ""
                var city = ""
                var postalCode = ""
                var country = ""
                if let name = placemark.name { placeName += name }
                if let locality = placemark.subLocality { city += locality }
                if let code = placemark.postalCode { postalCode += code }
                if let countryName = placemark.country { country += countryName }
                
                var location = "\(placeName), \(country)"
                
                
//                let note = SlickNotes(
//                    noteTitle:     self.noteTitleTextField.text!,
//                    noteText:      self.noteTextTextView.text,
//                    noteTimeStamp: self.noteCreationTimeStamp,
//                    latitude: String(self.userLocation.coordinate.latitude),
//                    longitude: String(self.userLocation.coordinate.longitude),
//                    location: location,
//                    category: self.categoryTextField.text!
//
//                )
//
//
//                SlickNotesStorage.storage.addNote(noteToBeAdded: note)
//
                
                // pop to lister
                self.navigationController?.popToRootViewController(animated: true)
               
                          
                
            }
            
        }
        
    }
    
    // MARK: changeItem
    private func changeItem() -> Void {
        // get changed note instance
        if let changingReallySimpleNote = self.changingReallySimpleNote {
            // change the note through note storage
            let lat = userLocation.coordinate.latitude
            let long  = userLocation.coordinate.longitude
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: lat, longitude: long)){
                
                placemark, error in
                
                
                if let error = error as? CLError
                {
                    print("CLError:", error)
                    return
                }
                    
                else if let placemark = placemark?[0]
                {
                    
                    
                    var placeName = ""
                    var city = ""
                    var postalCode = ""
                    var country = ""
                    if let name = placemark.name { placeName += name }
                    if let locality = placemark.subLocality { city += locality }
                    if let code = placemark.postalCode { postalCode += code }
                    if let countryName = placemark.country { country += countryName }
                    
                    var location = "\(placeName), \(country)"
                    
                    
//                    SlickNotesStorage.storage.changeNote(
////                        noteToBeChanged: SlickNotes(
////                            noteId:        changingReallySimpleNote.noteId,
////                            noteTitle:     self.noteTitleTextField.text!,
////                            noteText:      self.noteTextTextView.text,
////                            noteTimeStamp: self.noteCreationTimeStamp,
////                            latitude: String(self.userLocation.coordinate.latitude),
////                            longitude: String(self.userLocation.coordinate.longitude),
////                            location: location,
////                            category: self.categoryTextField.text!
//                        )
//                    )
                    // navigate back to list of notes
                      // pop to lister
                    
                    print("i am here")
                    self.navigationController?.popViewController(animated: true)
        
                    
                }
                
            }
            
            
            
        } else {
            // create alert
            let alert = UIAlertController(
                title: "Unexpected error",
                message: "Cannot change the note, unexpected error occurred. Try again later.",
                preferredStyle: .alert)
            
            // add OK action
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default ) { (_) in self.performSegue(
                                            withIdentifier: "backToMasterView",
                                            sender: self)})
            // show alert
            self.present(alert, animated: true)
        }
    }
    
    // MARK: didLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        check_record_permission()
        setupRecorder()
        playButton.isEnabled = false
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                   // create alert
                   let alert = UIAlertController(
                       title: "Could not get app delegate",
                       message: "Could not get app delegate, unexpected error occurred. Try again later.",
                       preferredStyle: .alert)
                   
                   // add OK action
                   alert.addAction(UIAlertAction(title: "OK",
                                                 style: .default))
                   // show alert
                   self.present(alert, animated: true)
                   return
                   
               }
        managedContext = appDelegate.persistentContainer.viewContext
               
                // set context in the storage
        SlickCategoryStorage.storage.setManagedContext(managedObjectContext: managedContext)
             
        
        
        
        
        categoryTextField.inputView = categoryPicker
        categoryTextField.text = folderSelectedName
        categoryPicker.delegate = self
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        // set text view delegate so that we can react on text change
        noteTextTextView.delegate = self
        
        // Add delegate
        locationManager.delegate = self
        
        // request permission
        locationManager.requestWhenInUseAuthorization()
        
        // update map info
        locationManager.startUpdatingLocation()
        
        // check if we are in create mode or in change mode
        if let changingReallySimpleNote = self.changingReallySimpleNote {
            // in change mode: initialize for fields with data coming from note to be changed
            noteDateLabel.text = SlickNotesDateHelper.convertDate(date: Date.init(seconds: noteCreationTimeStamp))
            noteTextTextView.text = changingReallySimpleNote.noteText
            noteTitleTextField.text = changingReallySimpleNote.noteTitle
            // enable done button by default
            noteDoneButton.isEnabled = true
            
            
            let request: NSFetchRequest<Note> = Note.fetchRequest()
            request.predicate = NSPredicate(format: "noteId = %@", changingReallySimpleNote.noteId as! CVarArg)
            var note: Note? = nil
            do {
                let notes = try self.managedContext.fetch(request)
                if notes.count > 0 {
                    note = notes[0]
                }
                
            } catch {
                print("Error loading folders \(error.localizedDescription)")
            }
            
            if note != nil {
                categoryTextField.text = note?.parent?.categoryName ?? "All"
            }
            else{
                categoryTextField.text = "All"
            }
            
        } else {
            // in create mode: set initial time stamp label
            noteDateLabel.text = SlickNotesDateHelper.convertDate(date: Date.init(seconds: noteCreationTimeStamp))
        }
        
        // initialize text view UI - border width, radius and color
        noteTextTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        noteTextTextView.layer.borderWidth = 1.0
        noteTextTextView.layer.cornerRadius = 5
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        // For back button in navigation bar, change text
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    // MARK: dismissKeyBoard
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    // MARK: textViewDidChange
    //Handle the text changes here
    func textViewDidChange(_ textView: UITextView) {
        if self.changingReallySimpleNote != nil {
            // change mode
            noteDoneButton.isEnabled = true
        } else {
            // create mode
            if ( noteTitleTextField.text?.isEmpty ?? true ) || ( textView.text?.isEmpty ?? true ) {
                noteDoneButton.isEnabled = false
            } else {
                noteDoneButton.isEnabled = true
            }
        }
    }
    
    
    // MARK: camera show Image
    @IBAction func cameraShowImage(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    /*_________________________________________________________________
                Methods for voice recording starts
        ______________________________________________________________*/
    
    
    
    
    func check_record_permission()
    {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                    if allowed {
                        self.isAudioRecordingGranted = true
                    } else {
                        self.isAudioRecordingGranted = false
                    }
            })
            break
        default:
            break
        }
    }
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func getFileUrl() -> URL
    {
        let filename = "myRecording.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
    return filePath
    }
    
    func setupRecorder() {
        
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try session.setActive(true)
            let recordSetting = [ AVFormatIDKey : kAudioFormatAppleLossless,
                                  AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                                  AVEncoderBitRateKey : 320000,
                                  AVNumberOfChannelsKey : 2,
                                  AVSampleRateKey : 44100.2] as [String : Any]
            
            soundRecorder = try AVAudioRecorder(url: getFileUrl(), settings: recordSetting )
            soundRecorder.delegate = self as? AVAudioRecorderDelegate
            soundRecorder.prepareToRecord()
        }
        catch {
            print(error)
              }
        }
            else
            {
        let alert = UIAlertController(title: "Access to mic denied", message: "You denied us from accessing your microphone, to record the voice please grant us access in your settinga.", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                self.present(alert, animated: true)
            }

    }
    
    
    func setupPlayer() {
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        } catch {
            print(error)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playButton.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let play = UIImage(systemName: "play.fill")
       recordButton.isEnabled = true
       playButton.setImage(play, for: .normal)
    }
    
    
    
    @IBAction func recordSound(_ sender: Any) {
        
        
        let stop = UIImage(systemName: "stop.fill")
        let record = UIImage(systemName: "mic.fill")
        
        
        if recordButton.titleLabel?.text == "r" {
                soundRecorder.record()
                recordButton.setImage(stop, for: .normal)
                recordButton.setTitle("s", for: .normal)
                playButton.isEnabled = false
            } else if recordButton.titleLabel?.text == "s"{
                soundRecorder.stop()
                recordButton.setImage(record, for: .normal)
                recordButton.setTitle("r", for: .normal)
                playButton.isEnabled = true
            }
        else{
            return
        }
        }
        
    
    
    @IBAction func playSound(_ sender: Any) {
        
        let stop = UIImage(systemName: "stop.fill")
        let play = UIImage(systemName: "play.fill")
        
            if playButton.titleLabel?.text == "p" {
                
                do{
                    FileManager.default.fileExists(atPath: getFileUrl().path)
                }
                catch{
                    print(error)
                }
                       playButton.setImage(stop, for: .normal)
                playButton.setTitle("S", for: .normal)
                       recordButton.isEnabled = false
                       setupPlayer()
                       soundPlayer.play()
                   }
            else if playButton.titleLabel?.text == "S"  {
                       soundPlayer.stop()
                       playButton.setImage(play, for: .normal)
                    playButton.setTitle("p", for: .normal)
                       recordButton.isEnabled = true
                   }
            else{
                return
                }
        }
}
    

// MARK extension CLLocationManager
extension SlickNoteCreatorViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        
        
    }
}


// MARK: ImagePicker
extension SlickNoteCreatorViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        self.imageView.image = image
    }
}


extension SlickNoteCreatorViewController:  UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let categories = SlickCategoryStorage.storage.readCategories(){
            return categories.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if let categories = SlickCategoryStorage.storage.readCategories(){
            return categories[row].categoryName
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let categories = SlickCategoryStorage.storage.readCategories(){
            categoryTextField.text = categories[row].categoryName
        }
    }
}
