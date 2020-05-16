//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Ischuk Alexander on 15.05.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var memeTableView: UITableView!
    
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(createMeme)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc func createMeme() {
        let editorVc = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditor") as! ViewController
        self.navigationController?.pushViewController(editorVc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
      }
      
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meme = self.memes[indexPath.row]
        let memeCell = tableView.dequeueReusableCell(withIdentifier: "MemeTableViewCell", for: indexPath) as! MemeTableViewCell
          
        memeCell.memeLabel?.text = ("\(meme.topText)...\(meme.bottomText)")
        memeCell.memeImageView?.image = meme.memedImage
          
        return memeCell
      }
      
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = storyboard!.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        detailController.image = memes[indexPath.row].memedImage
        navigationController!.pushViewController(detailController, animated: true)
    }
}
