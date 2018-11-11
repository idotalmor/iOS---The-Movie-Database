//
//  MovieTableViewCell.swift
//  MovieTest
//
//  Created by Ido Talmor on 05/11/2018.
//  Copyright © 2018 Ido Talmor. All rights reserved.
//

import UIKit
import SDWebImage

class MovieTableViewCell: UITableViewCell {

    var movie:Movie?{
        didSet{
            
            title.text = movie?.title
            rating.text = "\u{2B50}"+String(movie!.rate)
            let yearstr = movie!.release_date.components(separatedBy: "-")
            year.text = yearstr[0]
            overview.text = movie?.overview
            if(movie?.poster != nil){
                poster.sd_setImage(with: URL(string: "https://image.tmdb.org/t/p/w200"+movie!.poster!), placeholderImage: UIImage(named: "placeholder.png"))}
            else{
                poster.image = UIImage(named: "placeholder.png")
            }

            
        }
    }
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var overview: UILabel!
    

}
