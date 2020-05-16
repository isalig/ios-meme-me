//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Ischuk Alexander on 15.05.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemeCollectionViewCell"

class MemeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private let itemSpacing: CGFloat = 3.0
    private var isLandscape = false
    private var itemSize = CGSize(width: 0, height: 0)
    
    @IBOutlet weak var memeCollectionView: UICollectionView!
    @IBOutlet weak var memeFlowLayout: UICollectionViewFlowLayout!
    
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
        memeFlowLayout.minimumInteritemSpacing = itemSpacing
        memeFlowLayout.minimumLineSpacing = itemSpacing
        memeCollectionView.delegate = self
        recalcItemSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memeCollectionView.reloadData()
    }
    
    @objc func createMeme() {
        let editorVc = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditor") as! ViewController
        self.navigationController?.pushViewController(editorVc, animated: true)
    }
    
    private func recalcItemSize() {
        isLandscape = UIDevice.current.orientation.isLandscape
        let rowItemsCount: CGFloat
        if(isLandscape) {
            rowItemsCount = 5
        } else {
            rowItemsCount = 3
        }
        
        let spacesCount = rowItemsCount - 1
        let dimension = (view.frame.size.width - (spacesCount * itemSpacing)) / rowItemsCount
        itemSize = CGSize(width: dimension, height: dimension)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        let cell = memeCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
    
        let meme = self.memes[indexPath.row]
        cell.memeImageView.image = meme.memedImage
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = storyboard!.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        detailController.image = memes[indexPath.row].memedImage
        navigationController!.pushViewController(detailController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (isLandscape != UIDevice.current.orientation.isLandscape) {
            recalcItemSize()
        }
        
        return itemSize
    }
}
