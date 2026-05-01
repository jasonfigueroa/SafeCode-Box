import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { WeatherForecast } from '../../models/weather-forecast';

@Injectable({
  providedIn: 'root'
})
export class WeatherService {
  private http = inject(HttpClient);
  private apiUrl = 'http://localhost:5000/weatherforecast';

  getWeatherForecasts(): Observable<WeatherForecast[]> {
    return this.http.get<WeatherForecast[]>(this.apiUrl);
  }
}
