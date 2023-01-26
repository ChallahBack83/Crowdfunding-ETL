-- Challenge Bonus queries.
-- 1. (2.5 pts)
-- Retrieve all the number of backer_counts in descending order for each `cf_id` for the "live" campaigns. 

SELECT cf_id,
	backers_count
FROM campaign
WHERE outcome = ('live')
ORDER BY backers_count DESC;

-- 2. (2.5 pts)
-- Using the "backers" table confirm the results in the first query.

SELECT b.cf_id,
	COUNT(b.backer_id) AS "backers_count"
FROM backers AS b
INNER JOIN campaign AS c
ON b.cf_id = c.cf_id
WHERE c.outcome = 'live'
GROUP BY b.cf_id
ORDER BY "backers_count" DESC;


-- 3. (5 pts)
-- Create a table that has the first and last name, and email address of each contact.
-- and the amount left to reach the goal for all "live" projects in descending order. 

SELECT b.first_name,
	b.last_name,
	b.email,
	c.goal - c.pledged AS "Remaining Goal Amount"
INTO email_contacts_remaining_goal_amount
FROM contacts AS b
LEFT JOIN campaign AS c
ON b.contact_id = c.contact_id
WHERE c.outcome = 'live'
ORDER BY "Remaining Goal Amount" DESC;


-- Check the table
SELECT *
FROM email_contacts_remaining_goal_amount
LIMIT 10;

-- 4. (5 pts)
-- Create a table, "email_backers_remaining_goal_amount" that contains the email address of each backer in descending order, 
-- and has the first and last name of each backer, the cf_id, company name, description, 
-- end date of the campaign, and the remaining amount of the campaign goal as "Left of Goal". 

SELECT b.email,
	b.first_name,
	b.last_name,
	b.cf_id,
	c.compan_name,
	c.description,
	c.end_date,
	c.goal - c.pledged AS "Left of Goal"
INTO email_backers_remaining_goal_amount
FROM backers AS b
INNER JOIN  campaign AS c
ON b.cf_id = c.cf_id
ORDER BY last_name;


-- Check the table

SELECT *
FROM email_backers_remaining_goal_amount
LIMIT 10;

