//
// KKBOXOpenAPI.swift
//
// Copyright (c) 2019 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

import Foundation

private let KKUserAgent = "KKBOX Open API Swift SDK"
private let KKOauthTokenURL = "https://account.kkbox.com/oauth2/token"
private let KKErrorDomain = "KKErrorDomain"
private let KKBOXAPIPath = "https://api.kkbox.com/v1.1/"
private let KKBOXAccessTokenSettingKey = "KKBOX OPEN API Access Token"

private func escape(_ string: String) -> String {
	return string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
}

private func escape_arg(_ string: String) -> String {
	return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
}

/// An access token. It is required for making API calls.
public struct KKAccessToken: Codable {
	/// The access token string.
	public private(set) var accessToken: String
	/// When will the access token expires since now.
	public private(set) var expiresIn: TimeInterval
	/// Type of the access token.
	public private(set) var tokenType: String?
	/// Scope of the access token.
	public private(set) var scope: KKScope?

	private enum CodingKeys: String, CodingKey {
		case accessToken = "access_token"
		case expiresIn = "expires_in"
		case tokenType = "token_type"
		case scope = "scope"
	}

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		accessToken = try values.decode(String.self, forKey: .accessToken)
		expiresIn = try values.decode(TimeInterval.self, forKey: .expiresIn)
		tokenType = try values.decode(String.self, forKey: .tokenType)
		let scopeString = try values.decode(String.self, forKey: .tokenType)
		scope = KKScope(string: scopeString)
	}

}

/// The territory that KKBOX provides services.
///
/// - taiwan: Taiwan
/// - hongkong: Hong Kong
/// - singapore: Singapore
/// - malaysia: Malaysia
/// - japan: Japan
public enum KKTerritory: String, Codable {
	/// Taiwan
	case taiwan = "TW"
	/// Hong Kong
	case hongkong = "HK"
	/// Songapore
	case singapore = "SG"
	/// Malaysia
	case malaysia = "MY"
	/// Japan
	case japan = "JP"

	fileprivate func toString() -> String {
		return self.rawValue
	}
}

/// The desired search type.
public struct KKSearchType: OptionSet {
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}

	public let rawValue: Int
	public static let none = KKSearchType(rawValue: 0)
	/// Specify that we are searching for artists.
	public static let artist = KKSearchType(rawValue: 1 << 0)
	/// Specify that we are searching for albums.
	public static let album = KKSearchType(rawValue: 1 << 1)
	/// Specify that we are searching for tracks.
	public static let track = KKSearchType(rawValue: 1 << 2)
	/// Specify that we are searching for playlists.
	public static let playlist = KKSearchType(rawValue: 1 << 3)

	fileprivate func toString() -> String {
		var scapeStrings = [String]()
		if self.contains(KKSearchType.artist) {
			scapeStrings.append("artist")
		}
		if self.contains(KKSearchType.album) {
			scapeStrings.append("album")
		}
		if self.contains(KKSearchType.track) {
			scapeStrings.append("track")
		}
		if self.contains(KKSearchType.playlist) {
			scapeStrings.append("playlist")
		}
		return scapeStrings.joined(separator: ",")
	}
}

/// The scope of your client ID.
public struct KKScope: OptionSet, Codable {
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}

	fileprivate init(string: String) {
		if (string == "all") {
			self = KKScope.all
			return
		}
		var scope: Int = 0
		let components = string.split(separator: ",")
		for component in components {
			switch component {
			case "user_profile":
				scope |= KKScope.userProfile.rawValue
			case "user_territory":
				scope |= KKScope.userTerritory.rawValue
			case "user_account_status":
				scope |= KKScope.userAccountStatus.rawValue
			default:
				break
			}
		}
		self = KKScope(rawValue: scope)
	}


	public let rawValue: Int
	/// Your client does not request any additional permission.
	public static let none = KKScope(rawValue: 0)
	/// Your client requests the permission to access user profiles.
	public static let userProfile = KKScope(rawValue: 1 << 0)
	/// Your client requests the permission to access the territory where users are at.
	public static let userTerritory = KKScope(rawValue: 1 << 1)
	/// Your client requests the permission to access the status of accounts.
	public static let userAccountStatus = KKScope(rawValue: 1 << 2)
	/// Your client requests all permissions.
	public static let all: KKScope = [.userProfile, .userTerritory, .userAccountStatus]

	fileprivate func toString() -> String {
		if self == KKScope.all {
			return "all"
		}
		var scapeStrings = [String]()
		if self.contains(KKScope.userProfile) {
			scapeStrings.append("user_profile")
		}
		if self.contains(KKScope.userTerritory) {
			scapeStrings.append("user_territory")
		}
		if self.contains(KKScope.userAccountStatus) {
			scapeStrings.append("user_account_status")
		}
		return scapeStrings.joined(separator: " ")
	}
}


