//
//  BeamServiceClient.swift
//  Beam
//
//  Created by Michael VanAllen on 16.04.19.
//  Copyright © 2019 ReactiveCode Studios. All rights reserved.
//

import Foundation
import MultipeerConnectivity


class BeamServiceClient: NSObject {
	/*private*/ let serviceBrowser: MCNearbyServiceBrowser
	
	private let peerId: MCPeerID
	private let serviceType: String
	
	init(peerId: MCPeerID, serviceType: String) {
		self.peerId = peerId
		self.serviceType = serviceType
		
		self.serviceBrowser = MCNearbyServiceBrowser(peer: self.peerId, serviceType: self.serviceType)
		super.init()
		self.serviceBrowser.delegate = self
		
		NSLog("BeamServiceClient.init() - start browsing for service of type '\(self.serviceType)'")
		//self.serviceBrowser.startBrowsingForPeers()
	}
	
	deinit {
		//self.serviceBrowser.stopBrowsingForPeers()
		NSLog("BeamServiceClient.deinit() - stopped browsing for service of type '\(self.serviceType)'")
	}
}


extension BeamServiceClient: MCNearbyServiceBrowserDelegate {
	
	nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		NSLog("# BeamServiceClient.foundPeer() - found peer '\(peerID.displayName)'")
		
		NSLog("# BeamServiceClient.foundPeer() --> let's invite him!")
		// !!!: browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 0)
	}
	
	nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		NSLog("# BeamServiceClient.lostPeer() - lost peer '\(peerID.displayName)'")
	}
	
	nonisolated func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		NSLog("# BeamServiceClient.didNotStartBrowsingForPeers() - discovery failed w/ error: \(error)")
	}
}


// - MARK: ColorService

extension BeamServiceProvider {
	
	func sendColor(_ newColor: UIColor) {
		NSLog("BeamServiceClient.sendColor() - will try to send new color \(newColor)..")
		
		if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: newColor, requiringSecureCoding: true) {
			do {
				// !!!: try self.session.send(colorData, toPeers: self.session.connectedPeers, with: .reliable)
				NSLog("BeamServiceClient.sendColor() - ..sent.")

			} catch {
				NSLog("BeamServiceClient.sendColor() - send failed w/ error: \(error)")
			}
		}
	}
	
}
