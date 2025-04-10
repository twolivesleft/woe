//
//  CodeaProjectViewController.swift
//  TerminalofWoe
//
//  Created by Sim Saëns on Sunday 6 April 2025.
//  Copyright © 2019 Two Lives Left. All rights reserved.
//

import UIKit
import Tools
import RuntimeKit
import CraftKit

class CodeaProjectViewController: CodeaViewController {    

    let projectUrl: URL
    
    init(url: URL, addons: [CodeaAddon]) {
        projectUrl = url
        
        let runtime = ThreadedRuntimeViewController(addons: [
            CodeaStandardLibrary(),
            CraftAddon(),
            ProjectAddon(),
        ] + addons)
        
        super.init(runtime: runtime, activityType: "exported-codea-project")
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeRenderer {
            success in
            
            if !success {
                fatalError("Failed to load Codea project")
            }
        }
    }

    func initializeRenderer(completion: @escaping (Bool)->()) {
        let project = Project(bundlePath: projectUrl.path)
        
        runtime.project = project
        runtime.start {
            DispatchQueue.main.async {                
                self.runtime.startAnimation()
                
                completion(true)
            }
        }
    }
}

