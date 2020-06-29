//
//  DetailViewController.swift
//  SlickNotes
//
//  Created by user166476 on 6/19/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit
import CoreData
class NoteDetailViewController: UIViewController {

 
    var latitude: String!
    var longitude: String!
    var folderSelectedName: String?

    // All views
    var scrollView:UIScrollView! = nil
    var textViewTitle: UITextView!
    var noteDateLabel: UITextView!
    var viewsList: [UIView] = []
    var vstackView: UIStackView!
    var locationLabel : UILabel! = nil
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let detail = detailItem{
            let noteId = detail.noteId
            var predicate = NSPredicate(format: "noteId = %@", noteId as! CVarArg)
            var notes = SlickNotesStorage.storage.readNotes(withPredicate:predicate)
            if notes!.count > 0{
                detailItem = notes![0]
            }
        }
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
//         setUpView()
      }

    @IBAction func editBtnDown(_ sender: Any) {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let SlickCreateNoteViewController = storyBoard.instantiateViewController(withIdentifier: "SlickCreateNoteViewController") as! SlickCreateNoteViewController
        SlickCreateNoteViewController.changingReallySimpleNote = detailItem
        SlickCreateNoteViewController.folderSelectedName = folderSelectedName
        self.navigationController?.pushViewController(SlickCreateNoteViewController, animated: true)
    }
    
    
   var detailItem: SlickNotes? {
        didSet {
            // Update the view.
//            configureView()
            setUpView()
            
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let mapViewController = storyBoard.instantiateViewController(withIdentifier: "mapView") as! MapViewController
        
        mapViewController.latitude = latitude
        mapViewController.longitude = longitude

        self.navigationController?.pushViewController(mapViewController, animated: true)
        // Your action
    }
    
    @IBAction func editButtonDown(_ sender: Any) {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let SlickNoteCreatorViewController = storyBoard.instantiateViewController(withIdentifier: "SlickNoteCreatorViewController") as! SlickNoteCreatorViewController
        SlickNoteCreatorViewController.changingReallySimpleNote = detailItem
        SlickNoteCreatorViewController.folderSelectedName = folderSelectedName
        self.navigationController?.pushViewController(SlickNoteCreatorViewController, animated: true)

    }
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showChangeNoteSegue" {
//            let changeNoteViewController = (segue.destination as! UINavigationController).topViewController as! SlickNoteCreatorViewController
//            if let detail = detailItem {
//                changeNoteViewController.setChangingReallySimpleNote(
//                    changingReallySimpleNote: detail)
//            }
//        }
//    }
  //  (segue.destination as! UINavigationController).topViewController as! DetailViewController

  
    
    
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let MapViewController = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        
        if let detail = detailItem{
            MapViewController.latitude = detail.latitude
            MapViewController.longitude = detail.longitude
            self.navigationController?.pushViewController(MapViewController, animated: true)
        }
        
    }
    
    
    func setUpView(){

        if scrollView != nil {
            scrollView.removeFromSuperview()
        }

        viewsList = []
           // Add title
        if let detail = detailItem{
         
           textViewTitle = UITextView()
            textViewTitle.text = detail.noteTitle
           textViewTitle.textAlignment = .center
            textViewTitle.isEditable = false
          
          textViewTitle.heightAnchor.constraint(equalToConstant: 20).isActive = true
          textViewTitle.delegate = self
          textViewTitle.isScrollEnabled = false
           textViewTitle.font = UIFont.preferredFont(forTextStyle: .largeTitle)
          textViewDidChange(textViewTitle)
            
           viewsList.append(textViewTitle)
        
           
           // Add date
           noteDateLabel =  UITextView()
            noteDateLabel.delegate = self
            noteDateLabel.isEditable = false

            
           noteDateLabel.font = UIFont.preferredFont(forTextStyle: .headline)
           noteDateLabel.textAlignment = .center
            noteDateLabel.text = SlickNotesDateHelper.convertDate(date: detail.noteTimeStamp)
            noteDateLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
            noteDateLabel.isScrollEnabled = false
            
            textViewDidChange(noteDateLabel)
            viewsList.append(noteDateLabel)

            
            
           // Add a horizontal line
           let hr = UIView()
           hr.backgroundColor = .black
           hr.translatesAutoresizingMaskIntoConstraints = false
            hr.heightAnchor.constraint(equalToConstant: 50).isActive = true
            hr.widthAnchor.constraint(equalToConstant: 50).isActive = true
           
           
           
        
            
            
            
            locationLabel = UILabel()
            locationLabel.attributedText = NSAttributedString(string: detail.location, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
            
            locationLabel.textAlignment = .center
            locationLabel.isUserInteractionEnabled = true
            locationLabel.textColor = .blue

            locationLabel.translatesAutoresizingMaskIntoConstraints = false
            locationLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            locationLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
            
            
            let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))

            locationLabel.addGestureRecognizer(labelTap)
            
            viewsList.append(locationLabel)

            
            
            
            let locationOutBtn = UIButton()
            locationOutBtn.setImage(UIImage(named:"square.and.arrow.up" ), for: .normal)
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
           locationOutBtn.isUserInteractionEnabled = true
           locationOutBtn.addGestureRecognizer(tapGestureRecognizer)
                     
               
            
            
           let hStack = UIStackView(arrangedSubviews: [ locationLabel,locationOutBtn])
           hStack.distribution = .fillEqually
           hStack.alignment = .center
            hStack.widthAnchor.constraint(equalToConstant: 300)
            
            hStack.translatesAutoresizingMaskIntoConstraints  = false
           
           
            // generate all view order view
            
            var textIndex = 0
            var imageIndex = 0
            var audioIndex = 0

                  
           
           
           
           
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
           
           
            
            var textView1 = UITextView()
            
            textView1.text = detail.noteText
            textView1.textAlignment = .left
            
            
            textView1.heightAnchor.constraint(equalToConstant: 40).isActive = true
            textView1.delegate = self
            textView1.isScrollEnabled = false
            textView1.font = UIFont.preferredFont(forTextStyle: .headline)
            textView1.isUserInteractionEnabled = false
            textViewDidChange(textView1)
            viewsList.append(textView1)
            
            
//           viewsList = [textViewTitle,noteDateLabel,locationLabel] + viewsList
           vstackView = UIStackView(arrangedSubviews:  viewsList)
           vstackView.translatesAutoresizingMaskIntoConstraints = false
            vstackView.distribution = .fillProportionally
           vstackView.axis = .vertical
           scrollView.addSubview(vstackView)
            for view in viewsList{
                vstackView.setCustomSpacing(10, after: view)
            }
           
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
               
               vstackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -30),
               
               //              vstackView.heightAnchor.constraint(equalToConstant: 2000)
               
               
               
           ])
        }
       }
}







// text view customization
extension NoteDetailViewController: UITextViewDelegate{
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        

    }
    
   
    
    
}
