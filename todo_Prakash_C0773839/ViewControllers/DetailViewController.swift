//
//  DetailViewController.swift
//  SlickNotes
//
//  Created by user166476 on 6/19/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var noteTextTextView: UITextView!
    @IBOutlet weak var noteDate: UILabel!

    @IBOutlet weak var noteLocationLabel: UILabel!
    
    var latitude: String!
    var longitude: String!
    var folderSelectedName: String?
    
    @IBOutlet weak var noteLocationOutImg: UIImageView!
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let topicLabel = noteTitleLabel,
               let dateLabel = noteDate,
               let textView = noteTextTextView,
                let location = noteLocationLabel{
                topicLabel.text = detail.noteTitle
                dateLabel.text = SlickNotesDateHelper.convertDate(date:  detail.noteTimeStamp)
                textView.text = detail.noteText
                location.text = "\(detail.location)"
                latitude = detail.latitude
                longitude = detail.longitude
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        noteLocationOutImg.isUserInteractionEnabled = true
        noteLocationOutImg.addGestureRecognizer(tapGestureRecognizer)
    }

    
    
   var detailItem: SlickNotes? {
        didSet {
            // Update the view.
            configureView()
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

}

