//
//  Movie.swift
//  MovieTest
//
//  Created by Ido Talmor on 05/11/2018.
//  Copyright © 2018 Ido Talmor. All rights reserved.
//

import Foundation

class Movie{
    
    let id : Int
    let title: String
    let release_date: String
    let rate: Double
    let poster: String?
    let overview:String
    
    
    init(json:Json){
        
        id = json["id"] as! Int
        title = json["title"] as! String
        release_date = json["release_date"] as! String
        rate = json["vote_average"] as! Double
        poster = json["poster_path"] as? String
        overview = json["overview"] as! String
        
    }
    
}
