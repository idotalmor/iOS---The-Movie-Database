//
//  MovieDetailsViewController.swift
//  MovieTest
//
//  Created by Ido Talmor on 06/11/2018.
//  Copyright © 2018 Ido Talmor. All rights reserved.
//

import UIKit
import SDWebImage
import FCAlertView

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overview: UILabel!
    
    var castArray:[Cast] = [Cast]()
    @IBOutlet weak var castCollectionView: UICollectionView!
    
    var movie:Movie?
    var length:Int?{
        didSet{
            
            DispatchQueue.main.async {
                
                self.lengthLabel.text = String(self.length!) + " min"
                
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMovie(url: "https://api.themoviedb.org/3/movie/"+String(movie!.id)+"?api_key=4e0be2c22f7268edffde97481d49064a&append_to_response=credits")
        
        self.title = movie?.title
        
        if(movie?.poster != nil){
            moviePoster.sd_setImage(with: URL(string: "https://image.tmdb.org/t/p/w300"+movie!.poster!), placeholderImage: UIImage(named: "placeholder.png"))}
        else{
            moviePoster.image = UIImage(named: "placeholder.png")
        }
        ratingLabel.text = "\u{2B50}"+String(movie!.rate)
        
        titleLabel.text = movie?.title
        
        let yearstr = movie!.release_date.components(separatedBy: "-")
        yearLabel.text = yearstr[0]

        overview.text = movie?.overview
        
        castCollectionView.delegate = self
        castCollectionView.dataSource = self
        
    }

    func getMovie(url:String){
        
        
        guard let url = URL(string: url) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    guard let jsonArr = json as? Json else {return}
                    self.length = jsonArr["runtime"] as? Int
                    guard let creditsJsonArr = jsonArr["credits"] as? Json else {return}
                    
                    guard let castJsonArr = creditsJsonArr["cast"] as? [Json] else {return}
                    
                    for (idx,cast) in castJsonArr.enumerated(){
                        
                        self.castArray.append(Cast(json: cast))
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.castCollectionView.reloadData()
                        
                    }
                    
                } catch {
                    print(error)
                }
                
            }
            }.resume()
        
    }
    

}

extension MovieDetailsViewController : UICollectionViewDelegate,UICollectionViewDataSource,FCAlertViewDelegate{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.castArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cast = castArray[indexPath.row]
        
        let cell = castCollectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! CastCollectionViewCell
        
        if(cast.poster != nil){
            cell.castImageView.sd_setImage(with: URL(string: "https://image.tmdb.org/t/p/w200"+cast.poster!), placeholderImage: UIImage(named: "placeholder.png"))}
        else{
            cell.castImageView.image = UIImage(named: "placeholder.png")
        }
        
        cell.castName.text = cast.name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cast = castArray[indexPath.row]
        getCast(id: cast.id)

        
        
    }
    
    func getCast(id:Int){
        
        print(id)
        guard let url = URL(string:"https://api.themoviedb.org/3/person/"+String(id)+"?api_key=4e0be2c22f7268edffde97481d49064a&language=en-US") else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    guard let jsonArr = json as? Json else {return}
                    let name = jsonArr["name"] as? String
                    var biography = jsonArr["biography"] as? String
                    
                    DispatchQueue.main.async {
                        
                        if(biography != nil){
                            if(biography!.count>500){
                                biography = String(Array(biography!)[0..<500])+"..."}}
                        
                        if(biography!.isEmpty||biography == nil){
                            biography = "There is no information about this actor"
                        }
                        let alert = FCAlertView()

                        alert.dismissOnOutsideTouch = true
                        alert.avoidCustomImageTint = true
                        alert.showAlert(inView: self,
                                        withTitle: name,
                                        withSubtitle: biography,
                                        withCustomImage: nil,
                                        withDoneButtonTitle: nil,
                                        andButtons: nil)
                        
                        
                    }
                    
                } catch {
                    print(error)
                }
                
            }
            }.resume()
        
    }
    
    
    
}
