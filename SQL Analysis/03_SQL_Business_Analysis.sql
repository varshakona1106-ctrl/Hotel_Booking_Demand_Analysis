CREATE TABLE hotel_bookings (
    hotel VARCHAR(50),
    is_canceled INT,
    lead_time INT,
    arrival_date_year INT,
    arrival_date_month VARCHAR(20),
    arrival_date_week_number INT,
    arrival_date_day_of_month INT,
    stays_in_weekend_nights INT,
    stays_in_week_nights INT,
    adults INT,
    children INT,
    babies INT,
    meal VARCHAR(50),
    country VARCHAR(10),
    market_segment VARCHAR(50),
    distribution_channel VARCHAR(50),
    is_repeated_guest INT,
    previous_cancellations INT,
    previous_bookings_not_canceled INT,
    reserved_room_type VARCHAR(10),
    assigned_room_type VARCHAR(10),
    booking_changes INT,
    deposit_type VARCHAR(50),
    days_in_waiting_list INT,
    customer_type VARCHAR(50),
    adr NUMERIC(10,2),
    required_car_parking_spaces INT,
    total_of_special_requests INT,
    reservation_status VARCHAR(50),
    reservation_status_date DATE,
    has_company INT,
    has_agent INT
);


SELECT COUNT(*) AS total_rows
FROM hotel_bookings;

SELECT * FROM hotel_bookings
LIMIT 5;


/* Hotel Demand Analysis */

--1. Which hotel type generates a higher average ADR?
/* Which hotel earns more money per booking?
Resort Hotel? OR City Hotel? */

SELECT hotel, 
 ROUND(AVG(adr)::numeric,2) AS avg_adr 
FROM hotel_bookings
GROUP BY hotel
ORDER BY avg_adr DESC;

/* Finding: I calculated the average ADR for each hotel type.
Observation: City Hotel had a higher average ADR (111.18) than Resort Hotel (99.07).
Conclusion: City Hotels earn more revenue per booking on average. */


--2. Which customer type has the highest cancellation rate?
/* As this dataset does not contain any revenue column.
I estimated revenue like this: (Revenue = ADR * Number of Bookings), as ADR is the room rate per booking. */

SELECT arrival_date_month, 
       ROUND(SUM(adr)::numeric,2) AS estimated_revenue
FROM hotel_bookings
GROUP BY arrival_date_month
ORDER BY estimated_revenue DESC;

/* Finding: I calculated the estimated revenue generated in each month by summing the ADR values of all bookings.
Observation: The highest estimated revenue was generated during the peak travel months.
This indicates that booking demand and hotel earnings increase significantly during these months.
Conclusion: Peak months contribute the most to hotel revenue.
Management can focus marketing and pricing strategies during these periods to maximize earnings. */


--3. Average ADR by customer type?
--Which type of customer spends more on hotel rooms?

SELECT customer_type,
  ROUND(AVG(adr)::numeric, 2) AS avg_adr
FROM hotel_bookings
GROUP BY customer_type
ORDER BY avg_adr DESC;

/* Finding: I calculated the average ADR for each customer type.
Observation: Transient customers had the highest average ADR (110.24), while Group customers had the lowest (84.82).
Conclusion: Transient customers generate more revenue per booking compared to other customer types. */


--4. Which room types generate the highest ADR?

SELECT assigned_room_type , 
     ROUND(AVG(adr)::numeric, 2) AS avg_adr
FROM hotel_bookings
GROUP BY assigned_room_type
ORDER BY avg_adr DESC;

/* Finding: I calculated the average ADR for each assigned room type.
Observation: Room Type H generated the highest average ADR (172.13), while Room Type L generated the lowest (8.00).
Conclusion: Higher-category rooms contribute more revenue per booking and play an important role in hotel profitability. */


--5. Which customer type has the highest cancellation rate?

SELECT customer_type,
    ROUND(SUM(is_canceled) * 100.0 / COUNT(*)::numeric, 2) AS cancellation_rate
FROM hotel_bookings
GROUP BY customer_type
ORDER BY cancellation_rate DESC;

/* Finding: I calculated the cancellation rate for each customer type.
Observation: Transient customers had the highest cancellation rate (30.14%), while Group customers had the lowest cancellation rate (9.80%).
Conclusion: Transient bookings are more prone to cancellation, whereas Group bookings are comparatively more reliable. */


--6. Which market segments have the highest cancellation rates?

SELECT market_segment, 
  ROUND(SUM(is_canceled) * 100.0 / COUNT(*)::numeric, 2) AS cancellation_rate
FROM hotel_bookings
GROUP BY market_segment
ORDER BY cancellation_rate DESC;

/* Finding: I calculated the cancellation rate for each market segment.
Observation: Online TA had the highest cancellation rate (35.39%) among the major segments, while Corporate bookings had one of the lowest cancellation rates (12.13%).
Conclusion: Customers booking through Online Travel Agencies are more likely to cancel compared to customers from Corporate or Direct channels. */


