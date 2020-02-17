//
//  ViewController.swift
//  FrameworkClientApp
//
//  Created by wregula on 23/04/2019.
//  Copyright © 2019 wregula. All rights reserved.
//

import UIKit
import IOSSecuritySuite

internal class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {

        let jailbreakStatus = IOSSecuritySuite.amIJailbrokenWithFailMessage()
        let title = jailbreakStatus.jailbroken ? "Jailbroken" : "Jailed"
        let message = """
        Jailbreak: \(jailbreakStatus.failMessage),
        Run in emulator?: \(IOSSecuritySuite.amIRunInEmulator())
        Debugged?: \(IOSSecuritySuite.amIDebugged())
        Reversed?: \(IOSSecuritySuite.amIReverseEngineered())
        """
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))

        print("FailMessage: \(message)")
        present(alert, animated: false)
        
        let checks = IOSSecuritySuite.amIJailbrokenWithFailedChecks()
        print("The failed checks are: \(checks)")
        
    }
}
