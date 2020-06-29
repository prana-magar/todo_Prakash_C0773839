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


class SlickCreateNoteViewController : UIViewController, UINavigationControllerDelegate,  UIImagePickerControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    var managedContext: NSManagedObjectContext!
    let locationManager = CLLocationManager()
    var userLocation: CLLocation!
    let categoryPicker = UIPickerView()
    let datePicker = UIDatePicker()
    
   
    
    
    // UI elements
    var scrollView: UIScrollView! = nil
    var vstackView:UIStackView! = nil
    var textViewTitle: UITextView!
    var categoryTextField: UITextField!
    var dueDateTextField: UITextField!

    var noteDateLabel: UITextField!
    var textView1: UITextView!
    var isEditMode: Bool = false
    
    var viewsList: [UIView] = []
    
    
    private let noteCreationTimeStamp : Int64 = Date().toSeconds()
    var changingReallySimpleNote : SlickNotes? {
        didSet{
            isEditMode = true
           
        }
    }
    var folderSelectedName: String?
    
    // MARK: note tile changed
    @IBAction func noteTitleChanged(_ sender: UITextField, forEvent event: UIEvent) {
//        if self.changingReallySimpleNote != nil {
//            // change mode
//            noteDoneButton.isEnabled = true
//        } else {
//            // create mode
//            if ( sender.text?.isEmpty ?? true ) || ( noteTextTextView.text?.isEmpty ?? true ) {
//                noteDoneButton.isEnabled = false
//            } else {
//                noteDoneButton.isEnabled = true
//            }
//        }
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

              let dateFormatter = DateFormatter()
              dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
              dateFormatter.dateFormat = "dd/MM/yyyy"
                let date = dateFormatter.date(from: self.dueDateTextField.text!)!
              
                
                let note = SlickNotes(
                    noteTitle:     self.textViewTitle.text,
                    noteText:      self.textView1.text,
                    noteTimeStamp: date,
                    latitude: String(self.userLocation.coordinate.latitude),
                    longitude: String(self.userLocation.coordinate.longitude),
                    location: location,
                    category: self.categoryTextField.text!
                   
                    
                )


                SlickNotesStorage.storage.addNote(noteToBeAdded: note)
                
                self.scheduleNotification(date: Calendar.current.date(byAdding: .day, value: -1, to: date)!, taskName:  self.textViewTitle.text)

                // pop to lister
                self.navigationController?.popToRootViewController(animated: true)



            }

        }
        
    }
    
    func scheduleNotification(date: Date, taskName: String) {
        
        let center = UNUserNotificationCenter.current()
                      center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                          if granted {
                              print("Yay!")
                          } else {
                              print("D'oh")
                          }
                      }

        let content = UNMutableNotificationContent()
        content.title = "Task Due Tomorrow"
        content.body = "\(taskName) is due tomorrow"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request){ (error) in
            if error != nil {
                print(error ?? "notification center error")
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

                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    let date = dateFormatter.date(from: self.dueDateTextField.text!)!
                    

               
                    let note = SlickNotes(noteId: changingReallySimpleNote.noteId,
                        noteTitle:     self.textViewTitle.text,
                        noteText:      self.textView1.text,
                        noteTimeStamp: date,
                        latitude: String(self.userLocation.coordinate.latitude),
                        longitude: String(self.userLocation.coordinate.longitude),
                        location: location,
                        category: self.categoryTextField.text!
                       
                        
                    )


                    SlickNotesStorage.storage.changeNote(noteToBeChanged: note)

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
    
    
   
    
    
    
   
    
    @objc func donePicker() {

        categoryTextField.resignFirstResponder()

    }

    
    
    func setUpView(){
        
        
        // clear layout
        
        if scrollView != nil {
             scrollView.removeFromSuperview()
        }
        
        // Add title
        
        textViewTitle = UITextView()
        
        if changingReallySimpleNote == nil {
            textViewTitle.text = "Enter Task Name"
            textViewTitle.textColor = UIColor.lightGray
        }
        else{
            textViewTitle.text = changingReallySimpleNote?.noteTitle

        }
      
        textViewTitle.textAlignment = .center
        viewsList.append(textViewTitle)
       
       textViewTitle.heightAnchor.constraint(equalToConstant: 20).isActive = true
       textViewTitle.delegate = self
       textViewTitle.isScrollEnabled = false
        textViewTitle.font = UIFont.preferredFont(forTextStyle: .largeTitle)
       textViewDidChange(textViewTitle)
        
        // Add date
        let dueDateLabel = UILabel()
       dueDateLabel.text = "Due Date: "
       dueDateLabel.font = UIFont.preferredFont(forTextStyle: .headline)
       dueDateLabel.textAlignment = .right
        
        
        dueDateTextField =  UITextField()
        dueDateTextField.layer.borderWidth = 2
        dueDateTextField.font = UIFont.preferredFont(forTextStyle: .headline)
        dueDateTextField.textAlignment = .center
        dueDateTextField.inputView = datePicker
        
        if changingReallySimpleNote == nil {
            dueDateTextField.text = SlickNotesDateHelper.convertDateStandard(date: Date())
        }
        else{
            
            dueDateTextField.text = SlickNotesDateHelper.convertDateStandard(date: changingReallySimpleNote!.noteTimeStamp)
        }

        datePicker.datePickerMode = .date
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let dateDoneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let dateSpaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let dateCancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([dateDoneButton,dateSpaceButton,dateCancelButton], animated: false)
        
        dueDateTextField.inputAccessoryView = toolbar
        
        let dueDatehStack = UIStackView(arrangedSubviews: [ dueDateLabel,dueDateTextField])
        dueDatehStack.distribution = .fillEqually
        dueDatehStack.alignment = .center
        

        viewsList.append(dueDatehStack)
   
        // Add a horizontal line
        let hr = UIView()
        hr.backgroundColor = .black
        hr.translatesAutoresizingMaskIntoConstraints = false
        hr.heightAnchor.constraint(equalToConstant: 5)
        hr.widthAnchor.constraint(equalToConstant: 50)
        viewsList.append(hr)

        
        
        // Add category
        
        let categoryLabel = UILabel()
        categoryLabel.text = "Category: "
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        categoryLabel.textAlignment = .right
        
        
        
        categoryTextField = UITextField()
        categoryTextField.inputView = categoryPicker
        categoryTextField.text = folderSelectedName
        categoryTextField.textAlignment = .center
        categoryTextField.font = UIFont.preferredFont(forTextStyle: .headline)
        categoryTextField.layer.borderWidth = 2
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        categoryTextField.inputAccessoryView = toolBar
        
    
        
        let hStack = UIStackView(arrangedSubviews: [ categoryLabel,categoryTextField])
        hStack.distribution = .fillEqually
        hStack.alignment = .center
        viewsList.append(hStack)

        
        
        // add first Text view
        textView1 = UITextView()
        
        
        if let detailText = changingReallySimpleNote{
            textView1.text = detailText.noteText
        }
        else{
            textView1.text = "Enter Task Description"
            textView1.textColor = UIColor.lightGray

        }
        textView1.textAlignment = .left
        
        
        textView1.heightAnchor.constraint(equalToConstant: 200).isActive = true
        textView1.delegate = self
        textView1.isScrollEnabled = false
        textView1.font = UIFont.preferredFont(forTextStyle: .headline)
        textViewDidChange(textView1)
        
        
        viewsList.append(textView1)
        
        
        
       
        
        // add scroll view and vertical stack
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        //        textView1.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            
            
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
        
        
       
        vstackView = UIStackView(arrangedSubviews:  viewsList)
        for view in viewsList{
            vstackView.setCustomSpacing(10, after: view)
        }
        vstackView.translatesAutoresizingMaskIntoConstraints = false
        vstackView.distribution = .fill
        vstackView.axis = .vertical
        
        
        scrollView.addSubview(vstackView)
        
        vstackView.backgroundColor = .red
        
        NSLayoutConstraint.activate([
            vstackView.topAnchor.constraint(equalTo:
                scrollView.topAnchor
            ),
            
            
            vstackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15
            ),
            
            vstackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 15
            ),
            
            vstackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            vstackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor,constant: -30 )
            
            //              vstackView.heightAnchor.constraint(equalToConstant: 2000)
            
            
            
        ])
        
    }
    @IBAction func saveNoteBtnDown(_ sender: Any) {
        
        if self.changingReallySimpleNote != nil {
                  // change mode - change the item
                  changeItem()
              } else {
                  // create mode - create the item
                  addItem()
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
                self.viewsList.remove(at: self.viewsList.index(of: viewSwipped)!)
                     viewSwipped.removeFromSuperview()
                 }
        })
        
        // add OK action
        alert.addAction(cancelAction)
        alert.addAction(okAction)

        // show alert
        self.present(alert, animated: true)
    
        
      
       
    }
    @objc func keyboardWillShow(notification:NSNotification){

        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 40
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification){

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
     @objc func donedatePicker(){

      let formatter = DateFormatter()
      formatter.dateFormat = "dd/MM/yyyy"
      dueDateTextField.text = formatter.string(from: datePicker.date)
      self.view.endEditing(true)
    }

    @objc func cancelDatePicker(){
       self.view.endEditing(true)
     }
    
    // MARK: didLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                   // create alert
                   let alert = UIAlertController(
                       title: "Could note get app delegate",
                       message: "Could note get app delegate, unexpected error occurred. Try again later.",
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
            
        
         
        setUpView()
        

        
      
        
        categoryPicker.delegate = self

        
        // Add delegate
        locationManager.delegate = self
        
        // request permission
        locationManager.requestWhenInUseAuthorization()
        
        // update map info
        locationManager.startUpdatingLocation()
        
        // check if we are in create mode or in change mode
        if let changingReallySimpleNote = self.changingReallySimpleNote {
            // in change mode: initialize for fields with data coming from note to be changed
           
            textViewTitle.text = changingReallySimpleNote.noteTitle
//            noteTitleTextField.text = changingReallySimpleNote.noteTitle
            // enable done button by default
//            noteDoneButton.isEnabled = true
            
            
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
          
        }
        
       
    }
    
    // MARK: dismissKeyBoard
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    
    
    
}


// MARK extension CLLocationManager
extension SlickCreateNoteViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        
        
    }
    
    

}





extension SlickCreateNoteViewController:  UIPickerViewDelegate, UIPickerViewDataSource{
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




// text view customization
extension SlickCreateNoteViewController: UITextViewDelegate{
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            
            if textView == textViewTitle{
                textView.text = "Enter Task Name"
            }
            else{
                textView.text = "Enter Task Description"
            }
        
            
            
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    
    
    
}





extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
       
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}


