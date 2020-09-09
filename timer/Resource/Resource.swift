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
    /// Project's font resources
    public enum Font {
        // MARK: - 1.0
        public static let light = UIFont(name: "NanumSquareL", size: 17.0)!
        public static let regular = UIFont(name: "NanumSquareR", size: 17.0)!
        public static let bold = UIFont(name: "NanumSquareB", size: 17.0)!
        public static let extraBold = UIFont(name: "NanumSquareEB", size: 17.0)!
        
        // MARK: - 2.0
        public static let mainTimer = UIFont(name: "NotoSansCJKkr-Black", size: 30)!
        public static let subTimer = UIFont(name: "NotoSansCJKkr-Black", size: 20)!
        public static let header = UIFont(name: "NotoSansCJKkr-Bold", size: 18)!
        public static let title = UIFont(name: "NotoSansCJKkr-Bold", size: 15)!
        public static let body = UIFont(name: "NotoSansCJKkr-Regular", size: 12)!
        public static let subInfo = UIFont(name: "NotoSansCJKkr-Regular", size: 10)!
    }
    
    /// Project's color resources
    public enum Color {
        public static var clear: UIColor { .clear }
        
        // MARK: - 1.0
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
        
        // MARK: - 2.0
        // MARK: - Red
        public static var red1: UIColor { UIColor(named: "red_1")! }
        
        // MARK: - Blue
        public static var blue1: UIColor { UIColor(named: "blue_1")! }
        
        // MARK: - Green
        public static var green1: UIColor { UIColor(named: "green_1")! }
        
        // MARK: - Grey
        public static var grey1: UIColor { UIColor(named: "grey_1")! }
        public static var grey2: UIColor { UIColor(named: "grey_2")! }
        public static var grey3: UIColor { UIColor(named: "grey_3")! }
        public static var grey4: UIColor { UIColor(named: "grey_4")! }
        public static var grey5: UIColor { UIColor(named: "grey_5")! }
        public static var grey6: UIColor { UIColor(named: "grey_6")! }
        public static var grey7: UIColor { UIColor(named: "grey_7")! }
    }
    
    /// Project's icon resources
    public enum Icon {
        // MARK: - 1.0
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
        
        // MARK: - 2.0
        public static var iconBtnAlarmSlient: UIImage { UIImage(named: "icon_btn_alarm_silent")! }
        public static var iconBtnAlarmSound: UIImage { UIImage(named: "icon_btn_alarm_sound")! }
        public static var iconBtnAlarmVibe: UIImage { UIImage(named: "icon_btn_alarm_vibe")! }
        public static var iconBtnBack: UIImage { UIImage(named: "icon_btn_back")! }
        public static var iconBtnCancel: UIImage { UIImage(named: "icon_btn_cancel")! }
        public static var iconBtnCardView: UIImage { UIImage(named: "icon_btn_card_view")! }
        public static var iconBtnChangeShort: UIImage { UIImage(named: "icon_btn_change_short")! }
        public static var iconBtnCloseBig: UIImage { UIImage(named: "icon_btn_close_big")! }
        public static var iconBtnCloseSmall: UIImage { UIImage(named: "icon_btn_close_small")! }
        public static var iconBtnConfirm: UIImage { UIImage(named: "icon_btn_confirm")! }
        public static var iconBtnDownArrow: UIImage { UIImage(named: "icon_btn_down_arrow")! }
        public static var iconBtnHistory: UIImage { UIImage(named: "icon_btn_history")! }
        public static var iconBtnListView: UIImage { UIImage(named: "icon_btn_list_view")! }
        public static var iconBtnMemo: UIImage { UIImage(named: "icon_btn_memo")! }
        public static var iconBtnMinusRed: UIImage { UIImage(named: "icon_btn_minus_red")! }
        public static var iconBtnModifyCircle: UIImage { UIImage(named: "icon_btn_modify_circle")! }
        public static var iconBtnModify: UIImage { UIImage(named: "icon_btn_modify")! }
        public static var iconBtnPauseCircle: UIImage { UIImage(named: "icon_btn_pause_circle")! }
        public static var iconBtnPause: UIImage { UIImage(named: "icon_btn_pause")! }
        public static var iconBtnPlayCircle: UIImage { UIImage(named: "icon_btn_play_circle")! }
        public static var iconBtnPlay: UIImage { UIImage(named: "icon_btn_play")! }
        public static var iconBtnPlusBlue: UIImage { UIImage(named: "icon_btn_plus_blue")! }
        public static var iconBtnPlusUnAct: UIImage { UIImage(named: "icon_btn_plus_un_act")! }
        public static var iconBtnPlus: UIImage { UIImage(named: "icon_btn_plus")! }
        public static var iconBtnRepeatO: UIImage { UIImage(named: "icon_btn_repeat_o")! }
        public static var iconBtnRepeatX: UIImage { UIImage(named: "icon_btn_repeat_x")! }
        public static var iconBtnRightArrow: UIImage { UIImage(named: "icon_btn_right_arrow")! }
        public static var iconBtnSelected: UIImage { UIImage(named: "icon_btn_selected")! }
        public static var iconBtnSettings: UIImage { UIImage(named: "icon_btn_settings")! }
        public static var iconBtnTimer: UIImage { UIImage(named: "icon_btn_timer")! }
        public static var iconBtn: UIImage { UIImage(named: "icon_btn")! }
    }
}
