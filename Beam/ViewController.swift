//
//  ViewController.swift
//  Beam
//
//  Created by Michael VanAllen on 16.04.19.
//  Copyright © 2019 ReactiveCode Studios. All rights reserved.
//

import UIKit


protocol ColorServiceDelegate {
	func colorDidChange(to newColor: UIColor?)
}


class ViewController: UIViewController {
	
	let colorService = "beam-colorsvc"
	
	var vendor: ConnectivityVendor? = nil
	var consumer: ConnectivityConsumer? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		switch UIDevice.current.userInterfaceIdiom {
			
		case .phone:
			self.consumer = ConnectivityConsumer(type: colorService)
			
		case .pad:
			self.vendor = ConnectivityVendor(type: colorService)
			self.vendor?.colorServiceDelegate = self
			
		default:
			break
		}
	}
	
	@IBAction func pushBtn1(_ sender: UIButton) {
		if let color = sender.backgroundColor { self.changeColor(to: color) }
	}
	
	@IBAction func pushBtn2(_ sender: UIButton) {
		if let color = sender.backgroundColor { self.changeColor(to: color) }
	}
	
	@IBAction func pushBtn3(_ sender: UIButton) {
		if let color = sender.backgroundColor { self.changeColor(to: color) }
	}
}


// MARK: ColorServiceDelegate


extension ViewController: ColorServiceDelegate {
	
	func changeColor(to newColor: UIColor) {	// Consumer side
		self.consumer?.sendColor(newColor)
	}
	
	func colorDidChange(to newColor: UIColor?) {	// Vendor side
		DispatchQueue.main.async {
			self.view.backgroundColor = newColor ?? .white
		}
	}
	
}
