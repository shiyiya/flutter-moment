-- 数据库: `moment.cql`
--
--
-- SQLite
--

CREATE TABLE moment_content (
"cid" INTEGER NOT NULL PRIMARY KEY,
"title" varchar(200) default NULL ,
"created" int(10) default '0' ,
"modified" int(10) default '0' ,
"text" text default '',
"authorId" int(10) default '0' ,
"status" varchar(16) default 'publish' ,
"password" varchar(32) default NULL ,
"event" varchar(32) default '',
"location" varchar(16) default '',
"face" int(10) default '4',
"weather" int (10) default '4',
"alum" varchar(200) default '',
"commentsNum" int(10) default '0' ,
"allowComment" char(1) default '0', )

