//
//  Meme.swift
//  MemeMe
//
//  Created by Alp Eren Can on 29/08/15.
//  Copyright © 2015 Alp Eren Can. All rights reserved.
//

import UIKit

struct Meme {
    
    let topText: String?
    let bottomText: String?
    let originalImage: UIImage?
    let memedImage: UIImage?
    
    init(topText: String?, bottomText: String?, image: UIImage?, memedImage: UIImage?) {
        
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = image
        self.memedImage = memedImage
        
    }
    
}
