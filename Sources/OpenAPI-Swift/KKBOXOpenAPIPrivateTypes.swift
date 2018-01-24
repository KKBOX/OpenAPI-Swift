import Foundation

struct KKLoginError: Codable {
	var error: String
}

struct KKAPIError: Codable {
	var code: Int
	var message: String?
}

struct KKAPIErrorResponse: Codable {
	var error: KKAPIError
}

