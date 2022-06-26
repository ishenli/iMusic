//
//  Cookie.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/25.
//

import Foundation

// @see https://developer.apple.com/documentation/foundation/httpcookiestorage

public func GetCookieStorage()->HTTPCookieStorage{
  return HTTPCookieStorage.shared
}


public func GetCookieArray()->[HTTPCookie]{
  
  let cookieStorage = GetCookieStorage()
  let cookieArray = cookieStorage.cookies
  if cookieArray != nil {
    return cookieArray!
  }
  else{
    return []
  }
}


public func GetCookieByUrlAndName(url: URL, cookieName: String) -> String? {
  let cookieArray :[HTTPCookie] = HTTPCookieStorage.shared.cookies(for: url) ?? [];
  
  var value:String?
  
  if cookieArray.count > 0 {
    for cookie in cookieArray
    {
      if cookie.name == cookieName
      {
        value = cookie.value
        break
      }
    }
  }
  return value
}


public func GetCookieByName(_ cookieName:String)->String?
{
  let cookieArray:[HTTPCookie] = GetCookieArray()
  var value:String?
  if cookieArray.count > 0 {
    for cookie in cookieArray
    {
      if cookie.name == cookieName
      {
        value = cookie.value
        break
      }
    }
  }
  return value
}
