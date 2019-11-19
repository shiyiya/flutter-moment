-- 数据库: `moment.cql`
--

-- --------------------------------------------------------

--
-- MySQL
--

CREATE TABLE `moment_content` (
  `cid` int(10) unsigned NOT NULL auto_increment,
  `title` varchar(200) default NULL,
  `created` int(10) unsigned default '0',
  `modified` int(10) unsigned default '0',
  `text` longtext default '',
  `authorId` int(10) unsigned default '0',
  `status` varchar(16) default 'publish',
  `password` varchar(32) default NULL,
  `commentsNum` int(10) unsigned default '0',
  `allowComment` char(1) default '0',
  PRIMARY KEY  (`cid`),
  KEY `created` (`created`)
) ENGINE=MyISAM  DEFAULT CHARSET=%charset%;


