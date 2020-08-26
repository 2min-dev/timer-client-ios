//
//  Resource.swift
//  timer
//
//  Created by JSilver on 2020/08/26.
//  Copyright © 2020 Jeong Jin Eun. All rights reserved.
//

import UIKit

public typealias R = Resource

public enum Resource {
    public enum Color {
        public static var clear: UIColor { .clear }
        
        public static var alabaster: UIColor { UIColor(named: "alabaster")! }
        public static var carnation: UIColor { UIColor(named: "carnation")! }
        public static var codGray: UIColor { UIColor(named: "cod_gray")! }
        public static var darkBlue: UIColor { UIColor(named: "dark_blue")! }
        public static var doveGray: UIColor { UIColor(named: "dove_gray")! }
        public static var gallery: UIColor { UIColor(named: "gallery")! }
        public static var navyBlue: UIColor { UIColor(named: "navy_blue")! }
        public static var silver: UIColor { UIColor(named: "silver")! }
        public static var white: UIColor { UIColor(named: "white")! }
        public static var white_fdfdfd: UIColor { UIColor(named: "white#fdfdfd")! }
    }
    
    public enum Icon {
        public static var icApp: UIImage { UIImage(named: "ic_app")! }
        public static var icArrowRightDown: UIImage { UIImage(named: "ic_arrow_down")! }
        public static var icArrowRightCarnation: UIImage { UIImage(named: "ic_arrow_right_carnation")! }
        public static var icArrowRightWhite: UIImage { UIImage(named: "ic_arrow_right_white")! }
        public static var icArrowRight: UIImage { UIImage(named: "ic_arrow_right")! }
        public static var icBtnBack: UIImage { UIImage(named: "ic_btn_back")! }
        public static var icBtnChange: UIImage { UIImage(named: "ic_btn_change")! }
        public static var icBtnClearMini: UIImage { UIImage(named: "ic_btn_clear_mini")! }
        public static var icBtnClear: UIImage { UIImage(named: "ic_btn_clear")! }
        public static var icBtnConfirmWhite: UIImage { UIImage(named: "ic_btn_confirm_white")! }
        public static var icBtnConfirm: UIImage { UIImage(named: "ic_btn_confirm")! }
        public static var icBtnDeleteMini: UIImage { UIImage(named: "ic_btn_delete_mini")! }
        public static var icBtnDelete: UIImage { UIImage(named: "ic_btn_delete")! }
        public static var icBtnHistory: UIImage { UIImage(named: "ic_btn_history")! }
        public static var icBtnHome: UIImage { UIImage(named: "ic_btn_home")! }
        public static var icBtnPause: UIImage { UIImage(named: "ic_btn_pause")! }
        public static var icBtnPlay: UIImage { UIImage(named: "ic_btn_play")! }
        public static var icBtnRepeatDisable: UIImage { UIImage(named: "ic_btn_repeat_disable")! }
        public static var icBtnRepeatOff: UIImage { UIImage(named: "ic_btn_repeat_off")! }
        public static var icBtnRepeatOn: UIImage { UIImage(named: "ic_btn_repeat_on")! }
        public static var icBtnSearch: UIImage { UIImage(named: "ic_btn_search")! }
        public static var icBtnSetting: UIImage { UIImage(named: "ic_btn_setting")! }
        public static var icBtnShare: UIImage { UIImage(named: "ic_btn_share")! }
        public static var icBtnTabHome: UIImage { UIImage(named: "ic_btn_tab_home")! }
        public static var icBtnTabMy: UIImage { UIImage(named: "ic_btn_tab_my")! }
        public static var icBtnTabShare: UIImage { UIImage(named: "ic_btn_tab_share")! }
        public static var icBtnTimerEdit: UIImage { UIImage(named: "ic_btn_timer_edit")! }
        public static var icBtnTimesetAdd: UIImage { UIImage(named: "ic_btn_timeset_add")! }
        public static var icBtnTimesetDelete: UIImage { UIImage(named: "ic_btn_timeset_delete")! }
        public static var icBtnTimesetRecover: UIImage { UIImage(named: "ic_btn_timeset_recover")! }
        public static var icKeypadDelete: UIImage { UIImage(named: "ic_keypad_delete")! }
        public static var icMemo: UIImage { UIImage(named: "ic_memo")! }
        public static var icSelected: UIImage { UIImage(named: "ic_selected")! }
        public static var icSound: UIImage { UIImage(named: "ic_sound")! }
        public static var icTimerWhite: UIImage { UIImage(named: "ic_timer_white")! }
        public static var icTimer: UIImage { UIImage(named: "ic_timer")! }
    }
}
