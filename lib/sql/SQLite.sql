-- 数据库: `moment.cql`
--
--
-- SQLite
--


-- 个人偏好设置

-- CREATE TABLE moment_option (
-- "id" INTEGER NOT NULL PRIMARY KEY,
-- "authorId" int(10) default '0',
-- "name" varchar(32) default NULL ,
-- "value" varchar(32) default NULL ,
-- "status" int(10) default '0' )


-- user

-- CREATE TABLE moment_user (
-- "id" INTEGER NOT NULL PRIMARY KEY,
-- "created" int(10) default '0' ,
-- "modified" int(10) default '0' ,
-- "avatar" varchar(200) default NULL,
-- "gender" int(10) default '0',
-- "birthday" int(10) default '0' ,
-- "bio" varchar(200) default NULL,
-- "city" varchar(16) default '未知'
-- "status" int(10) default '0' )


-- 内容
-- event version2 废弃

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
"face" int(10) default '80',
"weather" int (10) default '4',
"alum" varchar(200) default '',
"commentsNum" int(10) default '0' ,
"allowComment" char(1) default '0', )

-- 事件

CREATE TABLE moment_event (
"id" INTEGER NOT NULL PRIMARY KEY,
"authorId" int(10) default '0',
"icon" varchar(32) default NULL,
"name" varchar(200) default NULL,
"created" int(10) default '0',
"description" varchar(200) default '',
"status" int(10) default '0' )


-- 事件 - 瞬间关联表

CREATE TABLE content_event (
"id" INTEGER NOT NULL PRIMARY KEY,
"authorId" int(10) default '0',
"eid" int(10) default NULL,
"cid" int(10) default NULL,
"created" int(10) default '0' )


--CREATE TABLE moment_flag (
--"id" INTEGER NOT NULL PRIMARY KEY,
--"title" varchar(32) default NULL ,
--"created" int(10) default '0' ,
--"time" int(10) default '0',
--"notifyTime" int(10) default '0',
--"description" varchar(200) default '',
--"status" int(10) default '0' )
