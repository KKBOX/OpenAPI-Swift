import Foundation

private let KKUserAgent = "KKBOX Open API Swift SDK"
private let KKOauthTokenURL = "https://account.kkbox.com/oauth2/token"
private let KKErrorDomain = "KKErrorDomain"
private let KKBOXAPIPath = "https://api.kkbox.com/v1.1/"

private func escape(_ string: String) -> String {
	return string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
}

private func escape_arg(_ string: String) -> String {
	return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
}


/// An access token.
public struct KKAccessToken: Codable {
	/// The access token string.
	public private(set) var accessToken: String
	/// When will the access token expires.
	public private(set) var expiresIn: TimeInterval
	/// Type of the access token.
	public private(set) var tokenType: String?
	/// Scope of the access token.
	public private(set) var scope: String?

	private enum CodingKeys: String, CodingKey {
		case accessToken = "access_token"
		case expiresIn = "expires_in"
		case tokenType = "token_type"
		case scope = "scope"
	}
}

/// The territory that KKBOX provides services.
///
/// - taiwan: Taiwan
/// - hongkong: HongKong
/// - singapore: Singapore
/// - maylaysia: Maylaysia
/// - japan: Japan
/// - thailand: Thailand
public enum KKTerritoryCode: String {
	case taiwan = "TW"
	case hongkong = "HK"
	case singapore = "SG"
	case maylaysia = "MY"
	case japan = "JP"
	case thailand = "TH"

	fileprivate func toString() -> String {
		return self.rawValue
	}
}

public struct KKSearchType: OptionSet {
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}

	public let rawValue: Int
	public static let none = KKSearchType(rawValue: 0)
	public static let artist = KKSearchType(rawValue: 1 << 0)
	public static let album = KKSearchType(rawValue: 1 << 1)
	public static let track = KKSearchType(rawValue: 1 << 2)
	public static let playlist = KKSearchType(rawValue: 1 << 2)
}

public struct KKScope: OptionSet {
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}

	public let rawValue: Int
	public static let none = KKScope(rawValue: 0)
	public static let userProfile = KKScope(rawValue: 1 << 0)
	public static let userTerritory = KKScope(rawValue: 1 << 1)
	public static let userAccountStatus = KKScope(rawValue: 1 << 2)
	public static let all: KKScope = [.userProfile, .userTerritory, .userAccountStatus]

	fileprivate func toString() -> String {
		if self == KKScope.all {
			return "all"
		}
		var scapeStrings = [String]()
		if self.rawValue & KKScope.userProfile.rawValue != 0 {
			scapeStrings.append("user_profile")
		}
		if self.rawValue & KKScope.userTerritory.rawValue != 0 {
			scapeStrings.append("user_territory")
		}
		if self.rawValue & KKScope.userAccountStatus.rawValue != 0 {
			scapeStrings.append("user_account_status")
		}
		return scapeStrings.joined(separator: " ")
	}
}


/// The response of API calls
///
/// - error: the API retuns an error with an error object.
/// - success: the API is successfully called and return an object.
public enum KKResult<T> {
	case success(T)
	case error(Error)
}

public enum KKBOXOpenAPIError: Error, LocalizedError {
	case failedToCreateClientCredential
	case invalidResponse
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

//MARK: -

/// The class helps you to access KKBOX's Open API in Swift
/// programming language.
///
/// Please create an instance of the class by calling `init(clientID:
/// String, secret: String)` and then fetch an access token by passing
/// a client credential. Then you can do the other API calls.
public class KKBOXOpenAPI {

	private var clientID: String
	private var clientSecret: String

	/// Scope of the client. It is KKScope.userProfile by default.
	public var requestScope: KKScope = .all
	/// The current access token.
	public private(set) var accessToken: KKAccessToken?
	/// If the user has logged-in into KKBOX or not.
	public var isLoggedIn: Bool {
		return accessToken != nil
	}

	/// Remove current access token.
	public func logout() {
		self.accessToken = nil
	}

	/// Create an instance of KKBOXOpenAPI by giving a client ID and
	/// secret.
	///
	/// To obtain a client ID and secret, visit [KKBOX's Developer
	/// Site](https://developer.kkbox.com) .
	///
	/// - Parameters:
	///   - clientID: A valid client ID
	///   - secret: A valid client Secret
	public init(clientID: String, secret: String) {
		self.clientID = clientID
		self.clientSecret = secret
	}

