//
//  SlickNotes.swift
//  SlickNotes
//
//  Created by user166476 on 6/19/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import Foundation

class SlickCategory {
    private(set) var categoryId        : UUID
    private(set) var categoryName     : String
    

    init(categoryName:String) {
        self.categoryId        = UUID()
        self.categoryName     = categoryName
        
    }

    init(categoryId: UUID, categoryName:String) {
        self.categoryId        = categoryId
        self.categoryName     = categoryName
       

    }
}
