//
//  Angle.swift
//  tvOS_App
//
//  Created by Apple on 1/29/16.
//  Copyright © 2016 PumpkinSpiceGirls. All rights reserved.
//

import Foundation

class Angle{
    var Value : Double
    {
        get
        {
            return value;
        }
    }
    private var value : Double;
    
    init()
    {
        value = 0.0;
    }
    
    init(value: Double)
    {
        self.value = value;
        while (self.value > M_PI)
        {
            self.value -= 2 * M_PI;
        }
        while (self.value < -M_PI)
        {
            self.value += 2 * M_PI;
        }
    }
    
    
}


func +(lhs: Angle, rhs: Angle) -> Angle
{
    return Angle(value: lhs.Value + rhs.Value);
}
func -(lhs: Angle, rhs: Angle) -> Angle
{
    return Angle(value: lhs.Value - rhs.Value);
}

func >(lhs: Angle, rhs: Angle) -> Bool
{
    return ((lhs.Value > rhs.Value && lhs.Value < rhs.Value + M_PI) || lhs.Value < rhs.Value - M_PI);
}

func <(lhs: Angle, rhs: Angle) -> Bool
{
    return ((lhs.Value < rhs.Value && lhs.Value > rhs.Value - M_PI) || lhs.Value > rhs.Value + M_PI);
}

func ==(lhs: Angle, rhs: Angle) -> Bool
{
    return lhs.Value == rhs.Value;
}