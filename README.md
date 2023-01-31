# Crowdfunding-ETL

The purpose of this project is to incorporate the new dataset about backers of live projects into the existing queries on the crowdfunding campaigns. Doing so allows us to extract and combine the new information to gather more insights about the campaigns and to efficiently contact backers of live campaigns.

## Project Overview

I was given a csv file with the backers information for the crowdfunding campaigns.  Unfortunately, the information for each backer was contained together in individual lists making it unreadable for analysis purposes. To clean the data, I converted each row into a dictionary before iterating through the rows using list comprehension to get the list of values for each row.
```
# Iterate through the backers DataFrame and convert each row to a dictionary.
backers_dict = []    

for i, row in backers_df.iterrows():
    data = row["backer_info"]
    dict_data = json.loads(data)
    
# Iterate through each dictionary (row) and get the values for each row using list comprehension.
    dict_values = [v for k, v in dict_data.items()]
    
    # Append the list of values for each row to a list. 
    backers_dict.append(dict_values)

# Print out the list of values for each row.
print(backers_dict)
```
Doing this conversion gave me data points that could then be transformed into the columns of a dataframe with the original keys as the column names. However, the data still needed further cleaning. I separated the name column into first and last names using str.split(), dropped the original name columns, and reordered the dataframe into a more useable format before exporting it into a csv. I exported it without the index since it would next be entered into a database.
```
# Split the "name" column into "first_name" and "last_name" columns.
backers_df[["first_name", "last_name"]] = backers_df["name"].str.split(" ", n=1, expand=True)

#  Drop the name column
backers_df = backers_df.drop(["name"], axis=1)

# Reorder the columns
backers_df_clean = backers_df[["backer_id", "cf_id", "first_name", "last_name", "email"]]

# Export the DataFrame as a CSV file using encoding='utf8'.
backers_df_clean.to_csv("backers.csv", encoding="utf8", index=False)
```
From there, I could import the dataframe into our PostgreSQL database.  Before doing so, I pulled up my previous ERD and mapped what the database should look like, identifying the primary key, foreign key, and mapping its connection to the existing tables.  

![ERD diagram](https://github.com/ChallahBack83/Crowdfunding-ETL/blob/main/crowdfunding_db_relationships.png)

Then I used CREATE TABLE and ALTER TABLE before importing the csv to bring the backers dataframe into the database. At this point, I could finally begin queries to analyze the crowdfunding data. Per the instructions, I created a query to pull the number of backer_counts for each live campaign in descending order using the campaign table. I then verified the data from this query by running a query on the backers table to do the same thing.  To do so, I had to use a JOIN on the two tables as you can see here:
```
SELECT b.cf_id,
	COUNT(b.backer_id) AS "backers_count"
FROM backers AS b
INNER JOIN campaign AS c
ON b.cf_id = c.cf_id
WHERE c.outcome = 'live'
GROUP BY b.cf_id
ORDER BY "backers_count" DESC;
```
This query ran successfully and confirmed the original results. You can see the results from both queries below:

![backer_counts1](https://github.com/ChallahBack83/Crowdfunding-ETL/blob/main/backer_count.png)
![backer_counts2](https://github.com/ChallahBack83/Crowdfunding-ETL/blob/main/backer_count_confirm.png)

Lastly, I created two new tables to export as contact lists for live campaigns.  The first is a table with the contact information for each live campaign which includes the remaining goal amount.  The query:
```
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
```
I exported the [email_contacts_remaining_goal_amount](https://github.com/ChallahBack83/Crowdfunding-ETL/blob/main/email_contacts_remaining_goal_amount.csv) file for use in quickly reaching the live campaign contacts.

The final query pulled similar information but for the backers of the same live campaigns. The query:
```
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
```
The final table was saved as [email_backers_remaining_goal_amount](https://github.com/ChallahBack83/Crowdfunding-ETL/blob/main/email_backers_remaining_goal_amount.csv).

## Summary 

In conclusion, this project helped me learn more about the pipeline of data analysis by completing steps of multiple processes. By carefully extracting and cleaning the data, I was able to make it useable for broader searches and answer valuable questions for my stakeholders.
