
--=================================================================
--
-- Q1. List all persons who are both clients and staff members. Order the result by pid in ascending order.
--
-- First I create a temp1 view of pid, firstname and lastname of all the staff.
create or replace view temp1(pid, firstname, lastname) 
as 
select p1.pid, p1.firstname, p1.lastname from person p1 join staff p2 
on p1.pid=p2.pid 
order by p1.pid;
-- Then use this temp view to create Q1 view which joins on the same pid's from the staff and 
-- the client.
create or replace view Q1(pid, firstname, lastname) as 
select p1.pid, p1.firstname, p1.lastname from temp1 p1 join client p2 
on p1.pid = p2.pid 
order by p1.pid;

-- alternate solution to not use two steps =>
create or replace view Q1(pid, firstname, lastname) as 
select p1.pid, p1.firstname, p1.lastname 
from person p1 
join staff p2 on p1.pid=p2.pid 
join client p3 on p2.pid = p3.pid
order by p1.pid;
--=================================================================
--
-- Q2. For each car brand, list the car insured by the most expensive policy (the premium, i.e., the sum of its coverages' rates). 
-- Order the result by brand, and then by car id, pno if there are ties, all in ascending order.

create or replace view Q2(brand, car_id, pno, premium) as 
select distinct on (insured_item.brand) insured_item.brand, policy.id, policy.pno, rating_record.rate 
from policy 
join insured_item on policy.id=insured_item.id
join coverage on policy.pno=coverage.pno
join rating_record on coverage.coid=rating_record.coid
group by insured_item.brand, policy.id, policy.pno, rating_record.rate
order by insured_item.brand ASC, rating_record.rate DESC, policy.id ASC, policy.pno ASC;
--=================================================================
--
-- Q3. List all the staff members who did not sell any policies in the last 365 calendar days (from today). 
-- Note that policy.sid records the staff who sold this policy, underwritten_by.wdate records the date a policy is sold (we ignore the status here). 
-- Order the result by pid in ascending order.
create or replace view Q3(pid, firstname, lastname) as 
select staff.pid, person.firstname, person.lastname
from person
join staff on person.pid=staff.pid
left join underwritten_by on underwritten_by.sid=staff.sid
where underwritten_by.wdate <= CURRENT_DATE - interval '1 year' or underwritten_by.wdate is null
order by person.pid ASC;

--=================================================================
--
-- Q4. For each suburb in NSW, compute the number of policies that have been sold to the policy holders living in the suburb (regardless of the policy status). 
-- Order the result by Number of Policies (npolicies), then by suburb, in ascending order. 
-- Exclude suburbs with no sold policies. Furthermore, suburb names are output in all uppercase.
--
-- First we take out people living in suburbs of NSW.
create or replace view numberofpolicies(pid, numpol) as 
select c.pid, count(i.pno) 
from client c join insured_by i on c.cid=i.cid 
group by c.pid;

create or replace view suburbpol(pid, suburb, npolicies) as 
select p.pid, p.suburb, n.numpol 
from person p join numberofpolicies n on p.pid = n.pid 
where p.state = 'NSW' 
order by p.pid;

create or replace view Q4(suburb, npolicies) as 
select s.suburb, sum(s.npolicies) 
from suburbpol s
group by s.suburb, s.npolicies 
order by s.npolicies;
--=================================================================
-- Q5. Find the policies which are rated, underwritten, and sold by the same staff member. 
-- Order the result by pno in ascending order.
create or replace view Q5(pno, pname, pid, firstname, lastname) as 
select distinct policy.pno, policy.pname, person.pid, person.firstname, person.lastname
from policy
join staff on staff.sid=policy.sid
join person on person.pid=staff.pid
join underwritten_by on underwritten_by.sid=staff.sid
join rated_by on rated_by.sid=underwritten_by.sid
order by policy.pno ASC;
--=================================================================
-- Q6. List the staff members (their firstname, a space and then the lastname as one column called name) 
-- who only sell policies to cover one brand of cars. 
-- Order the result by pid in ascending order.
create or replace view tempQ6(sid, pid, id, brand, name) as
select distinct staff.sid, staff.pid, policy.id, insured_item.brand, person.firstname||' '||person.lastname
from Policy, 
insured_item,
Staff, 
Person
where insured_item.id = policy.id 
and staff.sid = policy.sid 
and person.pid = staff.pid;

create or replace view Q6(pid, name, brand) as 
select staff1.pid, staff1.name, staff1.brand 
from tempQ6 as staff1 
where not 
exists 
(select * from tempQ6 
as staff2 
where staff1.name = staff2.name 
and staff1.brand != staff2.brand) 
order by staff1.pid;
--=================================================================
-- Q8. For each policy X, compute the number of other policies (excluding X) whose coverage is contained by the coverage of X. 
-- For example, if a policy X has 3 coverages (identified by cname), say {C1, C2, C3}, 
-- and another policy Y has 2 coverages, {C1, C3}, we say Y's coverage is contained by X's. 
-- In case if X's and Y's coverages are identical, their coverages are contained by each other. 
-- Order the result by pno in ascending order. 
-- Exclude policies that contain no other policies in your output (i.e., exclude those with npolicies being 0). [Ignore the policy status.]
create or replace view Q8(pno, npolicies) as
select distinct pno1, count(pno1) from (
	select client1.pno1, client1.pno3, count(*) matches from (
        select distinct client2.pno as pno1 ,client2.cname as cname, client3.pno as pno3, client3.cname as cname3 from Coverage client2
        inner join Coverage client3 on client2.cname = client3.cname 
        and client2.pno <> client3.pno)  client1
    group by client1.pno1 , client1.pno3
    ) sup
	inner join
    (
    select pno, count(distinct cname) reqs 
    from Coverage 
    group by pno
    ) sub
on sub.pno = sup.pno3 
and sup.matches = sub.reqs
group by pno1;