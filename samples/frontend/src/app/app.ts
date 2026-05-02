import { Component, OnInit, inject, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { DatePipe } from '@angular/common';
import { WeatherService } from './services/weather.service';
import { WeatherForecast } from '../models/weather-forecast';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, DatePipe],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App implements OnInit {
  private weatherService = inject(WeatherService);
  protected readonly title = signal('Awesome Weather Forecast');
  protected readonly forecasts = signal<WeatherForecast[]>([]);

  ngOnInit() {
    this.weatherService.getWeatherForecasts().subscribe({
      next: (data) => this.forecasts.set(data),
      error: (err) => console.error('Error fetching weather:', err)
    });
  }
}
