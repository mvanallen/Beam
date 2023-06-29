//
//  BeamServiceClient.swift
//  Beam
//
//  Created by Michael VanAllen on 16.04.19.
//  Copyright © 2019 ReactiveCode Studios. All rights reserved.
//

import Foundation
import MultipeerConnectivity


class BeamServiceClient: NSObject, MCNearbyServiceBrowserDelegate {
	private let serviceBrowser: MCNearbyServiceBrowser
	
	private let peerId = MCPeerID(displayName: UIDevice.current.name)
	let serviceType: String
	
	lazy var session: MCSession = {
		let session = MCSession(peer: self.peerId, securityIdentity: nil, encryptionPreference: .required)
		session.delegate = self
		return session
	}()
	
	init(type: String = "beam-themesvc") {
		self.serviceType = type
		self.serviceBrowser = MCNearbyServiceBrowser(peer: self.peerId, serviceType: self.serviceType)
		super.init()
		self.serviceBrowser.delegate = self
		
		NSLog("BeamServiceClient.init() - start browsing for service of type '\(self.serviceType)'")
		self.serviceBrowser.startBrowsingForPeers()
	}
	
	deinit {
		self.serviceBrowser.stopBrowsingForPeers()
		NSLog("BeamServiceClient.deinit() - stopped browsing for service of type '\(self.serviceType)'")
	}
	
	// MARK: MCNearbyServiceBrowserDelegate
	
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		NSLog("# BeamServiceClient.foundPeer() - found peer '\(peerID.displayName)'")
		
		NSLog("# BeamServiceClient.foundPeer() --> let's invite him!")
		browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 0)
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		NSLog("# BeamServiceClient.lostPeer() - lost peer '\(peerID.displayName)'")
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		NSLog("# BeamServiceClient.didNotStartBrowsingForPeers() - discovery failed w/ error: \(error)")
	}
	
	// MARK: ColorService
	
	func sendColor(_ newColor: UIColor) {
		NSLog("BeamServiceClient.sendColor() - will try to send new color \(newColor)..")
		
		if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: newColor, requiringSecureCoding: true) {
			do {
				try self.session.send(colorData, toPeers: self.session.connectedPeers, with: .reliable)
				NSLog("BeamServiceClient.sendColor() - ..sent.")

			} catch {
				NSLog("BeamServiceClient.sendColor() - send failed w/ error: \(error)")
			}
		}
	}
	
}


extension BeamServiceClient: MCSessionDelegate {
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		NSLog("# BeamServiceClient.MCSession: peer '\(peerID.displayName)' did change state to '\(state)'")
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		NSLog("# BeamServiceClient.MCSession: received \(data.count) bytes of data from peer '\(peerID.displayName)'")
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		NSLog("# BeamServiceClient.MCSession: received stream w/ name '\(streamName)' from peer '\(peerID.displayName)'")
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		NSLog("# BeamServiceClient.MCSession: did start receiving resource w/ name '\(resourceName)' from peer '\(peerID.displayName)'")
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		NSLog("# BeamServiceClient.MCSession: did finish receiving resource w/ name '\(resourceName)' from peer '\(peerID.displayName)'")
		NSLog("#   -> url '\(localURL?.absoluteString ?? "(nil)")'")
		NSLog("#   error: \(error?.localizedDescription ?? "(nil)")")
	}
	
	func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
		NSLog("# BeamServiceClient.MCSession: neat, received a certificate from peer '\(peerID.displayName)'!")
		NSLog("#   -> I'll allow it.")
		certificateHandler(true)
	}
	
}



extension MCSessionState: CustomStringConvertible {
	public var description: String {
		switch self {
		case .notConnected: return ".notConnected"
		case .connecting: return ".connecting"
		case .connected: return ".connected"
		@unknown default:
			NSLog("\(String(reflecting: self)) – discovered unknown state: \(self) (\(self.rawValue))")
			return ".unknown"
		}
	}
}
