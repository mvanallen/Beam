//
//  BeamServiceClient.swift
//  Beam
//
//  Created by Michael VanAllen on 16.04.19.
//  Copyright © 2019 ReactiveCode Studios. All rights reserved.
//

import Foundation
import MultipeerConnectivity


class BeamConnectionConsumer: NSObject {	// might have common superclass w/ other side (BeamConnectionObject)
	typealias DiscoveryHandler = (_ browser: MCNearbyServiceBrowser, _ provider: MCPeerID, _ info: [String : String]?) -> ()
	
	private let peerId: MCPeerID
	private let serviceType: String

	fileprivate lazy var serviceBrowser = {
		var browser = MCNearbyServiceBrowser(peer: peerId, serviceType: serviceType)
		browser.delegate = self
		return browser
	}()
	
	@Published private(set) var active: Bool = false
	@MainActor @Published var availablePeers: Set<MCPeerID> = []
	
	public var discoveryHandler: DiscoveryHandler?
	
	init(peerId: MCPeerID, serviceType: String) {
		self.peerId = peerId
		self.serviceType = serviceType
		
		super.init()
	}
	
	deinit {
		stop()
	}
	
	func start(with handler: @escaping DiscoveryHandler) {
		discoveryHandler = handler
		start()
	}
	
	func start() {
		NSLog("\(String(reflecting: self)).start() - start browsing for service of type '\(self.serviceType)'")
		active = true
		serviceBrowser.startBrowsingForPeers()
	}

	func stop() {
		serviceBrowser.stopBrowsingForPeers()
		active = false
		NSLog("\(String(reflecting: self)).stop() - stopped browsing for service of type '\(self.serviceType)'")
		
		Task { @MainActor in availablePeers.removeAll() }
	}
}


extension BeamConnectionConsumer: MCNearbyServiceBrowserDelegate {
	
	nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		NSLog("# \(String(reflecting: self)) – found peer '\(peerID.displayName)'")
		Task { @MainActor in availablePeers.insert(peerID) }
		
		self.discoveryHandler?(serviceBrowser, peerID, info)
		/* {
		 NSLog("# \(String(reflecting: self)) --> let's send a connection request!")
		 browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 0)
		} */
	}
	
	nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		NSLog("# \(String(reflecting: self)) – lost peer '\(peerID.displayName)'")
		Task { @MainActor in availablePeers.remove(peerID) }
	}
	
	nonisolated func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		NSLog("# \(String(reflecting: self)) – ERROR: discovery failed w/ error: \(error)")
	}
}


// - MARK: ColorService

extension BeamConnectionConsumer {
	
	func sendColor(_ newColor: UIColor) {
		NSLog("BeamConnectionConsumer.sendColor() - will try to send new color \(newColor)..")
		
		if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: newColor, requiringSecureCoding: true) {
			do {
				// !!!: try self.session.send(colorData, toPeers: self.session.connectedPeers, with: .reliable)
				NSLog("BeamConnectionConsumer.sendColor() - ..sent.")

			} catch {
				NSLog("BeamConnectionConsumer.sendColor() - send failed w/ error: \(error)")
			}
		}
	}
	
}
