//
//  IntialTermViewController.swift
//  vNUTS
//
//  Created by 間嶋大輔 on 2019/10/28.
//  Copyright © 2019 daisuke. All rights reserved.
//

import UIKit

class InitialTermViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.tabBar.isHidden = true
        self.view.addSubview(collectionView)
        collectionView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceVertical = true
        collectionView.indicatorStyle = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TextCollectionViewCell.self, forCellWithReuseIdentifier: TextCollectionViewCell.identifer)
        dataSouce = othersText.termsOfService

        // Do any additional setup after loading the view.
    }
    
    @IBAction func AgreeButton(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = false
        UserDefaults.standard.set(true, forKey: "notFirst")
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var othersText = OthersText()
    var dataSouce = [(String,String)]()
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSouce.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OthersCell", for: indexPath) as? TextCollectionViewCell
            else { preconditionFailure("Failed to load collection view cell") }
        cell.HeadLabel.text = dataSouce[indexPath.item].0
        cell.TextLabel.text = dataSouce[indexPath.item].1
        cell.HeadLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 25)
        cell.TextLabel.frame = CGRect(x: 0, y: cell.HeadLabel.frame.maxY + 8, width: view.bounds.width - 40, height: view.bounds.height)
        cell.TextLabel.preferredMaxLayoutWidth = view.bounds.width - 20

        cell.TextLabel.lineBreakMode = .byCharWrapping
        cell.TextLabel.numberOfLines = 0
        cell.TextLabel.sizeToFit()
        cell.HeadLabel.sizeToFit()
        cell.addSubview(cell.TextLabel)
        cell.addSubview(cell.HeadLabel)
        return cell
    }
}
extension InitialTermViewController: UICollectionViewDelegateFlowLayout {

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 40, height: 20))
    let headLabel = UILabel(frame: CGRect(x: 0, y: 20, width: view.bounds.width - 40, height: 20))
    headLabel.text = dataSouce[indexPath.item].0
    label.text = dataSouce[indexPath.item].1
    headLabel.sizeToFit()
    label.numberOfLines = 0
    label.lineBreakMode = .byCharWrapping
    label.preferredMaxLayoutWidth = view.bounds.width - 40

    label.sizeToFit()
    return CGSize(width: self.view.bounds.width, height: label.frame.height + headLabel.frame.height + 40)
    }
}
