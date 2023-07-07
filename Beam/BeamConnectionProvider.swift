//
//  BeamServiceProvider.swift
//  Beam
//
//  Created by Michael VanAllen on 16.04.19.
//  Copyright © 2019 ReactiveCode Studios. All rights reserved.
//

import Foundation
import MultipeerConnectivity


class BeamConnectionProvider: NSObject {	// might have common superclass w/ other side (BeamConnectionObject)
	typealias InvitationHandler = (_ consumer: MCPeerID, _ context: Data?, _ invitationHandler: @escaping (Bool, MCSession?) -> ()) -> ()
	
	private let peerId: MCPeerID
	private let serviceType: String

	fileprivate lazy var serviceAdvertiser = {
		var advertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: serviceType)
		advertiser.delegate = self
		return advertiser
	}()
	
	@Published private(set) var active: Bool = false
	
	public var invitationHandler: InvitationHandler?
	
	required init(peerId: MCPeerID, serviceType: String) {
		self.peerId = peerId
		self.serviceType = serviceType
		
		super.init()
	}
	
	deinit {
		stop()
	}
	
	func start(with handler: @escaping InvitationHandler) {
		invitationHandler = handler
		start()
	}
	
	func start() {
		NSLog("\(String(reflecting: self)).start() - start advertising service of type '\(self.serviceType)'")
		active = true
		serviceAdvertiser.startAdvertisingPeer()
	}
	
	func stop() {
		serviceAdvertiser.stopAdvertisingPeer()
		active = false
		NSLog("\(String(reflecting: self)).stop() - stopped advertising service of type '\(self.serviceType)'")
	}
}


extension BeamConnectionProvider: MCNearbyServiceAdvertiserDelegate {
	
	nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		NSLog("# \(String(reflecting: self)) – received connection request from peer '\(peerID.displayName)'")
		
		self.invitationHandler?(peerID, context, invitationHandler)
		/* {
		 NSLog("# \(String(reflecting: self)) --> how nice, I'll accept!")
		 invitationHandler(true, self.session)
		} */
	}
	
	nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		NSLog("# \(String(reflecting: self)) – ERROR: advertising failed w/ error: \(error)")
	}
}


// - MARK: ColorService

extension BeamConnectionProvider {
	var colorServiceDelegate: ColorServiceDelegate? { nil } //= nil
	
	func receivedColor(_ newColor: UIColor?) {
		NSLog("BeamConnectionProvider.receivedColor() - received new color \(newColor ?? .clear), trying to delegate..")
		if self.serviceType == "beam-colorsvc", let delegate = self.colorServiceDelegate {
			delegate.colorDidChange(to: newColor)
			NSLog("BeamConnectionProvider.receivedColor() - ..done.")
		}
	}
}

/*
extension BeamConnectionProvider: MCSessionDelegate {
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		NSLog("# BeamServiceProvider.MCSession: received \(data.count) bytes of data from peer '\(peerID.displayName)'")
		
		// MARK: ColorService
		if let newColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
			self.receivedColor(newColor)
		}
	}
}
*/
