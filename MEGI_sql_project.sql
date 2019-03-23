/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT  name 
FROM  Facilities 
WHERE membercost >0
ORDER BY name ASC 

/* Q2: How many facilities do not charge a fee to members? */
SELECT  COUNT(name) AS number_facilities_booking_free
FROM  Facilities 
WHERE membercost =0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT  facid,
        name,
		membercost,
		monthlymaintenance
FROM  Facilities 
WHERE membercost < (0.2*monthlymaintenance)
ORDER BY  1 ASC 

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * 
FROM  Facilities 
WHERE facid=1 OR facid=5

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT  name,
        CASE WHEN  monthlymaintenance >100 THEN 'expensive'
		     ELSE  'cheap' END AS monthly_maintenance
FROM  Facilities 
ORDER BY  name ASC 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT t1.memid, t1.surname, t1.firstname, t1.joindate
FROM Members t1
WHERE t1.joindate LIKE (SELECT MAX(t2.joindate) FROM Members AS t2) 


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT t3.name, 
       (CONCAT(t2.surname, ', ',t2.firstname)) as member
FROM  Bookings AS t1 
	INNER JOIN Members AS t2 
	ON (t1.memid=t2.memid)
		INNER JOIN Facilities AS t3
		ON (t1.facid=t3.facid)
    WHERE t3.name LIKE 'Tennis%'
GROUP BY 2,1
ORDER BY 2 ASC


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT t1.bookid, t2.name, CONCAT(t3.surname,', ', t3.firstname) AS user, 
       CASE WHEN t1.memid=0 THEN t2.guestcost*t1.slots
	        ELSE t2.membercost*t1.slots END AS booking_cost
			
FROM Bookings AS t1
INNER JOIN Facilities AS t2 ON t1.facid = t2.facid
INNER JOIN Members AS  t3 ON t1.memid=t3.memid
WHERE t1.starttime LIKE '2012-09-14%'
HAVING booking_cost>30
ORDER BY booking_cost DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT t1.bookid, t2.name, CONCAT(t3.surname,', ', t3.firstname) AS user, 
       CASE WHEN t1.memid=0 THEN t2.guestcost*t1.slots
	        ELSE t2.membercost*t1.slots END AS booking_cost

FROM Facilities AS t2, 
     Members AS t3,
     (
       SELECT bookid, memid, facid, slots, starttime
       FROM Bookings 
       WHERE starttime LIKE '2012-09-14%'
      ) AS t1

WHERE (t1.memid=t3.memid) AND (t1.facid=t2.facid)
HAVING booking_cost>30
ORDER BY booking_cost DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT t2.name, 
       SUM(CASE WHEN t1.memid=0 THEN t2.guestcost*t1.slots
	        ELSE t2.membercost*t1.slots END) AS revenue

FROM Bookings AS t1
INNER JOIN Facilities AS t2 ON t1.facid = t2.facid
GROUP BY t2.name
HAVING revenue>1000
ORDER BY revenue DESC