	private func loginAPICallback(callback: @escaping (KKResult<KKAccessToken>) -> ()) -> (KKResult<Data>) -> () {
		return { result in
			switch result {
			case .error(let error):
				callback(.error(error))
			case .success(let data):
				do {
					let decoder = JSONDecoder()
					let accessToken = try decoder.decode(KKAccessToken.self, from: data)
					self.accessToken = accessToken
					callback(.success(accessToken))
				} catch {
					let decoder = JSONDecoder()
					let kkError = try? decoder.decode(KKLoginError.self, from: data)
					if let kkError = kkError {
						let customError = NSError(domain: KKErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: kkError.error])
						callback(.error(customError as Error))
					} else {
						callback(.error(error))
					}
				}
				break
			}
		}
	}

	/// Fetch an access token by passing client credential.
	///
	/// - Parameters:
	///   - callback: The callback closure.
	///	  - result: The access token.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.failedToCreateClientCredential
	public func fetchAccessTokenByClientCredential(callback: @escaping (_ result: KKResult<KKAccessToken>) -> ()) throws -> URLSessionTask {
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

extension KKBOXOpenAPI {

	private func apiCallBack<T: Codable>(callback: @escaping (KKResult<T>) -> ()) -> (KKResult<Data>) -> () {
		return { result in
			switch result {
			case .error(let error):
				callback(.error(error))
			case .success(let data):
				do {
					let decoder = JSONDecoder()
					let track = try decoder.decode(T.self, from: data)
					callback(.success(track))
				} catch {
					callback(.error(error))
				}
			}
		}
	}

	//MARK: Tracks

	/// Fetch a song track by giving a song track ID.
	///
	/// - Parameters:
	///   - ID: ID of the track.
	///   - territory: The Territory
	///   - callback: The callback closure.
	///	  - result: The result that contains the song track info.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(track ID: String, territory: KKTerritoryCode = .taiwan, callback: @escaping (_ result: KKResult<KKTrackInfo>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)tracks/\(escape(ID))?territory=\(territory.toString())"
		return try self.call(url: URL(string: urlString)!, callback: self.apiCallBack(callback: callback))
	}

	//MARK: Albums

	/// Fetch an album by giving an album ID.
	///
	/// - Parameters:
	///   - ID: ID of the album.
	///   - territory: The Territory
	///   - callback: The callback closure.
	///	  - result: The result that contains the album info.
	/// - Returns: A URLSessionTask that you can use it to cancel current fetch.
	/// - Throws: KKBOXOpenAPIError.requireAccessToken.
	public func fetch(album ID: String, territory: KKTerritoryCode = .taiwan, callback: @escaping (_ result: KKResult<KKAlbumInfo>) -> ()) throws -> URLSessionTask {
		let urlString = "\(KKBOXAPIPath)albums/\(escape(ID))?territory=\(territory.toString())"
		return try self.call(url: URL(string: urlString)!, callback: self.apiCallBack(callback: callback))
	}
}

extension KKBOXOpenAPI {
	private func post(url: URL, postParameters: [AnyHashable: Any], headers: [String: String], callback: @escaping (KKResult<Data>) -> ()) -> URLSessionTask {
		var headers = headers
		headers["Content-type"] = "application/x-www-form-urlencoded"
		let parameterString = postParameters.map {
			"\($0)=\($1)"
		}.joined(separator: "&")
		return post(url: url, data: parameterString.data(using: .utf8), headers: headers, callback: callback)
	}

	private func post(url: URL, data: Data?, headers: [String: String], callback: @escaping (KKResult<Data>) -> ()) -> URLSessionTask {
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		for (k, v) in headers {
			request.setValue(v, forHTTPHeaderField: k)
		}
		request.setValue(KKUserAgent, forHTTPHeaderField: "User-Agent")
		request.httpBody = data
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
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
		task.resume()
		return task
	}

	func call(url: URL, callback: @escaping (KKResult<Data>) -> ()) throws -> URLSessionTask {
		guard let accessToken = self.accessToken else {
			throw KKBOXOpenAPIError.requireAccessToken
		}
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue(KKUserAgent, forHTTPHeaderField: "User-Agent")
		request.setValue("Bearer \(accessToken.accessToken)", forHTTPHeaderField: "Authorization")
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
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
			let decoder = JSONDecoder()
			let kkError = try? decoder.decode(KKAPIErrorResponse.self, from: data)
			if let kkError = kkError {
				let customError = NSError(domain: KKErrorDomain, code: kkError.error.code, userInfo: [NSLocalizedDescriptionKey: kkError.error.message ?? ""])
				DispatchQueue.main.async {
					callback(.error(customError))
				}
				return
			}
			DispatchQueue.main.async {
//				let s = String(data:data, encoding:.utf8)
//				print(s)
				callback(.success(data))
			}
		}
		task.resume()
		return task
	}


}
