//
//  Cast.swift
//  MovieTest
//
//  Created by Ido Talmor on 06/11/2018.
//  Copyright © 2018 Ido Talmor. All rights reserved.
//

import Foundation

class Cast{
    
    let id:Int
    let name:String
    var poster : String?
    
    init(json:Json){
    
    id = json["id"] as! Int
        name = json["name"] as! String
        poster = json["profile_path"] as? String
    
        
    }
    
}
