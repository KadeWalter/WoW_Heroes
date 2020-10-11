//
//  LoadingSpinnerViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 9/28/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

final class LoadingSpinnerViewController: UIViewController {
    
    let spinner = Spinner()
    var parentVC: UIViewController
    
    init(withViewController vc: UIViewController) {
        self.parentVC = vc
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func showLoadingMask() {
        showLoadingMask(withCompletion: nil)
    }
    
    func showLoadingMask(withCompletion completion: (() -> Void)?) {
        DispatchQueue.main.async {
            self.parentVC.navigationController?.present(self, animated: true, completion: completion)
        }
    }
    
    func hideLoadingMask() {
        hideLoadingMask(withCompletion: nil)
    }
    
    func hideLoadingMask(withCompletion completion: (() -> Void)?) {
        DispatchQueue.main.async {
            self.parentVC.navigationController?.dismiss(animated: true, completion: completion)
        }
    }
}
    
extension LoadingSpinnerViewController {    
    private func setupView() {
        view.isUserInteractionEnabled = false
        view.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? UIColor(white: 1.0, alpha: 0.15) : UIColor(white: 0, alpha: 0.15)
        
        spinner.frame = CGRect(x: view.center.x - 50, y: view.center.y - 50, width: 100, height: 100)
        view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}
