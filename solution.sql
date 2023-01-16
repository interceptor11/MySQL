use ipl;
-- 1.Show the percentage of wins of each bidder in the order of highest to lowest percentage.

select ibd.BIDDER_ID,count(ibd.BID_STATUS)/ibp.NO_OF_BIDS*100 as percentage
from ipl_bidding_details ibd
join ipl_bidder_points ibp using (BIDDER_ID)
where ibd.BID_STATUS='won'
group by ibd.BIDDER_ID
order by percentage desc;

-- 2.Display the number of matches conducted at each stadium with the stadium name and city.

SELECT imc.STADIUM_ID,
		ist.STADIUM_NAME,ist.CITY,count(imc.MATCH_ID) as total_matches_conducted
FROM ipl_match_schedule imc
join ipl_stadium ist using(STADIUM_ID)
group by imc.STADIUM_ID
order by total_matches_conducted desc;

-- 3.In a given stadium, what is the percentage of wins by a team which has won the toss?

select a.stadium_id,(((sum(case when b.toss_winner=b.match_winner then 1 else 0 end ))/(count(a.match_id)))*100) as win_percentage 
from IPL_Match_Schedule as a 
join IPL_Match as b on a.match_id=b.match_id 
where a.status="completed"
group by a.stadium_id
order by win_percentage desc;


-- 4.	Show the total bids along with the bid team and team name.


SELECT BID_TEAM,IPL_TEAM.TEAM_NAME,COUNT(BID_TEAM) as total_bids
FROM IPL_BIDDING_DETAILS 
JOIN IPL_TEAM 
ON IPL_BIDDING_DETAILS.BID_TEAM = IPL_TEAM.TEAM_ID
GROUP BY BID_TEAM
order by total_bids desc;

-- 5.	Show the team id who won the match as per the win details.

select (CASE when match_winner=1 then team_id1 else team_id2 end )as winning_team_id ,win_details

from ipl_match;

-- 6.	Display total matches played, total matches won and total matches lost by the team along with its team name.


select a.team_id, b.team_name, sum(a.matches_played) as matches_played, sum(a.matches_won) as matches_won, 
sum(a.matches_lost) as matches_lost
from ipl_team_standings as a 
join ipl_team as b on  a.team_id=b.team_id
group by team_id;

-- 7.	Display the bowlers for the Mumbai Indians team.


select itp.TEAM_ID,ip.PLAYER_NAME,itp.PLAYER_ROLE,it.team_name
from ipl_team_players itp 
join ipl_team it using (team_id)
join ipl_player ip using(player_id)
where it.team_name='Mumbai Indians' and itp.PLAYER_ROLE='Bowler';

-- 8.	How many all-rounders are there in each team, Display the teams with more than 4 all-rounders in descending order.

select *
from (
select itp.TEAM_ID,count(itp.PLAYER_ROLE) as all_rounder_count ,it.team_name
from ipl_team_players itp 
join ipl_team it using (team_id)
 
where itp.PLAYER_ROLE='All-Rounder'
group by itp.TEAM_ID ) as a

where all_rounder_count>4
order by all_rounder_count desc;


-- 9.Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when 
--   it won the match in M. Chinnaswamy Stadium bidding year-wise.
--   Note the total bidders’ points in descending order and the year is bidding year.
--   Display columns: bidding status, bid date as year, total bidder’s points

select a.bid_status as 'bidding status',ibp.tournmt_id as 'Bid date as year',ibp.total_points as 'total bidder’s points'
from ipl_bidder_points  ibp
join (
select bidder_id , bid_status
from ipl_bidding_details
where bid_team = (select team_id from ipl_team where remarks='csk'
) and bid_status='won'
) a 
using (bidder_id)

where tournmt_id in 
(
select tournmt_id
from ipl_match_schedule
where stadium_id = (select stadium_id from ipl_stadium where stadium_name='M. Chinnaswamy Stadium')
);

-- 10.	Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
-- Note 
-- 1. use the performance_dtls column from ipl_player to get the total number of wickets
-- 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
-- 3. Do not use joins in any cases.
-- 4. Display the following columns teamn_name, player_name, and player_role.


