//
//  VoiceRecHelper.swift
//  SlickNotes
//
//  Created by Raghav Bobal on 2020-06-25.
//  Copyright © 2020 Quasars. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VoiceRecHelper
{
        static let shareInstance = VoiceRecHelper()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        func saveAudio(data: Data) {
            let voiceRec = Audio(context: context)
            voiceRec.voiceRecording = data
                
            do {
                try context.save()
                print("Audio is saved")
            } catch {
                print(error.localizedDescription)
            }
        }
        
        func fetchAudio() -> [Audio] {
            var fetchingAudio = [Audio]()
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Audio")
            
            do {
                fetchingAudio = try context.fetch(fetchRequest) as! [Audio]
            } catch {
                print("Error while fetching the Audio")
            }
            
            return fetchingAudio
        }
    }
