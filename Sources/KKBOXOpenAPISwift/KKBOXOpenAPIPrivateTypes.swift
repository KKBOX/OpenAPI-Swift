//
// KKBOXOpenAPIPrivateTypes.swift
//
// Copyright (c) 2019 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

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

