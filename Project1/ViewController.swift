//
//  ViewController.swift
//  Project1
//
//  Created by Andrei Korikov on 10.10.2021.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    var viewCounter = [String : Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(recommendMe))
        
        if let counter = UserDefaults.standard.dictionary(forKey: "viewCounter") as? [String : Int] {
            viewCounter = counter
        }
        
        performSelector(inBackground: #selector(loadImageNames), with: nil)
    }
    
    @objc func loadImageNames() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
        
        pictures.sort()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pictureName = pictures[indexPath.row]
        let viewCount = viewCounter[pictureName, default: 0]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictureName
        if viewCount > 0 {
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = "Viewed \(viewCount) time\(viewCount > 1 ? "s" : "")"
        } else {
            cell.detailTextLabel?.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1: try loading the "Detail" view controller and typecasting it to be DetailViewController
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            // 2: success! Set its selectedImage property
            let imageName = pictures[indexPath.row]
            vc.selectedImage = imageName
            vc.title = "Picture \(indexPath.row + 1) of \(pictures.count)"
            
            // Save info about how much this picture has been opened
            viewCounter[imageName] = viewCounter[imageName, default: 0] + 1
            UserDefaults.standard.set(viewCounter, forKey: "viewCounter")
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            // 3: now push it onto the navigation controller
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func recommendMe() {
        let recommendMsg = "Hi, there is cool app - The Image Viewer"
        
        let activityVC = UIActivityViewController(
            activityItems: [recommendMsg],
            applicationActivities: nil
        )
        
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
}