/// The response of API calls
///
/// - error: the API returns an error with an error object.
/// - success: the API is successfully called and return an object.
public enum KKAPIResult<T> {
	/// The API is successfully called and return an object.
	case success(T)
	/// the API returns an error with an error object.
	case error(Error)
}

/// Errors used in KKBOX Open API SDK.
public enum KKBOXOpenAPIError: Error, LocalizedError {
	/// Failed to create a client credential
	case failedToCreateClientCredential
	/// Invalid response
	case invalidResponse
	/// The operation required an access token
	case requireAccessToken

	public var errorDescription: String? {
		switch self {
		case .failedToCreateClientCredential:
			return NSLocalizedString("Failed to create a client credential.", comment: "")
		case .invalidResponse:
			return NSLocalizedString("Invalid response", comment: "")
		case .requireAccessToken:
			return NSLocalizedString("The operation required an access token.", comment: "")
		}
	}
}

/// Additioanl nitifications
extension Notification.Name {
	/// Notification for obtaining an access token.
	static let KKBOXOpenAPIDidLogin = Notification.Name("KKBOXOpenAPIDidLogin")
	/// Notification for removing current access token.
	static let KKBOXOpenAPIDidLogout = Notification.Name("KKBOXOpenAPIDidLogout")
}

//MARK: -

/// The class helps you to access KKBOX's Open API in Swift programming
/// language.
///
/// Please create an instance of the class by calling
/// `KKBOXOpenAPI.init(clientID:, secret:, scope:)` and then fetch an access
/// token by passing a client credential. Then you can do the other API calls.
public class KKBOXOpenAPI {

	/// Create an instance of KKBOXOpenAPI by giving a client ID and
	/// secret.
	///
	/// To obtain a client ID and secret, visit [KKBOX's Developer
	/// Site](https://developer.kkbox.com) .
	///
	/// - Parameters:
	///   - clientID: A valid client ID
	///   - secret: A valid client Secret
	///   - scope: Scope of the client.
	public init(clientID: String, secret: String, scope: KKScope = .none) {
		self.clientID = clientID
		self.clientSecret = secret
		self.requestScope = scope
		self.restoreAccessToken()
	}

	private var clientID: String
	private var clientSecret: String

	/// Scope of the client. It is `KKScope.none` by default.
	public var requestScope: KKScope = .none
	/// The current access token.
	public private(set) var accessToken: KKAccessToken? {
		didSet {
			if self.accessToken == nil {
				NotificationCenter.default.post(name: .KKBOXOpenAPIDidLogout, object: self)
			} else {
				NotificationCenter.default.post(name: .KKBOXOpenAPIDidLogin, object: self)
			}
		}
	}
	/// MARK: - Authentication

	/// If the user has logged-in into KKBOX or not.
	public var isLoggedIn: Bool {
		return accessToken != nil
	}

	/// Remove current access token.
	public func logout() {
		self.accessToken = nil
		let key = "\(KKBOXAccessTokenSettingKey)_\(self.clientID)"
		UserDefaults.standard.removeObject(forKey: key)
	}

	private func saveAccessToken() {
		let key = "\(KKBOXAccessTokenSettingKey)_\(self.clientID)"
		let encoder = JSONEncoder()
		do {
			let data = try encoder.encode(self.accessToken)
			UserDefaults.standard.set(data, forKey: key)
			UserDefaults.standard.synchronize()
		} catch {
		}
	}

	private func restoreAccessToken() {
		let key = "\(KKBOXAccessTokenSettingKey)_\(self.clientID)"
		guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
			return
		}
		let decoder = JSONDecoder()
		do {
			self.accessToken = try decoder.decode(KKAccessToken.self, from: data)
		} catch {
		}
	}

}

extension KKBOXOpenAPI {

	/// Fetch an access token by passing client credential.
	///
	/// - Parameters:
	///   - callback: The callback closure.
	///   - result: The access token.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.failedToCreateClientCredential
	public func fetchAccessTokenByClientCredential(callback: @escaping (_ result: KKAPIResult<KKAccessToken>) -> ()) throws -> URLSessionTask {
		func makeClientCredential() -> String? {
			let base = "\(self.clientID):\(self.clientSecret)"
			let credential = base.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
			return credential
		}

		guard let credential = makeClientCredential() else {
			throw KKBOXOpenAPIError.failedToCreateClientCredential
		}
		let headers = ["Authorization": "Basic \(credential)"]
		let parameters = ["grant_type": "client_credentials", "scope": self.requestScope.toString()]
		return self.post(url: URL(string: KKOauthTokenURL)!, postParameters: parameters, headers: headers, callback: self.loginAPICallback(callback: callback))
	}

}

