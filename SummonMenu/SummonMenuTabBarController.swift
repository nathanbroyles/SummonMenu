//
//  SummonMenuTabBarController.swift
//  SummonMenu
//
//  Created by Nathan Broyles on 4/7/18.
//  Copyright © 2018 DeadPixel. All rights reserved.
//

import UIKit

class SummonMenuTabBarController: UITabBarController {
    
    var isAwaitingTouch: Bool = true
    var feedbackGenerator: UIImpactFeedbackGenerator?
    var selectionGenerator: UISelectionFeedbackGenerator?
    var leadingConstraint: NSLayoutConstraint?
    var topConstraint: NSLayoutConstraint?
    lazy var summonMenu: UIStackView = {
        let menu = UIStackView()
        menu.distribution = UIStackViewDistribution.fillEqually
        menu.spacing = 10
        menu.axis = UILayoutConstraintAxis.vertical
        menu.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, viewController) in (viewControllers ?? []).enumerated() {
            let button = UIButton(type: UIButtonType.system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(viewController.title, for: UIControlState.normal)
            button.addTarget(self, action: #selector(buttonPressed(sender:)), for: UIControlEvents.touchUpInside)
            button.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            button.layer.cornerRadius = 3
            button.tag = index
            menu.addArrangedSubview(button)
        }
        
        menu.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        return menu
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if traitCollection.forceTouchCapability == .available {
            tabBar.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if traitCollection.forceTouchCapability == .available {
            feedbackGenerator = UIImpactFeedbackGenerator(style: UIImpactFeedbackStyle.heavy)
            feedbackGenerator?.prepare()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if traitCollection.forceTouchCapability == .available {
            if touches.first?.force ?? 0.0 >= 4.0, isAwaitingTouch == true {
                feedbackGenerator?.impactOccurred()
                isAwaitingTouch = false
                summonMenu(at: touches.first?.location(in: view))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if traitCollection.forceTouchCapability == .available {
            isAwaitingTouch = true
            feedbackGenerator = nil
        }
    }
    
    func summonMenu(at point: CGPoint?) {
        guard let point = point else { return }
        
        selectionGenerator = UISelectionFeedbackGenerator()
        selectionGenerator?.prepare()
        
        leadingConstraint?.isActive = false
        topConstraint?.isActive = false
        
        view.addSubview(summonMenu)
        
        leadingConstraint = summonMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: point.x - (summonMenu.bounds.width/2))
        leadingConstraint?.isActive = true
        
        topConstraint = summonMenu.topAnchor.constraint(equalTo: view.topAnchor, constant: point.y - (summonMenu.bounds.height/2))
        topConstraint?.isActive = true
        
        view.setNeedsLayout()
    }
    
    @objc func buttonPressed(sender: UIButton) {
        selectionGenerator?.selectionChanged()
        selectionGenerator = nil
        selectedViewController = viewControllers?[sender.tag]
        summonMenu.removeFromSuperview()
    }
}
