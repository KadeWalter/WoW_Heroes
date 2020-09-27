//
//  RegionSelectionViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 4/3/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

// TODO: - Change this to a table view
class RegionSelectViewController: UIViewController {

    lazy var usButton = lazyRegionButton(regionName: "US")
    lazy var euButton = lazyRegionButton(regionName: "EU")
    lazy var krButton = lazyRegionButton(regionName: "KR")
    lazy var twButton = lazyRegionButton(regionName: "TW")
    lazy var stackView = lazyButtonStackView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Select Your Region"
        navigationItem.largeTitleDisplayMode = .never
        self.view.backgroundColor = .systemGroupedBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup views
        initializeView()
        // add button targets
        usButton.addTarget(self, action: #selector(usButtonSelected), for: .touchUpInside)
        euButton.addTarget(self, action: #selector(euButtonSelected), for: .touchUpInside)
        krButton.addTarget(self, action: #selector(krButtonSelected), for: .touchUpInside)
        twButton.addTarget(self, action: #selector(twButtonSelected), for: .touchUpInside)
    }
}

// MARK: - Button Selected Functions
extension RegionSelectViewController {
    @objc func usButtonSelected() {
        let vc = AddCharacterTableViewController(region: "us")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func euButtonSelected() {
        let vc = AddCharacterTableViewController(region: "eu")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func krButtonSelected() {
        let vc = AddCharacterTableViewController(region: "kr")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func twButtonSelected() {
        let vc = AddCharacterTableViewController(region: "tw")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - View Controller Setup
extension RegionSelectViewController {
    func initializeView() {
        self.stackView.addArrangedSubview(usButton)
        self.stackView.addArrangedSubview(euButton)
        self.stackView.addArrangedSubview(krButton)
        self.stackView.addArrangedSubview(twButton)
        
        self.view.addSubview(self.stackView)
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -40),
            usButton.heightAnchor.constraint(equalToConstant: 50),
            euButton.heightAnchor.constraint(equalToConstant: 50),
            krButton.heightAnchor.constraint(equalToConstant: 50),
            twButton.heightAnchor.constraint(equalToConstant: 50),
            usButton.centerXAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.centerXAnchor),
            euButton.centerXAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.centerXAnchor),
            krButton.centerXAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.centerXAnchor),
            twButton.centerXAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    func lazyRegionButton(regionName: String) -> UIButton {
        let button = UIButton()
        // Button title information.
        button.setTitle(regionName, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = FontManager.shared.standardFont
        
        // Button border.
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.borderWidth = 1.5
        button.layer.cornerRadius = 15.0
                
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func lazyButtonStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}
