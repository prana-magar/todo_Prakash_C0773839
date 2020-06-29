//
//  CreateNoteViewController.swift
//  SlickNotes
//
//  Created by Prakash on 2020-06-23.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit

class CreateNoteViewController: UIViewController {

    var vstackView:UIStackView! = nil
    var viewsList: [UIView] = []
    var imagePicker: ImagePicker!

    var currentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)

        let textView1 = UITextView()
        textView1.text = "Heloo asnjdajsndansjndansjdnjansdnjansjdnansndjkansjkdnas,mndans,dn,ansdnlansdnalnskldnaklsndnakls"
        
        
        textView1.heightAnchor.constraint(equalToConstant: 80).isActive = true
        textView1.delegate = self
        textView1.isScrollEnabled = false
        textView1.font = UIFont.preferredFont(forTextStyle: .headline)
        textViewDidChange(textView1)
        
        
        
        
        
        
        let scrollView = UIScrollView()
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
        
        
        viewsList = [textView1]
        vstackView = UIStackView(arrangedSubviews:  viewsList)
        vstackView.translatesAutoresizingMaskIntoConstraints = false
        vstackView.distribution = .fillProportionally
        vstackView.axis = .vertical
        scrollView.addSubview(vstackView)
       
        vstackView.backgroundColor = .red
        
        NSLayoutConstraint.activate([
              vstackView.topAnchor.constraint(equalTo:
                scrollView.topAnchor
                      ),
                      
              
              vstackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor
              ),
              
              vstackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor
              ),
              
              vstackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
              
              vstackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
              
//              vstackView.heightAnchor.constraint(equalToConstant: 2000)

            
            
        ])
        
        
        
     

        // Do any additional setup after loading the view.
    }
    
    
    
   

    @IBAction func addVoiceBtnDown(_ sender: Any) {
    }
    @IBAction func addImageBtnDown(_ sender: Any) {
        
        self.imagePicker.present(from: self.view)

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


extension CreateNoteViewController: UITextViewDelegate{
    
    
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
        currentView = textView
    }
}


extension CreateNoteViewController: ImagePickerDelegate{
    
    func addImageView(belowView: UIView, image: UIImage){
        var vStackSubViews = viewsList
        
        for view in vStackSubViews{
            if view == belowView{
                
                // add image view below.
                let imageViewNew = UIImageView(image: image)
                let size = CGSize(width: view.frame.width, height: .infinity)
                imageViewNew.heightAnchor.constraint(equalToConstant:
                imageViewNew.sizeThatFits(size).height).isActive = true
                
                viewsList.insert(imageViewNew, at: viewsList.firstIndex(of: view)! + 1)
                
                if(viewsList.firstIndex(of: imageViewNew) != (viewsList.endIndex - 1)){
                    
                    let nextView = viewsList[viewsList.firstIndex(of: imageViewNew)! + 1]
                    if let nextView2 = nextView as? UITextView{
                        print("next view is textView so skipping")
                    }
                    else{
                        let textViewNew = UITextView()
                                  textViewNew.heightAnchor.constraint(equalToConstant: 30).isActive = true
                                  textViewNew.delegate = self
                                  textViewNew.isScrollEnabled = false
                                textViewNew.font = UIFont.preferredFont(forTextStyle: .headline)

                                  viewsList.insert(textViewNew, at: viewsList.firstIndex(of: imageViewNew)! + 1)
                    }
                }
                else
                    {
                        let textViewNew = UITextView()
                        textViewNew.heightAnchor.constraint(equalToConstant: 30).isActive = true
                        textViewNew.delegate = self
                        textViewNew.isScrollEnabled = false
                        textViewNew.font = UIFont.preferredFont(forTextStyle: .headline)
                        viewsList.insert(textViewNew, at: viewsList.firstIndex(of: imageViewNew)! + 1)
                        
                }
                    
                    
                
                
                
                vstackView.removeAllArrangedSubviews()
                viewsList.forEach { (vw) in
                    vstackView.addArrangedSubview(vw)
                }
            }
        }
    }
    
    func didSelect(image: UIImage?) {
        print(image)
        print(currentView)
        
        if currentView == nil{
            currentView = viewsList[viewsList.endIndex-1]
        }
        
        
        self.addImageView(belowView: currentView, image: image!)
    }
    
    
}



