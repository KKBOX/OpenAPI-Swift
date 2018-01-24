import Foundation

private let KKUserAgent = "KKBOX Open API Swift SDK"
private let KKOauthTokenURL = "https://account.kkbox.com/oauth2/token"
private let KKErrorDomain = "KKErrorDomain"

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
public enum KKTerritoryCode {
	case taiwan
	case hongkong
	case singapore
	case maylaysia
	case japan
	case thailand
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

	func toString() -> String {
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
	case invalidResponse

	public var errorDescription: String? {
		switch self {
		case .invalidResponse:
			return NSLocalizedString("Invalid response", comment: "")
		}
	}
}

/// The class helps you to access KKBOX's Open API in Swift
/// programming language.
///
/// Please create an instance of the class by calling `init(clientID:
/// String, secret: String)` and then fetch an access token by passing
/// a client credential. Then you can do the other API calls.
open class KKBOXOpenAPI {

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
					let kkError = try? decoder.decode(KKError.self, from: data)
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

	public func fetchAccessTokenByClientCredential(callback: @escaping (KKResult<KKAccessToken>) -> ()) {
		func makeClientCredential() -> String? {
			let base = "\(self.clientID):\(self.clientSecret)"
			let credential = base.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
			return credential
		}

		guard let credential = makeClientCredential() else {
			return
		}
		let headers = ["Authorization": "Basic \(credential)"]
		let parameters = ["grant_type": "client_credentials", "scope": self.requestScope.toString()]
		self.post(url: URL(string: KKOauthTokenURL)!, postParameters: parameters, headers: headers, callback: self.loginAPICallback(callback: callback))
	}

}

extension KKBOXOpenAPI {
	private func post(url: URL, postParameters: [AnyHashable: Any], headers: [String: String], callback: @escaping (KKResult<Data>) -> ()) {
		var headers = headers
		headers["Content-type"] = "application/x-www-form-urlencoded"
		let parameterString = postParameters.map {
			"\($0)=\($1)"
		}.joined(separator: "&")
		post(url: url, data: parameterString.data(using: .utf8), headers: headers, callback: callback)
	}

	private func post(url: URL, data: Data?, headers: [String: String], callback: @escaping (KKResult<Data>) -> ()) {
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
					callback(KKResult.error(error))
				}
				return
			}
			guard let data = data else {
				return callback(KKResult.error(KKBOXOpenAPIError.invalidResponse))
			}
			DispatchQueue.main.async {
				let s = String(data: data, encoding: .utf8)
				print("s: \(String(describing: s))")
				callback(KKResult.success(data))
			}
		}
		task.resume()
	}
}
