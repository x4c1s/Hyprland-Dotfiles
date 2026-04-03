#!/usr/bin/env python3

import requests
import os
import json
from dotenv import load_dotenv

def getWeatherIcon(isDayTime: bool, weatherDescription: str):
    if weatherDescription in ["CLEAR"]:
        if isDayTime:
            return "☀️"
        else:
            return "🌙 "
    if weatherDescription in ["PARTLY_CLOUDY", "MOSTLY_CLEAR"]: 
        if isDayTime:
            return  "⛅"
        else:
            return " "
    if weatherDescription in ["CLOUDY", "MOSTLY_CLOUDY"]: 
            return "☁️"
    if weatherDescription in ["LIGHT_RAIN", "LIGHT_TO_MODERATE_RAIN","LIGHT_RAIN_SHOWERS"]:
        if isDayTime:
            return "🌦️"
        else:
            return " "
    if weatherDescription in ["RAIN", "RAIN_SHOWERS", "HEAVY_RAIN", "HEAVY_RAIN_SHOWERS", "MODERATE_TO_HEAVY_RAIN", "RAIN_PERIODICALLY_HEAVY"]:
        return "🌧️"
    if weatherDescription in ["SNOW", "LIGHT_SNOW", "HEAVY_SNOW", "SNOW_SHOWERS", "LIGHT_SNOW_SHOWERS", "HEAVY_SNOW_SHOWERS", "SNOWSTORM", "BLOWING_SNOW", "RAIN_AND_SNOW", "HAIL"]:
        return "❄️"
    if weatherDescription in ["LIGHT_THUNDERSTORM_RAIN"]:
        if isDayTime: 
            return "⛈️"
        else:
            return "⛈️"

    if weatherDescription in ["THUNDERSHOWER", "SCATTERED_THUNDERSTORMS", "THUNDERSTORM", "HEAVY_THUNDERSTORM"]:
        return "🌩️"
    
    if weatherDescription in ["WINDY"]:
        if isDayTime:
            return "🍃"
        else:
            return "🍃"
    
    if weatherDescription in ["FOG","HAZE","DUST","MIST","SMOKE"]:
        if isDay:
            return " "
        else:
            return " "
            
    return "󰖐 "


url = "https://weather.googleapis.com/v1/currentConditions:lookup"
lat = "<LATITUDE>"
long = "<LONGITUDE>"

load_dotenv()
params = {
        "key":os.getenv("API_KEY"),
        "location.latitude":lat,
        "location.longitude": long
        }


response = requests.get(url, params=params)
jsonDump = json.loads(response.text)
currentTemperature = jsonDump["temperature"]["degrees"]
weatherDescription = jsonDump["weatherCondition"]["type"]
isDaytime = jsonDump["isDaytime"]
precipitation = jsonDump["precipitation"]["probability"]["percent"]
windSpeed = jsonDump["wind"]["speed"]["value"]

weatherIcon = getWeatherIcon(isDaytime, weatherDescription)
print(weatherIcon, f"{currentTemperature}°C",f"☔ {precipitation}%", f"🌬️ {windSpeed}kph")

