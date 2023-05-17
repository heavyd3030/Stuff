//
//  ViewController.swift
//  FrameworkClientApp
//
//  Created by wregula on 23/04/2019.
//  Copyright © 2019 wregula. All rights reserved.
//
//swiftlint:disable all

import UIKit
import IOSSecuritySuite

class RuntimeClass {
   @objc dynamic func runtimeModifiedFunction()-> Int {
       return 1
   }
}

//Test watchpoint
func testWatchpoint() -> Bool{
    var ptr = malloc(9)
    var count = 3
    return SecuritySuiteiOS.hasWatchpoint()
}

internal class ViewController: UIViewController {
    
    func testHookPrint() {
        typealias MyPrint = @convention(thin) (Any..., String, String) ->Void
        func myPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
            NSLog("print has been hooked")
        }
        let myprint: MyPrint = myPrint
        let myPrintPointer = unsafeBitCast(myprint, to: UnsafeMutableRawPointer.self)
        var oldMethod: UnsafeMutableRawPointer?
        
        // hook
        replaceSymbol("$ss5print_9separator10terminatoryypd_S2StF", newMethod: myPrintPointer, oldMethod: &oldMethod)
        print("print hasn't been hooked")
        
        // antiHook
        SecuritySuiteiOS.denySymbolHook("$ss5print_9separator10terminatoryypd_S2StF")
        print("print has been antiHooked")
    }

    override func viewDidAppear(_ animated: Bool) {
//        testHookPrint()
        
        // Runtime Check
        let test = RuntimeClass.init()
        test.runtimeModifiedFunction()
        let dylds = ["UIKit"]
        let amIRuntimeHooked = SecuritySuiteiOS.amIRuntimeHooked(dyldWhiteList: dylds, detectionClass: RuntimeClass.self, selector: #selector(RuntimeClass.runtimeModifiedFunction), isClassMethod: false)
        // MSHook Check
        func msHookReturnFalse(takes: Int) -> Bool {
            /// add breakpoint at here to test `SecuritySuiteiOS.hasBreakpointAt`
            return false
        }
        typealias FunctionType = @convention(thin) (Int) -> (Bool)
        func getSwiftFunctionAddr(_ function: @escaping FunctionType) -> UnsafeMutableRawPointer {
            return unsafeBitCast(function, to: UnsafeMutableRawPointer.self)
        }
        let funcAddr = getSwiftFunctionAddr(msHookReturnFalse)

        let jailbreakStatus = SecuritySuiteiOS.amIJailbrokenWithFailMessage()
        let title = jailbreakStatus.jailbroken ? "Jailbroken" : "Jailed"
        let message = """
        Jailbreak: \(jailbreakStatus.failMessage),
        Run in emulator?: \(SecuritySuiteiOS.amIRunInEmulator())
        Debugged?: \(SecuritySuiteiOS.amIDebugged())
        HasBreakpoint?: \(SecuritySuiteiOS.hasBreakpointAt(funcAddr, functionSize: nil))
        Has watchpoint: \(testWatchpoint())
        Reversed?: \(SecuritySuiteiOS.amIReverseEngineered())
        Am I MSHooked: \(SecuritySuiteiOS.amIMSHooked(funcAddr))
        Am I runtime hooked: \(amIRuntimeHooked)
        Am I tempered with: \(SecuritySuiteiOS.amITampered([.bundleID("biz.securing.FrameworkClientApp")]).result)
        Application executable file hash value: \(SecuritySuiteiOS.getMachOFileHashValue() ?? "")
        IOSSecuritySuite executable file hash value: \(SecuritySuiteiOS.getMachOFileHashValue(.custom("IOSSecuritySuite")) ?? "")
        Am I proxied: \(SecuritySuiteiOS.amIProxied())
        """
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))

        print("FailMessage: \(message)")
        present(alert, animated: false)

        let checks = SecuritySuiteiOS.amIJailbrokenWithFailedChecks()
        print("The failed checks are: \(checks)")
        
#if arch(arm64)
        print("Loaded libs: \(SecuritySuiteiOS.findLoadedDylibs() ?? [])")
#endif
    }
}
