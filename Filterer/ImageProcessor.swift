import Foundation
import UIKit

public enum Filter {
    case DOUBLERED, DOUBLEGREEN, DOUBLEBLUE, BLACKWHITE, HALFTRANSPARENT
}

public class ImageProcessor {
    
    public init(){

    }
    
    public func applyFilterByName(input: UIImage, filters: String...) -> UIImage {
        var internalFilter = [Filter]()
        for name in filters {
            switch name {
                case "DoubleRed":
                    internalFilter.append(Filter.DOUBLERED)
                case "DoubleGreen":
                    internalFilter.append(Filter.DOUBLEGREEN)
                case "DoubleBlue":
                    internalFilter.append(Filter.DOUBLEBLUE)
                case "BlackWhite":
                    internalFilter.append(Filter.BLACKWHITE)
                case "HalfTransparent":
                    internalFilter.append(Filter.HALFTRANSPARENT)
                default:
                    print("No filter found by name: \(name)")
            }
        }
        return applyFilter(input, filters: internalFilter)
    }
    
    public func applyFilter(input: UIImage, filters: [Filter], intensity:Int = 50) -> UIImage {
        var image =  RGBAImage(image: input)!
        for i in 0..<(image.width*image.height - 1) {
            var pixel = image.pixels[i]
            for filter in filters {
                switch filter {
                case .DOUBLERED:
                    //print("Apply double red filter")
                    pixel = doubleRed(pixel, intensity: intensity)
                case .BLACKWHITE:
                    //print("Apply black and white filter")
                    pixel = blackWhite(pixel)
                case .DOUBLEGREEN:
                    //print("Apply double green filter")
                    pixel = doubleGreen(pixel, intensity: intensity)
                case .DOUBLEBLUE:
                    //print("Apply double blue filter")
                    pixel = doubleBlue(pixel, intensity: intensity)
                case .HALFTRANSPARENT:
                    //print("Apply half transparent filter")
                    pixel = halfTransparent(pixel)
                }
            }
            image.pixels[i] = pixel
        }
        return image.toUIImage()!
    }
    
    public func blackWhite(pixel: Pixel) -> Pixel {
        var newPixel = pixel
        let avg = UInt8((Int(pixel.red) + Int(pixel.green) + Int(pixel.blue))/3)
        newPixel.red = avg
        newPixel.green = avg
        newPixel.blue = avg
        return newPixel
    }
    
    public func halfTransparent(pixel: Pixel) -> Pixel {
        var newPixel = pixel
        newPixel.alpha = UInt8(max(0, min(255,pixel.alpha / 2)))
        return newPixel
    }
    
    
    public func doubleRed(pixel: Pixel, intensity:Int) -> Pixel {
        var newPixel = pixel
        newPixel.red = UInt8(max(0, min(255, Int(pixel.red) * intensity/100*4)))
        return newPixel
    }
    
    public func doubleGreen(pixel: Pixel, intensity:Int) -> Pixel {
        var newPixel = pixel
        newPixel.green = UInt8(max(0, min(255, Int(pixel.green) * intensity/100*4)))
        return newPixel
    }
    
    public func doubleBlue(pixel: Pixel, intensity:Int) -> Pixel {
        var newPixel = pixel
        newPixel.blue = UInt8(max(0, min(255, Int(pixel.blue) * intensity/100*4)))
        return newPixel
    }

}