select ipl_p.PLAYER_ID,ipl_p.PLAYER_NAME,
(select ipl_t_p.PLAYER_ROLE

from ipl_team_players as ipl_t_p 
where ipl_t_p.player_id = ipl_p.player_id and ipl_t_p.player_role IN ('Bowler','All-rounder')) as "Player role",
convert(replace(SUBSTRING(ipl_p.performance_dtls, INSTR(ipl_p.performance_dtls,'Wkt-'), 
INSTR(ipl_p.performance_dtls,'Dot')-INSTR(ipl_p.performance_dtls,'Wkt-')),'Wkt-',''), SIGNED INTEGER) as "Total no of Wickets" 
from ipl_player as ipl_p 
order by convert(replace(SUBSTRING(ipl_p.performance_dtls, INSTR(ipl_p.performance_dtls,'Wkt-'), 
INSTR(ipl_p.performance_dtls,'Dot')-INSTR(ipl_p.performance_dtls,'Wkt-')),'Wkt-',''), SIGNED INTEGER) desc;


-- 11.	show the percentage of toss wins of each bidder and display the results in descending order based on the percentage


select ibd.bidder_id,sum(case when ibd.bid_team=sub.toss_winning_team then 1 else 0 end )/count(ibd.bid_team)*100 as percentage_toss_wins
from ipl_bidding_details ibd
join ipl_match_schedule ims using( schedule_id)
join (
select (CASE when toss_winner=1 then team_id1 else team_id2 end) as toss_winning_team,match_id
from ipl_match
) sub using(match_id)
group by ibd.bidder_id
order by percentage_toss_wins desc;


--  12.	find the IPL season which has min duration and max duration.
--  Output columns should be like the below:
-- Tournment_ID, Tourment_name, Duration column, Duration

select TOURNMT_ID, TOURNMT_NAME, max(datediff(to_date, from_date)) as max_duration_days
FROM ipl_tournament 
group by TOURNMT_ID
order by max_duration_days desc limit 1;

select TOURNMT_ID, TOURNMT_NAME, min(datediff(to_date, from_date)) as min_duration_days
FROM ipl_tournament 
group by TOURNMT_ID
order by min_duration_days asc limit 1;

-- 13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total points 
-- in descending order and month-wise in ascending order.
-- Note: Display the following columns:
-- 1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
-- Only use joins for the above query queries.


select distinct ibp.bidder_id,ib.bidder_name,year(ibd.bid_date) as Year ,month(ibd.bid_date) as Month ,ibp.TOTAL_POINTS
from ipl_bidder_details ib
join ipl_bidding_details ibd using(bidder_id)
join ipl_bidder_points ibp using (bidder_id)
where year(ibd.bid_date)=2017
order by ibp.TOTAL_POINTS desc, Month;
 

-- 14. Write a query for the above question using sub queries by having the same constraints as the above question.


with CTE as 
		(select distinct ibp.bidder_id,ib.bidder_name,year(ibd.bid_date) as Year ,month(ibd.bid_date) as Month ,ibp.TOTAL_POINTS
from ipl_bidder_details ib
join ipl_bidding_details ibd using(bidder_id)
join ipl_bidder_points ibp using (bidder_id)
where year(ibd.bid_date)=2017
order by ibp.TOTAL_POINTS desc, Month
           )
SELECT bidder_id,bidder_name,year, month,total_points FROM CTE
order by TOTAL_POINTS desc, Month;

-- 15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
-- Output columns should be:
-- like:
-- Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;

select distinct a.bidder_id,a.bidder_name as Highest_3_Bidders, b.total_points as Total_points
from ipl_bidder_details a
join ipl_bidder_points b using(bidder_id)
join ipl_bidding_details c using(bidder_id)
where year(c.bid_date) =2018
order by total_points desc limit 3;

select distinct a.bidder_id,a.bidder_name as Lowest_3_Bidders, b.total_points as Total_points
from ipl_bidder_details a
join ipl_bidder_points b using(bidder_id)
join ipl_bidding_details c using(bidder_id)
where year(c.bid_date) =2018
order by total_points limit 3;