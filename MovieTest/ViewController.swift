//
//  ViewController.swift
//  MovieTest
//
//  Created by Ido Talmor on 05/11/2018.
//  Copyright © 2018 Ido Talmor. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var moviesArray:[Movie] = [Movie]()
    var page = 1
    var totalpages = 1
    var searchString : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension;
        
        searchBar.delegate = self
        tableView.addSubview(self.refreshControl)

        getMovies(url: "https://api.themoviedb.org/3/movie/top_rated?api_key=4e0be2c22f7268edffde97481d49064a", reset: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Top Rated Movies"
        
    }
    
    func getMovies(url:String,reset:Bool){
        
        if(reset){
            moviesArray = [Movie]()
            page = 1
            self.tableView.reloadData()
        }
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
                    if(self.page==1){
                        self.totalpages = jsonArr["total_pages"] as! Int}
                    guard let movieJsonArr = jsonArr["results"] as? [Json] else {return}
                    
                    if(movieJsonArr.count == 0){return}
                    
                    DispatchQueue.main.async {
                        for (idx,movie) in movieJsonArr.enumerated(){
                            // run on main thread - ui thread

                            self.moviesArray.append(Movie(json: movie))
                            let indexpath = IndexPath(row: idx, section: 0)
                            self.tableView.insertRows(at: [indexpath], with: .right)
                            
                        }
                        
                        if(self.refreshControl.isRefreshing){
                            self.refreshControl.endRefreshing()
                        }
                        
                    }
                    
                } catch {
                    print(error)
                }
                
            }
            }.resume()
        
    }
    
    //handeling the tableview delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return moviesArray.count}
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieTableViewCell
        cell.movie = moviesArray[indexPath.row]
        
            return cell
            
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddResult") as! UITableViewCell
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 0){
            performSegue(withIdentifier: "MovieSegue", sender: self)
            //code for movie cell will be paste here
            return
        }
        if(indexPath.section == 1){
            //more result function
            
            tableView.deselectRow(at: indexPath, animated: true)
            page = page + 1
            
            if (page > totalpages){
                
                let alert = UIAlertController(title: "Oops!", message: "There is no more results fot you!", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
                    
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
                
            }
            
            if(searchString ==  nil){
                
                let urlStr = "https://api.themoviedb.org/3/movie/top_rated?page="+String(page)+"&api_key=4e0be2c22f7268edffde97481d49064a"
                
                getMovies(url: urlStr, reset: false)
                
            }else{
                
                let urlStr = "https://api.themoviedb.org/3/search/movie?page="+String(page)+"&api_key=4e0be2c22f7268edffde97481d49064a&query="+self.searchString!
                
                getMovies(url: urlStr, reset: false)
                
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "MovieSegue"){
            
            guard let dest = segue.destination as? MovieDetailsViewController else{
                return
            }
            var indexPath = tableView.indexPathForSelectedRow
            dest.movie = moviesArray[indexPath!.row]
            tableView.deselectRow(at: indexPath!, animated: true)

            
            
        }
    }

    
    //Adding the refresh controll
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ViewController.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    //to be run on refresh
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        if(searchString == nil){
            getMovies(url: "https://api.themoviedb.org/3/movie/top_rated?api_key=4e0be2c22f7268edffde97481d49064a", reset: true)
            return
        }
        let urlstr = "https://api.themoviedb.org/3/search/movie?&api_key=4e0be2c22f7268edffde97481d49064a&query="+self.searchString!
        getMovies(url: urlstr, reset: true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //close keyboard when user touch tableview
        self.view.endEditing(true)
    }
    
}

extension ViewController : UISearchBarDelegate{
    
    //consume the search bar editing change
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchText.isEmpty){
            //if the searchbar is empty - clear the search viewcontroller scope string and display the top movies again
            self.searchString = nil
            getMovies(url: "https://api.themoviedb.org/3/movie/top_rated?api_key=4e0be2c22f7268edffde97481d49064a", reset: true)
            return
            
        }
        
        self.searchString = searchText.replacingOccurrences(of: " ", with: "+")
        let urlstr = "https://api.themoviedb.org/3/search/movie?&api_key=4e0be2c22f7268edffde97481d49064a&query="+self.searchString!
        getMovies(url: urlstr, reset: true)
    }
    
}
typealias Json = [String:Any]
