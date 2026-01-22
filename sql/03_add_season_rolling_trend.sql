-- First create a season-year table (one row per season-year)
CREATE OR REPLACE TABLE seasonal_by_year AS
SELECT DISTINCT
  season_year,
  season,
  season_mean_temp,
  season_mean_tdelta,
  season_total_rain,
  season_total_sun
FROM london_weather_monthly_seasonal
ORDER BY season, season_year;

-- Add a 10y rolling average per season (Winter/Spring/Summer/Autumn)
CREATE OR REPLACE TABLE seasonal_by_year_trends AS
SELECT
  season_year,
  season,
  season_mean_temp,
  AVG(season_mean_temp) OVER (
    PARTITION BY season
    ORDER BY season_year
    ROWS BETWEEN 9 PRECEDING AND CURRENT ROW
  ) AS season_rolling_10y_temp,
  season_mean_tdelta,
  AVG(season_mean_tdelta) OVER (
    PARTITION BY season
    ORDER BY season_year
    ROWS BETWEEN 9 PRECEDING AND CURRENT ROW
  ) AS season_rolling_10y_tdelta,
  season_total_rain,
  AVG(season_total_rain) OVER (
    PARTITION BY season
    ORDER BY season_year
    ROWS BETWEEN 9 PRECEDING AND CURRENT ROW
  ) AS season_rolling_10y_rain,
  season_total_sun,
  AVG(season_total_sun) OVER (
    PARTITION BY season
    ORDER BY season_year
    ROWS BETWEEN 9 PRECEDING AND CURRENT ROW
  ) AS season_rolling_10y_sun,
FROM seasonal_by_year;

-- Join it back so each month carries the rolling trend too
CREATE OR REPLACE TABLE london_weather_monthly_seasonal AS
SELECT
  m.*,
  t.season_rolling_10y_temp,
  t.season_rolling_10y_tdelta,
  t.season_rolling_10y_rain,
  t.season_rolling_10y_sun
FROM london_weather_monthly_seasonal m
LEFT JOIN seasonal_by_year_trends t
  ON m.season_year = t.season_year
 AND m.season = t.season
ORDER BY m.date;