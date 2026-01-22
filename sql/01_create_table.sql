--DROP TABLE IF EXISTS london_weather_raw;
CREATE OR REPLACE TABLE london_weather_raw AS
SELECT *
FROM read_csv_auto(
    'data/processed/heathrow_monthly_weather.csv',
    header=true
);