--7. Which distribution channels have the highest cancellation rates?

SELECT distribution_channel,
   ROUND(SUM(is_canceled) * 100.0 / COUNT(*):: numeric, 2) AS cancellation_rate
FROM hotel_bookings
GROUP BY distribution_channel
ORDER BY cancellation_rate DESC;

/*Finding: I calculated the cancellation rate for each distribution channel.
Observation: TA/TO recorded the highest cancellation rate (31.00%), while Corporate bookings had the lowest cancellation rate (12.77%).
Conclusion: Bookings coming through Travel Agents and Tour Operators are more prone to cancellations compared to Corporate bookings. */


--8. Which deposit type has the highest cancellation rate?

SELECT deposit_type, 
  ROUND(SUM(is_canceled) * 100.0 / COUNT(*):: numeric, 2) AS cancellation_rate
FROM hotel_bookings
GROUP BY deposit_type
ORDER BY cancellation_Rate DESC;

/* Finding: I calculated the cancellation rate for each deposit type.
Observation: Non-refund bookings had the highest cancellation rate (94.70%), while Refundable bookings had the lowest cancellation rate (24.30%).
Conclusion: Deposit type appears to have a strong relationship with booking cancellations. */


--9. How does lead time affect cancellations?

SELECT
    CASE
        WHEN lead_time <= 30 THEN '0-30 Days'
        WHEN lead_time <= 90 THEN '31-90 Days'
        WHEN lead_time <= 180 THEN '91-180 Days'
        ELSE '180+ Days'
    END AS lead_time_group,

    ROUND((SUM(is_canceled) * 100.0 / COUNT(*))::numeric, 2) AS cancellation_rate
FROM hotel_bookings

GROUP BY CASE
           WHEN lead_time <= 30 THEN '0-30 Days'
           WHEN lead_time <= 90 THEN '31-90 Days'
           WHEN lead_time <= 180 THEN '91-180 Days'
           ELSE '180+ Days'
         END
ORDER BY cancellation_rate DESC;

/* Finding: I analyzed cancellation rates across different lead time groups.
Observation: The cancellation rate increased steadily as the lead time increased. Bookings made more than 180 days before arrival had the highest cancellation rate (39.74%).
Conclusion: Long-term bookings are more prone to cancellation, while last-minute bookings tend to be more reliable. */

--10. Do customers with more special requests cancel less?

SELECT total_of_special_requests,
   ROUND(SUM(is_canceled) * 100.0 / COUNT(*):: numeric, 2) AS cancelled
FROM hotel_bookings
GROUP BY total_of_special_requests
ORDER BY total_of_special_requests;

/* Finding: I analyzed the relationship between special requests and cancellation rates.
Observation: Cancellation rates consistently decreased as the number of special requests increased. Customers with no special requests had a cancellation rate of 33.25%, whereas customers with five requests had a cancellation rate of only 5.56%.
Conclusion: Customers who make more special requests tend to be more committed to their bookings and are therefore less likely to cancel. */

--11. Which hotel type receives more repeat guests?

SELECT hotel,
    COUNT(*) AS repeat_guests
FROM hotel_bookings
WHERE is_repeated_guest = 1
GROUP BY hotel
ORDER BY repeat_guests DESC;

/* Finding: I analyzed repeat guest bookings across hotel types.
Observation: Resort Hotels recorded 1,706 repeat guests, while City Hotels recorded 1,657 repeat guests.
Conclusion: Resort Hotels attract slightly more repeat customers, indicating marginally stronger customer loyalty compared to City Hotels. */

--12. Average Stay Duration by Hotel Type?

SELECT hotel, 
  ROUND(AVG(stays_in_weekend_nights + stays_in_week_nights)) AS avg_stay
FROM hotel_bookings
GROUP BY hotel
ORDER BY avg_stay DESC;
/* Finding: I calculated the average stay duration for each hotel type.
Observation: Guests stayed an average of 4 days in Resort Hotels and 3 days in City Hotels.
Conclusion: Customers tend to spend more time at Resort Hotels compared to City Hotels. */

--13. Hotel booking trend by year?

SELECT arrival_date_year, COUNT(*) AS tot_bookings
FROM hotel_bookings
GROUP BY arrival_date_year
ORDER BY arrival_date_year DESC;

/* Finding: I analyzed the booking trend across different years.
Observation: Bookings increased sharply in 2016 and then decreased slightly in 2017.
Conclusion: The hotel experienced significant growth in demand during the period covered by the dataset. */

--14. Cancellation Trend by Year?

SELECT arrival_date_year,
  ROUND((SUM(is_canceled) * 100.0 / COUNT(*)):: numeric, 2) AS cancellation
FROM hotel_bookings
GROUP BY arrival_date_year
ORDER BY arrival_date_year;

/* Finding: I analyzed cancellation trends across different years.
Observation: The cancellation rate increased every year, reaching its highest value of 31.95% in 2017.
Conclusion: The risk of booking cancellations increased over time, highlighting the importance of monitoring cancellation behavior. */