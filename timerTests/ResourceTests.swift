//
//  ResourceTests.swift
//  timerTests
//
//  Created by JSilver on 2020/08/27.
//  Copyright © 2020 Jeong Jin Eun. All rights reserved.
//

import XCTest
@testable import timer

class ResourceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadImages() throws {
        _ = R.Icon.icApp
        _ = R.Icon.icArrowRightDown
        _ = R.Icon.icArrowRightCarnation
        _ = R.Icon.icArrowRightWhite
        _ = R.Icon.icArrowRight
        _ = R.Icon.icBtnBack
        _ = R.Icon.icBtnChange
        _ = R.Icon.icBtnClearMini
        _ = R.Icon.icBtnClear
        _ = R.Icon.icBtnConfirmWhite
        _ = R.Icon.icBtnConfirm
        _ = R.Icon.icBtnDeleteMini
        _ = R.Icon.icBtnDelete
        _ = R.Icon.icBtnHistory
        _ = R.Icon.icBtnHome
        _ = R.Icon.icBtnPause
        _ = R.Icon.icBtnPlay
        _ = R.Icon.icBtnRepeatDisable
        _ = R.Icon.icBtnRepeatOff
        _ = R.Icon.icBtnRepeatOn
        _ = R.Icon.icBtnSearch
        _ = R.Icon.icBtnSetting
        _ = R.Icon.icBtnShare
        _ = R.Icon.icBtnTabHome
        _ = R.Icon.icBtnTabMy
        _ = R.Icon.icBtnTabShare
        _ = R.Icon.icBtnTimerEdit
        _ = R.Icon.icBtnTimesetAdd
        _ = R.Icon.icBtnTimesetDelete
        _ = R.Icon.icBtnTimesetRecover
        _ = R.Icon.icKeypadDelete
        _ = R.Icon.icMemo
        _ = R.Icon.icSelected
        _ = R.Icon.icSound
        _ = R.Icon.icTimerWhite
        _ = R.Icon.icTimer
    }
    
    func testColors() throws {
        _ = R.Color.clear
        _ = R.Color.alabaster
        _ = R.Color.carnation
        _ = R.Color.codGray
        _ = R.Color.darkBlue
        _ = R.Color.doveGray
        _ = R.Color.gallery
        _ = R.Color.navyBlue
        _ = R.Color.silver
        _ = R.Color.white
        _ = R.Color.white_fdfdfd
    }
}