//MARK: -

extension KKBOXOpenAPI {

	//MARK: Tracks

	/// Fetch a song track by giving a song track ID.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#tracks_track_id).
	///
	/// - Parameters:
	///   - ID: ID of the track.
	///   - territory: The Territory
	///   - callback: The callback closure.
	///   - result: The result that contains the song track info.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(track ID: String, territory: KKTerritory = .taiwan, callback: @escaping (_ result: KKAPIResult<KKTrackInfo>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)tracks/\(escape(ID))?territory=\(territory.toString())"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}
}

extension KKBOXOpenAPI {

	//MARK: Albums

	/// Fetch an album by giving an album ID.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#albums_album_id).
	///
	/// - Parameters:
	///   - ID: ID of the album.
	///   - territory: The Territory.
	///   - callback: The callback closure.
	///   - result: The result that contains the album info.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(album ID: String, territory: KKTerritory = .taiwan, callback: @escaping (_ result: KKAPIResult<KKAlbumInfo>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)albums/\(escape(ID))?territory=\(territory.toString())"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}

	/// Fetch tracks contained in an album.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#albums_album_id_tracks).
	///
	/// - Parameters:
	///   - ID: ID of the album.
	///   - territory: The Territory.
	///   - callback: The callback closure.
	///   - result: The result that contains tracks of the album.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(tracksInAlbum ID: String, territory: KKTerritory = .taiwan, callback: @escaping (_ result: KKAPIResult<KKTrackList>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)albums/\(escape(ID))/tracks?territory=\(territory.toString())"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}
}

extension KKBOXOpenAPI {

	//MARK: Artist

	/// Fetch the profile by giving an artist ID.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#artists_artist_id).
	///
	/// - Parameters:
	///   - ID: ID of the artist.
	///   - territory: The Territory.
	///   - callback: The callback closure.
	///   - result: The result that contains profile of the artist.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(artist ID: String, territory: KKTerritory = .taiwan, callback: @escaping (_ result: KKAPIResult<KKArtistInfo>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)artists/\(escape(ID))?territory=\(territory.toString())"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}

	/// Fetch albums of an artist.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#artists_artist_id_albums).
	///
	/// - Parameters:
	///   - ID: ID of the artist.
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 200 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains albums of the artist.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(albumsBelongToArtist ID: String, territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 200, callback: @escaping (_ result: KKAPIResult<KKAlbumList>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)artists/\(escape(ID))/albums?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}

	/// Fetch top tracks of an artist.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#artists_artist_id_top-tracks).
	///
	/// - Parameters:
	///   - ID: ID of the artist.
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 200 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains top tracks of the artist.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(topTracksOfArtist ID: String, territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 200, callback: @escaping (_ result: KKAPIResult<KKTrackList>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)artists/\(escape(ID))/top-tracks?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}

	/// Fetch related artists of an artist.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#artists_artist_id_related-artists).
	///
	/// - Parameters:
	///   - ID: ID of the artist.
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 20 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains related artists of the artist.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(relatedArtistsOfArtist ID: String, territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 20, callback: @escaping (_ result: KKAPIResult<KKArtistList>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)artists/\(escape(ID))/related-artists?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}
}

extension KKBOXOpenAPI {
	//MARK: Shared Playlists

	/// Fetch a playlist's metadata and tracks by giving the playlist ID
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#shared-playlists_playlist_id).
	///
	/// - Parameters:
	///   - ID: The playlist ID.
	///   - territory: The Territory.
	///   - callback: The callback closure.
	///   - result: The result that contains the metadata and tracks of the playlist.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(playlist ID: String, territory: KKTerritory = .taiwan, callback: @escaping (_ result: KKAPIResult<KKPlaylistInfo>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)shared-playlists/\(escape(ID))?territory=\(territory.toString())"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}

	/// Fetch tracks contained in a playlist.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#shared-playlists_playlist_id_tracks).
	///
	/// - Parameters:
	///   - ID: The playlist ID.
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 20 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains the metadata of the playlist.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(tracksInPlaylist ID: String, territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 20, callback: @escaping (_ result: KKAPIResult<KKTrackList>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)shared-playlists/\(escape(ID))/tracks?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}
}

extension KKBOXOpenAPI {
	//MARK: Featured Playlists

	/// Fetch the featured playlists.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#featured-playlists).
	///
	/// - Parameters:
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 100 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains the featured playlists.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetchFeaturedPlaylists(territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 100, callback: @escaping (_ result: KKAPIResult<KKPlaylistList>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)featured-playlists?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}
}

