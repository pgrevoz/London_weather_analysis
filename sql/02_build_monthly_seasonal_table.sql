CREATE OR REPLACE TABLE london_weather_monthly_seasonal AS
WITH base AS (
  SELECT
    -- Month date (DuckDB)
    MAKE_DATE(CAST(yyyy AS BIGINT), CAST(mm AS BIGINT), 1) AS date,
    CAST(yyyy AS BIGINT) AS year,
    CAST(mm AS BIGINT)   AS month,
    STRFTIME(MAKE_DATE(2000, CAST(mm AS BIGINT), 1), '%B') AS month_name,

    -- Raw measures
    tmax,
    tmin,
    rain,
    sun,

    -- Monthly mean and deltatemp derived from tmax/tmin
    (tmax + tmin) / 2 AS tmean,
    tmax - tmin AS tdelta,

    -- Season label
    CASE
      WHEN mm IN (12, 1, 2) THEN 'Winter'
      WHEN mm IN (3, 4, 5)  THEN 'Spring'
      WHEN mm IN (6, 7, 8)  THEN 'Summer'
      ELSE 'Autumn'
    END AS season,

    -- Season year (critical: Dec belongs to next year's winter)
    CASE
      WHEN mm = 12 THEN CAST(yyyy AS BIGINT) + 1
      ELSE CAST(yyyy AS BIGINT)
    END AS season_year
  FROM london_weather_raw
  WHERE yyyy IS NOT NULL
    AND mm IS NOT NULL
),

with_season_aggregates AS (
  SELECT
    *,
    -- Season aggregates repeated on each month row
    AVG(tmean) OVER (PARTITION BY season_year, season) AS season_mean_temp,
    AVG(tdelta) OVER (PARTITION BY season_year, season) AS season_mean_tdelta,
    SUM(rain)  OVER (PARTITION BY season_year, season) AS season_total_rain,
    SUM(sun)   OVER (PARTITION BY season_year, season) AS season_total_sun
  FROM base
)
SELECT *
FROM with_season_aggregates
ORDER BY date;
