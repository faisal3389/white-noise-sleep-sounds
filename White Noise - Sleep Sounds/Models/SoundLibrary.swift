import Foundation

struct SoundLibrary {
    static let allSounds: [Sound] = [
        // MARK: - Noise (4 generated)
        Sound(id: "white_noise", name: "White Noise", category: .noise, fileName: "", backgroundImage: "bg_white_noise", isPremium: false, isGenerated: true),
        Sound(id: "pink_noise", name: "Pink Noise", category: .noise, fileName: "", backgroundImage: "bg_pink_noise", isPremium: true, isGenerated: true),
        Sound(id: "brown_noise", name: "Brown Noise", category: .noise, fileName: "", backgroundImage: "bg_brown_noise", isPremium: true, isGenerated: true),
        Sound(id: "blue_noise", name: "Blue Noise", category: .noise, fileName: "", backgroundImage: "bg_blue_noise", isPremium: true, isGenerated: true),

        // MARK: - Rain (4 file-based)
        Sound(id: "light_rain", name: "Light Rain", category: .rain, fileName: "light_rain.m4a", backgroundImage: "bg_light_rain", isPremium: false, isGenerated: false),
        Sound(id: "heavy_rain", name: "Heavy Rain", category: .rain, fileName: "heavy_rain.m4a", backgroundImage: "bg_heavy_rain", isPremium: true, isGenerated: false),
        Sound(id: "rain_on_roof", name: "Rain on Roof", category: .rain, fileName: "rain_on_roof.m4a", backgroundImage: "bg_rain_on_roof", isPremium: true, isGenerated: false),
        Sound(id: "thunderstorm", name: "Thunderstorm", category: .rain, fileName: "thunderstorm.m4a", backgroundImage: "bg_thunderstorm", isPremium: true, isGenerated: false),

        // MARK: - Nature (5 file-based)
        Sound(id: "forest", name: "Forest", category: .nature, fileName: "forest.m4a", backgroundImage: "bg_forest", isPremium: true, isGenerated: false),
        Sound(id: "birds", name: "Birds Singing", category: .nature, fileName: "birds.m4a", backgroundImage: "bg_birds", isPremium: true, isGenerated: false),
        Sound(id: "crickets", name: "Crickets", category: .nature, fileName: "crickets.m4a", backgroundImage: "bg_crickets", isPremium: true, isGenerated: false),
        Sound(id: "wind", name: "Wind", category: .nature, fileName: "wind.m4a", backgroundImage: "bg_wind", isPremium: true, isGenerated: false),
        Sound(id: "leaves", name: "Rustling Leaves", category: .nature, fileName: "leaves.m4a", backgroundImage: "bg_leaves", isPremium: true, isGenerated: false),

        // MARK: - Urban (3 file-based)
        Sound(id: "city_traffic", name: "City Traffic", category: .urban, fileName: "city_traffic.m4a", backgroundImage: "bg_city_traffic", isPremium: true, isGenerated: false),
        Sound(id: "cafe", name: "Cafe Ambience", category: .urban, fileName: "cafe.m4a", backgroundImage: "bg_cafe", isPremium: true, isGenerated: false),
        Sound(id: "train", name: "Train Ride", category: .urban, fileName: "train.m4a", backgroundImage: "bg_train", isPremium: true, isGenerated: false),

        // MARK: - Machine (4 file-based)
        Sound(id: "fan", name: "Fan", category: .machine, fileName: "fan.m4a", backgroundImage: "bg_fan", isPremium: true, isGenerated: false),
        Sound(id: "ac", name: "Air Conditioner", category: .machine, fileName: "ac.m4a", backgroundImage: "bg_ac", isPremium: true, isGenerated: false),
        Sound(id: "dryer", name: "Clothes Dryer", category: .machine, fileName: "dryer.m4a", backgroundImage: "bg_dryer", isPremium: true, isGenerated: false),
        Sound(id: "washing_machine", name: "Washing Machine", category: .machine, fileName: "washing_machine.m4a", backgroundImage: "bg_washing_machine", isPremium: true, isGenerated: false),

        // MARK: - Fire (3 file-based)
        Sound(id: "campfire", name: "Campfire", category: .fire, fileName: "campfire.m4a", backgroundImage: "bg_campfire", isPremium: false, isGenerated: false),
        Sound(id: "fireplace", name: "Fireplace", category: .fire, fileName: "fireplace.m4a", backgroundImage: "bg_fireplace", isPremium: true, isGenerated: false),
        Sound(id: "candle", name: "Candle Flicker", category: .fire, fileName: "candle.m4a", backgroundImage: "bg_candle", isPremium: true, isGenerated: false),

        // MARK: - Water (4 file-based)
        Sound(id: "ocean_waves", name: "Ocean Waves", category: .water, fileName: "ocean_waves.m4a", backgroundImage: "bg_ocean_waves", isPremium: true, isGenerated: false),
        Sound(id: "river", name: "River Stream", category: .water, fileName: "river.m4a", backgroundImage: "bg_river", isPremium: true, isGenerated: false),
        Sound(id: "waterfall", name: "Waterfall", category: .water, fileName: "waterfall.m4a", backgroundImage: "bg_waterfall", isPremium: true, isGenerated: false),
        Sound(id: "underwater", name: "Underwater", category: .water, fileName: "underwater.m4a", backgroundImage: "bg_underwater", isPremium: true, isGenerated: false),

        // MARK: - Premium (12 exclusive sounds)
        Sound(id: "singing_bowl", name: "Tibetan Singing Bowl", category: .premium, fileName: "singing_bowl.m4a", backgroundImage: "bg_singing_bowl", isPremium: true, isGenerated: false),
        Sound(id: "wind_chimes", name: "Wind Chimes", category: .premium, fileName: "wind_chimes.m4a", backgroundImage: "bg_wind_chimes", isPremium: true, isGenerated: false),
        Sound(id: "underwater_bubbles", name: "Underwater Bubbles", category: .premium, fileName: "underwater_bubbles.m4a", backgroundImage: "bg_underwater_bubbles", isPremium: true, isGenerated: false),
        Sound(id: "japanese_garden", name: "Japanese Garden", category: .premium, fileName: "japanese_garden.m4a", backgroundImage: "bg_japanese_garden", isPremium: true, isGenerated: false),
        Sound(id: "northern_lights", name: "Northern Lights Ambience", category: .premium, fileName: "northern_lights.m4a", backgroundImage: "bg_northern_lights", isPremium: true, isGenerated: false),
        Sound(id: "cabin_rain", name: "Cabin in the Rain", category: .premium, fileName: "cabin_rain.m4a", backgroundImage: "bg_cabin_rain", isPremium: true, isGenerated: false),
        Sound(id: "midnight_forest", name: "Midnight Forest", category: .premium, fileName: "midnight_forest.m4a", backgroundImage: "bg_midnight_forest", isPremium: true, isGenerated: false),
        Sound(id: "desert_wind", name: "Desert Wind", category: .premium, fileName: "desert_wind.m4a", backgroundImage: "bg_desert_wind", isPremium: true, isGenerated: false),
        Sound(id: "snow_falling", name: "Snow Falling", category: .premium, fileName: "snow_falling.m4a", backgroundImage: "bg_snow_falling", isPremium: true, isGenerated: false),
        Sound(id: "coffee_shop", name: "Coffee Shop", category: .premium, fileName: "coffee_shop.m4a", backgroundImage: "bg_coffee_shop", isPremium: true, isGenerated: false),
        Sound(id: "library", name: "Library Ambience", category: .premium, fileName: "library.m4a", backgroundImage: "bg_library", isPremium: true, isGenerated: false),
        Sound(id: "vinyl_crackle", name: "Vinyl Crackle", category: .premium, fileName: "vinyl_crackle.m4a", backgroundImage: "bg_vinyl_crackle", isPremium: true, isGenerated: false),
    ]

    static func sounds(for category: SoundCategory) -> [Sound] {
        allSounds.filter { $0.category == category }
    }

    static var groupedByCategory: [(category: SoundCategory, sounds: [Sound])] {
        SoundCategory.allCases.compactMap { category in
            let categorySounds = sounds(for: category)
            return categorySounds.isEmpty ? nil : (category, categorySounds)
        }
    }
}