extension KKBOXOpenAPI {
	//MARK: New-Hits Playlists

	/// Fetch the New-Hits playlists.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#new-hits-playlists).
	///
	/// - Parameters:
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 10 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains the New-Hits playlists.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetchNewHitsPlaylists(territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 10, callback: @escaping (_ result: KKAPIResult<KKPlaylistList>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)new-hits-playlists?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}
}

extension KKBOXOpenAPI {
	//MARK: Featured Playlists Categories

	/// Fetch featured playlist categories.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#featured-playlist-categories).
	///
	/// - Parameters:
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 100 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains featured playlist categories.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetchFeaturedPlaylistCategories(territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 100, callback: @escaping (_ result: KKAPIResult<KKFeaturedPlaylistCategoryList>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)featured-playlist-categories?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}

	/// Fetch featured playlists in a category.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#featured-playlist-categories_category_id).
	///
	/// - Parameters:
	///   - ID: The category ID.
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 100 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains featured playlists.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetchFeaturedPlaylist(inCategory ID: String, territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 100, callback: @escaping (_ result: KKAPIResult<KKFeaturedPlaylistCategory>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)featured-playlist-categories/\(escape(ID))?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}
}

extension KKBOXOpenAPI {
	//MARK: Mood Radio Stations

	/// Fetch mood station categories.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#mood-stations).
	///
	/// - Parameters:
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 100 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains the mood station categories.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetchMoodStations(territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 100, callback: @escaping (_ result: KKAPIResult<KKRadioStationList>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)mood-stations?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}

	/// Fetch tracks in a mood radio station.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#mood-stations_station_id).
	///
	/// - Parameters:
	///   - ID: Mood station ID
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 100 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains the tracks.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(tracksInMoodStation ID: String, territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 100, callback: @escaping (_ result: KKAPIResult<KKRadioStation>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)mood-stations/\(escape(ID))?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}

	//MARK: Genre Radio Stations

	/// Fetch genre station categories.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#genre-stations).
	///
	/// - Parameters:
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 100 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains the mood genre categories.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetchGenreStations(territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 100, callback: @escaping (_ result: KKAPIResult<KKRadioStationList>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)genre-stations?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}

	/// Fetch tracks in a genre radio station.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#genre-stations_station_id).
	///
	/// - Parameters:
	///   - ID: Genre station ID
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 100 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains the tracks.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(tracksInGenreStation ID: String, territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 100, callback: @escaping (_ result: KKAPIResult<KKRadioStation>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)genre-stations/\(escape(ID))?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}
}

extension KKBOXOpenAPI {
	//MARK: New Released Albums

	/// Fetch the categories of the new released albums.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#new-release-categories).
	///
	/// - Parameters:
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 100 by default.
	///   - callback: The callback closure.
	///	  - result: The result that contains the categories.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetchNewReleaseAlbumsCategories(territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 100, callback: @escaping (_ result: KKAPIResult<KKNewReleasedAlbumsCategoryList>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)new-release-categories?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}

	/// Fetch albums in a given new released albums category.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#new-release-categories_category_id).
	///
	/// - Parameters:
	///   - ID: The category ID.
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 100 by default.
	///   - callback: The callback closure.
	///	  - result: The result that contains the albums.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(newReleasedAlbumsUnderCategory ID: String, territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 100, callback: @escaping (_ result: KKAPIResult<KKNewReleasedAlbumsCategory>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)new-release-categories/\(escape(ID))?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}
}

extension KKBOXOpenAPI {
	//MARK: Charts

	/// Fetch charts.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#charts).
	///
	/// - Parameters:
	///   - territory: The Territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 50 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains the charts.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetchCharts(territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 50, callback: @escaping (_ result: KKAPIResult<KKPlaylistList>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)charts?territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}
}

extension KKBOXOpenAPI {
	//MARK: Search

	/// Search in KKBOX's music library.
	///
	/// See [API reference](https://docs-en.kkbox.codes/v1.1/reference#search).
	///
	/// - Parameters:
	///   - keyword: The search keyword.
	///   - types: Artists, albums, tracks or playlists.
	///   - territory: The territory.
	///   - offset: The offset. 0 by default.
	///   - limit: The limit. 50 by default.
	///   - callback: The callback closure.
	///   - result: The result that contains search results.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func search(with keyword: String, types: KKSearchType, territory: KKTerritory = .taiwan, offset: Int = 0, limit: Int = 50, callback: @escaping (_ result: KKAPIResult<KKSearchResults>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)search?q=\(escape_arg(keyword))&type=\(types.toString())&territory=\(territory.toString())&offset=\(offset)&limit=\(limit)"
		print(urlString)
		return try self.get(url: URL(string: urlString)!, callback: self.apiDataCallback(callback: callback))
	}
}

