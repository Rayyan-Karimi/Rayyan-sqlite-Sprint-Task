--Table info
PRAGMA table_info(table_name);
-- Create tables
CREATE TABLE organization (id integer primary key autoincrement, name text not null);
create table channel (id integer primary key autoincrement, name text not null, org_id integer, foreign key (org_id) references organization(id));

create table user( id integer primary key autoincrement, name text not null);
create table messages (id integer primary key autoincrement, content text not null, post_time datetime default current_timestamp, user_id integer not null, channel_id integer not null, foreign key (user_id) references user(id), 
foreign key (channel_id) references channel(id));

create table subscriptions (id integer primary key autoincrement, channel_id integer not null, user_id integer not null, foreign key (channel_id) references channel(id), foreign key (user_id) references user(id));


--INSERTIONS
insert into organization (name) values ("Lambda School");
insert into user(name) values("Alice"), ("Bob"), ("Chris");
insert into channel(name, org_id) values("#general", 1), ("#random", 1);
insert into messages (content, user_id, channel_id) Values ("Message A-G", 1, 1), ("Message bg", 2, 1), ("Message cg", 3, 1), ("Message ar", 1, 2), ("Message br", 2, 2), ("Message cr", 3, 2), ("Message ar2", 1, 2), ("Message cr2", 3, 2), ("Message ag2", 1, 1), ("Message br2", 2, 2);
Insert into subscriptions (user_id, channel_id) Values (1,1), (1,2), (2,1), (3,2);

-- List all organization names.
sELECT * FROM oRGANIZATION;
-- List all channel names.
SELECT * FROM CHANNEL;
-- List all channels in a specific organization by organization name.
select channel.name, organization.name from channel inner join organization on channel.org_id=organization.id where organization.name = "Lambda School";

--List all messages in a specific channel by channel name #general in order of post_time, descending. (Hint: ORDER BY. Because your INSERTs might have all taken place at the exact same time, this might not return meaningful results. But humor us with the ORDER BY anyway.)
Select messages.content, messages.post_time from messages 
inner join channel on messages.channel_id = channel.id 
where channel.name = "#general" 
order by messages.post_time desc;
-- List all channels to which user Alice belongs.
select channel.name from channel
inner join subscriptions on channel.id = subscriptions.channel_id
inner join user on subscriptions.user_id = user.id
where user.name = "Alice";
-- List all users that belong to channel #general.
Select user.name from user inner join subscriptions on user.id=subscriptions.user_id inner join channel on subscriptions.channel_id = channel.id where channel.name = "#general";
-- List all messages in all channels by user Alice.
Select content from messages inner join user on messages.user_id = user.id where user.name = "Alice";
--List all messages in #random by user Bob
select content from messages inner join channel on messages.channel_id = channel.id inner join user on messages.user_id = user.id where user.name = "Bob" and channel.name = "#random";
-- List the count of messages across all channels per user. (Hint: COUNT, GROUP BY.)
select user.name as "User Name", count(*) as "Message Count" from messages inner join channel on messages.channel_id = channel.id inner join user on messages.user_id = user.id group by user.name;
-- [Stretch!] List the count of messages per user per channel.
Select user.name as "User", channel.name as "Channel", Count(*) as "Message Count" from messages inner join channel on messages.channel_id = channel.id inner join user on messages.user_id = user.id group by user.name, channel.name;



-- What SQL keywords or concept would you use if you wanted to automatically delete all messages by a user if that user were deleted from the user table?
--there are two ways to go about this:
--
--1. USE "ON DELETE CASCADE" keyword in the Table property definition of messages.user_id:
--Our code changes to :-
--create table messages ( id integer primary key autoincrement, content text not null, post_time datetime default current_timestamp, user_id not null, channel_id not null, FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE, foreign key (channel_id) references channel(id));
--I have put the change in ALL CAPS to highlight it.
--This will automatically delete all entries of messages table if the user_id here (in messages table) matches the id of the recently deleted user from the user table.
--e.g. DELETE FROM user WHERE name = "Alice" <<- will delete all entries of Alice's messages from the messages table.
--
--2. Second way is to manually delete. For example, 
--DELETE FROM user WHERE name = "Alice"
--then
--SELECT * FROM messages where messages.user_id not in (select id from user);
--shows the pending rows to be deleted.
--DELETE FROM messages where messages.user_id not in (select id from user);
--will delete these rows.
