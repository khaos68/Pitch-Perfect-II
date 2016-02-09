//
//  RecordedAudio.swift
//  Pitch-Perfect-II
//
//  Created by Patrizio Palazzetti on 17/10/15.
//  Copyright © 2015 Patrizio Palazzetti. All rights reserved.
//

import Foundation

final class RecordedAudio {
    
    // MARK: Variables
    
    private var filePathURL: NSURL! // Stores files' path
    private var titleText: String!  // Stores the file name
    
    // MARK: - Initializers
    
    init (filePath: NSURL, title: String) {
        
        self.filePathURL = filePath
        self.titleText = title
        
    }
    
    // MARK: - Properties
    
    var filePath: NSURL {
        return filePathURL
    }
    
    var title: String {
        return titleText
    }
    
}