//MARK: -

extension KKBOXOpenAPI {

	private func loginAPICallback(callback: @escaping (KKAPIResult<KKAccessToken>) -> ()) -> (KKAPIResult<Data>) -> () {
		return { result in
			switch result {
			case .error(let error):
				callback(.error(error))
			case .success(let data):
				do {
					let decoder = JSONDecoder()
					let accessToken = try decoder.decode(KKAccessToken.self, from: data)
					self.accessToken = accessToken
					self.saveAccessToken()
					callback(.success(accessToken))
				} catch {
					let decoder = JSONDecoder()
					let decodedError = try? decoder.decode(KKLoginError.self, from: data)
					if let decodedError = decodedError {
						let userInfo = [NSLocalizedDescriptionKey: decodedError.error,
						                NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Please follow the error description to fix your API calls.", comment: "")]
						let customError = NSError(domain: KKErrorDomain, code: 0, userInfo: userInfo)
						callback(.error(customError as Error))
					} else {
						callback(.error(error))
					}
				}
			}
		}
	}

	private func apiDataCallback<T: Codable>(callback: @escaping (KKAPIResult<T>) -> ()) -> (KKAPIResult<Data>) -> () {
		return { result in
			switch result {
			case .error(let error):
				callback(.error(error))
			case .success(let data):
				let decodedError = try? JSONDecoder().decode(KKAPIErrorResponse.self, from: data)
				if let decodedError = decodedError {
					let customError = NSError(domain: KKErrorDomain, code: decodedError.error.code, userInfo: [NSLocalizedDescriptionKey: decodedError.error.message ?? ""])
					DispatchQueue.main.async {
						callback(.error(customError))
					}
					return
				}
				do {
					let decoder = JSONDecoder()
					let formatter = DateFormatter()
					formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
					decoder.dateDecodingStrategy = .formatted(formatter)
					let track = try decoder.decode(T.self, from: data)
					callback(.success(track))
				} catch {
					callback(.error(error))
				}
			}
		}
	}
}

extension KKBOXOpenAPI {
	private func connectionHandler(callback: @escaping (KKAPIResult<Data>) -> ()) -> (Data?, URLResponse?, Error?) -> () {
		return { data, response, error in
			if let error = error {
				DispatchQueue.main.async {
					callback(.error(error))
				}
				return
			}
			let code = (response as? HTTPURLResponse)?.statusCode ?? 200
			if code != 200 {
				let error = NSError(domain: KKErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: "API call failed with status code \(code)"])
				DispatchQueue.main.async {
					callback(.error(error))
				}
				return
			}

			guard let data = data else {
				DispatchQueue.main.async {
					callback(.error(KKBOXOpenAPIError.invalidResponse))
				}
				return
			}
			DispatchQueue.main.async {
				callback(.success(data))
			}
		}
	}

	private func post(url: URL, postParameters: [AnyHashable: Any], headers: [String: String], callback: @escaping (KKAPIResult<Data>) -> ()) -> URLSessionTask {
		var headers = headers
		headers["Content-type"] = "application/x-www-form-urlencoded"
		let parameterString = postParameters.map {
			"\($0)=\($1)"
		}.joined(separator: "&")
		return post(url: url, data: parameterString.data(using: .utf8), headers: headers, callback: callback)
	}

	private func post(url: URL, data: Data?, headers: [String: String], callback: @escaping (KKAPIResult<Data>) -> ()) -> URLSessionTask {
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		for (k, v) in headers {
			request.setValue(v, forHTTPHeaderField: k)
		}
		request.setValue(KKUserAgent, forHTTPHeaderField: "User-Agent")
		request.httpBody = data
		let task = URLSession.shared.dataTask(with: request, completionHandler: self.connectionHandler(callback: callback))
		task.resume()
		return task
	}

	private func get(url: URL, callback: @escaping (KKAPIResult<Data>) -> ()) throws -> URLSessionTask {
		guard let accessToken = self.accessToken else {
			throw KKBOXOpenAPIError.requireAccessToken
		}
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue(KKUserAgent, forHTTPHeaderField: "User-Agent")
		request.setValue("Bearer \(accessToken.accessToken)", forHTTPHeaderField: "Authorization")
		let task = URLSession.shared.dataTask(with: request, completionHandler: self.connectionHandler(callback: callback))
		task.resume()
		return task
	}


}
