//
//  ViewController.swift
//  Bware
//
//  Created by Alan Salazar on 21/10/17.
//  Copyright © 2017 Alan Salazar. All rights reserved.
//

// En esta pantalla se carga el launchview.

import UIKit

class ViewController: UIViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Registrar notificación
        NotificationCenter.default.addObserver(self, selector: #selector(usuarioValidado), name: NSNotification.Name.init(rawValue: "firmaGoogle"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func usuarioValidado() {
        let delegado = UIApplication.shared.delegate as! AppDelegate
        print("\(delegado.firmado)")
        performSegue(withIdentifier: "SignInGoogle", sender: self)
    }
}

