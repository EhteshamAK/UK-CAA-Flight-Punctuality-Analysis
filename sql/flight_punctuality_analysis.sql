SELECT * FROM flights.caa_2025_punctuality_clean;USE flight_project;

-- Q1. Preview the data
SELECT *
FROM flights
LIMIT 10;


-- Q2. Which airports handled the most matched flights?
SELECT
    airport,
    SUM(matched_flights) AS total_matched_flights
FROM flights
GROUP BY airport
ORDER BY total_matched_flights DESC;


-- Q3. Which airlines handled the most matched flights?
SELECT
    airline,
    SUM(matched_flights) AS total_matched_flights
FROM flights
GROUP BY airline
ORDER BY total_matched_flights DESC;


-- Q4. Which airports had the highest weighted average delay?
SELECT
    airport,
    ROUND(
        SUM(avg_delay_mins * matched_flights)
        / NULLIF(SUM(matched_flights), 0),
        2
    ) AS weighted_avg_delay_mins
FROM flights
WHERE avg_delay_mins IS NOT NULL
GROUP BY airport
ORDER BY weighted_avg_delay_mins DESC;


-- Q5. Which airlines had the highest weighted average delay?
SELECT
    airline,
    ROUND(
        SUM(avg_delay_mins * matched_flights)
        / NULLIF(SUM(matched_flights), 0),
        2
    ) AS weighted_avg_delay_mins
FROM flights
WHERE avg_delay_mins IS NOT NULL
GROUP BY airline
HAVING SUM(matched_flights) >= 100
ORDER BY weighted_avg_delay_mins DESC;


-- Q6. Which airports had the best weighted on-time performance?
SELECT
    airport,
    ROUND(
        SUM(on_time_percent * matched_flights)
        / NULLIF(SUM(matched_flights), 0),
        2
    ) AS weighted_on_time_percent
FROM flights
GROUP BY airport
ORDER BY weighted_on_time_percent DESC;


-- Q7. Which airports had the highest percentage of flights delayed over 15 minutes?
SELECT
    airport,
    ROUND(
        SUM(delayed_over_15_percent * matched_flights)
        / NULLIF(SUM(matched_flights), 0),
        2
    ) AS weighted_delay_over_15_percent
FROM flights
GROUP BY airport
ORDER BY weighted_delay_over_15_percent DESC;


-- Q8. Which airports had the highest severe delay percentage?
SELECT
    airport,
    ROUND(
        SUM(severe_delay_percent * matched_flights)
        / NULLIF(SUM(matched_flights), 0),
        2
    ) AS weighted_severe_delay_percent
FROM flights
GROUP BY airport
ORDER BY weighted_severe_delay_percent DESC;


-- Q9. Which routes had the highest flight volume?
SELECT
    airport,
    destination,
    SUM(matched_flights) AS total_matched_flights
FROM flights
GROUP BY airport, destination
ORDER BY total_matched_flights DESC;


-- Q10. Which routes had the worst weighted average delay?
SELECT
    airport,
    destination,
    SUM(matched_flights) AS total_matched_flights,
    ROUND(
        SUM(avg_delay_mins * matched_flights)
        / NULLIF(SUM(matched_flights), 0),
        2
    ) AS weighted_avg_delay_mins
FROM flights
WHERE avg_delay_mins IS NOT NULL
GROUP BY airport, destination
HAVING SUM(matched_flights) >= 100
ORDER BY weighted_avg_delay_mins DESC;


-- Q11. Which airlines had both high volume and high delay?
SELECT
    airline,
    SUM(matched_flights) AS total_matched_flights,
    ROUND(
        SUM(avg_delay_mins * matched_flights)
        / NULLIF(SUM(matched_flights), 0),
        2
    ) AS weighted_avg_delay_mins
FROM flights
WHERE avg_delay_mins IS NOT NULL
GROUP BY airline
HAVING SUM(matched_flights) >= 500
ORDER BY weighted_avg_delay_mins DESC;


