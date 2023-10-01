-- Q1, Who is senior most employee on job title?
select * from employee
order by levels desc 
limit 1;


-- Q2. Which country have the most invoices?
 select billing_country, count(*) from invoice 
 group by billing_country 
 order by count(*) desc
 limit 1;
 
 
-- Q3. What are top 3 values of total invoice?  
select round(total,2) from invoice
order by total desc limit 3;


-- Q4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a Query that returns
-- one city that has the highest sum of invoice totals. Return both the city name and sum of all invoice totals.
 select billing_city, sum(total) as Total_Invoice from invoice 
 group by billing_city 
 order by Total_invoice desc limit 1;
 
 
-- Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person
-- who has spent the most money?
 select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
 from customer
 join invoice on customer.customer_id = invoice.customer_id
 group by customer.customer_id, customer.first_name, customer.last_name
 order by total desc limit 1;
 
 
-- Q6. Write Query to return the email, first name, last name & genre of all rock music listerners. Return your list ordered alphabetically
-- by email starting with A
select  distinct customer.email, customer.first_name,customer.last_name, genre_id FROM musicdb.track
join invoice_line on track.track_id = invoice_line.track_id
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on invoice.customer_id = customer.customer_id
where genre_id = (select genre_id from genre where name like 'Rock')
order by customer.email;
-- OR
select customer.customer_id from invoice_line
join invoice on invoice_line.invoice_id = invoice.invoice_id
join customer on invoice.customer_id = customer.customer_id
where track_id in (select track_id from track where genre_id = (select genre_id from genre where name like 'Rock'))
group by customer.customer_id ;

-- Q7. Lets invite the artists who have written the most rock music in our dataset. Write a query 
-- that returns the Artist name and total track count of the top 10 rock bands.

select artist.name, count(*) as Rock_music_count from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
where genre_id = (select genre_id from genre where name like 'Rock') and
track_id in (select track_id from playlist_track where playlist_id in (select playlist_id from playlist where name = 'Music'))
group by artist.name
order by count(*) desc limit 10;
-- OR
select artist.name, count(*) from track
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
where genre_id = (select genre_id from genre where name like 'Rock')
group by artist.name
order by count(*) desc limit 10;

-- Q8. Return all the track names that have a song length longer that the average song length. Return the name and milliseconds for each track. 
-- Order the song length with the longest songs listed first. 

select name, milliseconds from track
where milliseconds >= (select avg(milliseconds) from track) 
order by milliseconds desc;

-- Q9. Find how much amount spent by each customer on top artist? Write a query to return customer name, artist name and total spent
-- customer.first_name, customer.last_name, artist.name
with cte as (select artist.artist_id, sum(total) from invoice_line
join invoice on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by artist.artist_id
order by sum(total) desc limit 1
)
select customer.customer_id, sum(total) as ttl from invoice_line
join invoice on invoice_line.invoice_id = invoice.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
where album_id in (select album_id from album where artist_id = (select artist_id from cte))
group by customer.customer_id
order by sum(total) desc


-- select sum(ttl) from cte2
-- OR
with cte as (
select artist.artist_id, sum(invoice.total) from invoice
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on album.album_id = track.album_id
join artist on album.artist_id = artist.artist_id
group by artist_id
order by sum(invoice.total) desc limit 1
)
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as totalInvoice from invoice_line
join invoice on invoice_line.invoice_id = invoice.invoice_id
join customer on invoice.customer_id = customer.customer_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
where artist_id = (select artist_id from cte)
group by customer.customer_id, customer.first_name, customer.last_name
order by sum(invoice.total) desc;


-- Q10. we want to find out the most popular genre for each country. We determine the most popular genere as the genre with high number of purchases. 
-- Write a Query tht returns each country along with the top genre.

with cte as (
SELECT count(invoice.invoice_id) as purchaseCount, billing_country , genre.name as Genre, row_number() over (partition by billing_country order by count(invoice.invoice_id) desc) as Rowrank
 FROM invoice
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on track.genre_id = genre.genre_id
group by billing_country, genre.name
order by billing_country, purchaseCount desc
)
select * from cte where Rowrank = 1;


-- Q11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top
-- customers and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

with cte as (
select customer.country, customer.customer_id, round(sum(invoice.total),2) as moneySpent, 
row_number() over (partition by customer.country order by sum(invoice.total) desc) as RowNo
from invoice
join customer on invoice.customer_id = customer.customer_id
group by 1,2
order by 1,3 desc
 )
 select country, customer_id, moneySpent from cte where RowNo = 1
 
 


