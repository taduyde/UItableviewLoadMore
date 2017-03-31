//
//  ViewController.swift
//  LoadMore
//
//  Created by Ta Duy De on 2/22/17.
//  Copyright © 2017 Ta Duy De. All rights reserved.
//

import UIKit
import SDWebImage

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let ConsumerKey = "ROvT5Wz8PJfOAJv0iIv2tLtyjuCBYAHVIdfq2UIA"
    var currentPage: Int = 0
    var totalPages: Int = 0
    var totalItems: Int = 0
    var maxPages: Int = 0
    var photos: Array<Any> = []
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        loadPhotos(page: self.currentPage)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPhotos(page: Int) {
        print("Start load data")
        let apiURL = "https://api.500px.com/v1/photos?feature=editors&page=\(page)&consumer_key=\(ConsumerKey)"
        guard let url = URL(string: apiURL) else {
            print("Error: cannot create URL");
            return
        }
        let session: URLSession = URLSession.shared
        let urlRequest = URLRequest(url: url)
        let task = session.dataTask(with: urlRequest, completionHandler: {(data, response, error) in
            if (error == nil){
                do {
                    let jsonReponse = try JSONSerialization.jsonObject(with: data!, options: [.allowFragments]) as! [String: Any]
                    self.photos += jsonReponse["photos"] as! Array<Any>
                    self.currentPage = jsonReponse["current_page"] as! Int
                    self.currentPage = jsonReponse["total_pages"] as! Int
                    self.currentPage = jsonReponse["total_items"] as! Int
                    DispatchQueue.global(qos: .userInitiated).async {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                } catch {
                    
                }
            }
        })
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("photos is", self.photos)
        if (self.currentPage == self.maxPages || self.currentPage == self.totalPages || self.totalItems == self.photos.count) {
            print("photos count 1", self.photos.count)
            return self.photos.count
        }
        print("photos count 2", self.photos.count)
        return self.photos.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == self.photos.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadCell
            let activityIndicator: UIActivityIndicatorView = cell.contentView.viewWithTag(100) as! UIActivityIndicatorView
            activityIndicator.startAnimating()
            return cell
        } else {
            let photo: [String: AnyObject] = photos[indexPath.row] as! Dictionary
            print(indexPath, photo)
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemCell
            
            //cell.textLabel?.text = photo["name"] as? String
            cell.titleText?.text = photo["name"] as? String
            cell.descriptionText?.text = photo["description"] as? String
            cell.imageView?.sd_setImage(with: URL(string: photo["image_url"] as! String), placeholderImage: UIImage(named: "placeholder.jpg"))
            cell.imageView?.setShowActivityIndicator(true)
            cell.imageView?.setIndicatorStyle(.gray)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (self.currentPage != self.maxPages && indexPath.row == self.photos.count - 1) {
            self.loadPhotos(page: self.currentPage + 1)
        }
    }


}