-- Q12. Compare arrivals vs departures
SELECT
    direction,
    SUM(matched_flights) AS total_matched_flights,
    ROUND(
        SUM(avg_delay_mins * matched_flights)
        / NULLIF(SUM(matched_flights), 0),
        2
    ) AS weighted_avg_delay_mins,
    ROUND(
        SUM(on_time_percent * matched_flights)
        / NULLIF(SUM(matched_flights), 0),
        2
    ) AS weighted_on_time_percent
FROM flights
GROUP BY direction;


-- Q13. Scheduled vs charter performance
SELECT
    flight_type,
    SUM(matched_flights) AS total_matched_flights,
    ROUND(
        SUM(avg_delay_mins * matched_flights)
        / NULLIF(SUM(matched_flights), 0),
        2
    ) AS weighted_avg_delay_mins,
    ROUND(
        SUM(on_time_percent * matched_flights)
        / NULLIF(SUM(matched_flights), 0),
        2
    ) AS weighted_on_time_percent
FROM flights
GROUP BY flight_type;


-- Q14. Countries with the highest matched flight volume
SELECT
    country,
    SUM(matched_flights) AS total_matched_flights
FROM flights
GROUP BY country
ORDER BY total_matched_flights DESC;


-- Q15. Which airports contributed the most estimated delayed flights?
SELECT
    airport,
    ROUND(SUM(estimated_delayed_flights), 0) AS estimated_delayed_flights
FROM flights
GROUP BY airport
ORDER BY estimated_delayed_flights DESC;


-- Q16. Which routes contributed the most estimated delayed flights?
SELECT
    airport,
    destination,
    ROUND(SUM(estimated_delayed_flights), 0) AS estimated_delayed_flights
FROM flights
GROUP BY airport, destination
ORDER BY estimated_delayed_flights DESC;


-- Q17. Compare current vs previous year average delay by airport
SELECT
    airport,
    ROUND(
        SUM(avg_delay_mins * matched_flights)
        / NULLIF(SUM(matched_flights), 0),
        2
    ) AS current_weighted_avg_delay,
    ROUND(
        SUM(previous_year_avg_delay * previous_year_flights)
        / NULLIF(SUM(previous_year_flights), 0),
        2
    ) AS previous_weighted_avg_delay
FROM flights
WHERE avg_delay_mins IS NOT NULL
GROUP BY airport
ORDER BY current_weighted_avg_delay DESC;


-- Q18. Airport ranking by flight volume
SELECT
    airport,
    SUM(matched_flights) AS total_matched_flights,
    RANK() OVER (
        ORDER BY SUM(matched_flights) DESC
    ) AS flight_volume_rank
FROM flights
GROUP BY airport;


-- Q19. Airline ranking by weighted average delay
WITH airline_performance AS (
    SELECT
        airline,
        SUM(matched_flights) AS total_matched_flights,
        SUM(avg_delay_mins * matched_flights)
        / NULLIF(SUM(matched_flights), 0) AS weighted_avg_delay_mins
    FROM flights
    WHERE avg_delay_mins IS NOT NULL
    GROUP BY airline
)
SELECT
    airline,
    total_matched_flights,
    ROUND(weighted_avg_delay_mins, 2) AS weighted_avg_delay_mins,
    RANK() OVER (
        ORDER BY weighted_avg_delay_mins DESC
    ) AS delay_rank
FROM airline_performance
WHERE total_matched_flights >= 100;


-- Q20. High-volume, high-delay routes
WITH route_performance AS (
    SELECT
        airport,
        destination,
        SUM(matched_flights) AS total_matched_flights,
        SUM(avg_delay_mins * matched_flights)
        / NULLIF(SUM(matched_flights), 0) AS weighted_avg_delay_mins
    FROM flights
    WHERE avg_delay_mins IS NOT NULL
    GROUP BY airport, destination
)
SELECT
    airport,
    destination,
    total_matched_flights,
    ROUND(weighted_avg_delay_mins, 2) AS weighted_avg_delay_mins
FROM route_performance
WHERE total_matched_flights >= 500
ORDER BY weighted_avg_delay_mins DESC;