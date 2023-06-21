//
//  BeamServiceProvider.swift
//  Beam
//
//  Created by Michael VanAllen on 16.04.19.
//  Copyright © 2019 ReactiveCode Studios. All rights reserved.
//

import Foundation
import MultipeerConnectivity


class BeamServiceProvider: NSObject, MCNearbyServiceAdvertiserDelegate {
	private let serviceAdvertiser: MCNearbyServiceAdvertiser
	
	private let peerId = MCPeerID(displayName: UIDevice.current.name)
	let serviceType: String
	
	lazy var session: MCSession = {
		let session = MCSession(peer: self.peerId, securityIdentity: nil, encryptionPreference: .required)
		session.delegate = self
		return session
	}()
	
	init(type: String = "beam-themesvc") {
		self.serviceType = type
		self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.peerId, discoveryInfo: nil, serviceType: self.serviceType)
		super.init()
		self.serviceAdvertiser.delegate = self
		
		NSLog("BeamServiceProvider.init() - start advertising service of type '\(self.serviceType)'")
		self.serviceAdvertiser.startAdvertisingPeer()
	}
	
	deinit {
		self.serviceAdvertiser.stopAdvertisingPeer()
		NSLog("BeamServiceProvider.deinit() - stopped advertising service of type '\(self.serviceType)'")
	}
	
	// MARK: MCNearbyServiceAdvertiserDelegate
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		NSLog("# BeamServiceProvider.didReceiveInvitationFromPeer() - received invitation from peer '\(peerID.displayName)'")
		
		NSLog("# BeamServiceProvider.didReceiveInvitationFromPeer() --> how nice, I'll accept!")
		invitationHandler(true, self.session)
		
		NSLog("# BeamServiceProvider.didReceiveInvitationFromPeer() - (..also, I'll reset the color)")
		self.receivedColor(nil)
	}
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		NSLog("# BeamServiceProvider.didNotStartAdvertisingPeer() - advertising failed w/ error: \(error)")
	}
	
	// MARK: ColorService
	
	var colorServiceDelegate: ColorServiceDelegate? = nil
	
	func receivedColor(_ newColor: UIColor?) {
		NSLog("BeamServiceProvider.receivedColor() - received new color \(newColor ?? .clear), trying to delegate..")
		if self.serviceType == "beam-colorsvc", let delegate = self.colorServiceDelegate {
			delegate.colorDidChange(to: newColor)
			NSLog("BeamServiceProvider.receivedColor() - ..done.")
		}
	}
}


extension BeamServiceProvider: MCSessionDelegate {
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		NSLog("# BeamServiceProvider.MCSession: peer '\(peerID.displayName)' did change state to '\(state)'")
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		NSLog("# BeamServiceProvider.MCSession: received \(data.count) bytes of data from peer '\(peerID.displayName)'")
		
		// MARK: ColorService
		if let newColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
			self.receivedColor(newColor)
		}
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		NSLog("# BeamServiceProvider.MCSession: received stream w/ name '\(streamName)' from peer '\(peerID.displayName)'")
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		NSLog("# BeamServiceProvider.MCSession: did start receiving resource w/ name '\(resourceName)' from peer '\(peerID.displayName)'")
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		NSLog("# BeamServiceProvider.MCSession: did finish receiving resource w/ name '\(resourceName)' from peer '\(peerID.displayName)'")
		NSLog("#   -> url '\(localURL?.absoluteString ?? "(nil)")'")
		NSLog("#   error: \(error?.localizedDescription ?? "(nil)")")
	}
	
	func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
		NSLog("# BeamServiceProvider.MCSession: neat, received a certificate from peer '\(peerID.displayName)'!")
		NSLog("#   -> I'll allow it.")
		certificateHandler(true)
	}
	
}
