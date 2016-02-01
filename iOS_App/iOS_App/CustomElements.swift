//
//  CustomElements.swift
//  iOS_App
//
//  Created by Apple on 1/31/16.
//  Copyright © 2016 PumpkinSpiceGirls. All rights reserved.
//

import Foundation

public enum CustomElementType: Int {
    
    case FiddlestickX   = 50
    case FiddlestickY   = 51
    case FiddlestickZ   = 52
    case Keyboard       = 53
    
}

public class CustomElements : CustomElementsSuperclass {
    override init()
    {
        super.init();
        
        //Set up custom stuff here
        customProfileElements = [
            CustomElement(name: "Fiddlestick X", dataType: .Float, type:CustomElementType.FiddlestickX.rawValue),
            CustomElement(name: "Fiddlestick Y", dataType: .Float, type:CustomElementType.FiddlestickY.rawValue),
            CustomElement(name: "Fiddlestick Z", dataType: .Float, type:CustomElementType.FiddlestickZ.rawValue),
            CustomElement(name: "Keyboard", dataType: .String, type:CustomElementType.Keyboard.rawValue)
        ]
    }
}