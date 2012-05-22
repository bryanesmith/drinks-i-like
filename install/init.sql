USE `drinks_i_like`;

-- Just one table.
DROP TABLE IF EXISTS `drink`;

CREATE TABLE `drink` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY( `id` ),
  UNIQUE ( `title` )
);

-- Test data.
INSERT INTO `drink`( `title`, `description` ) VALUES ( 'milk', '"Milk is for babies. When you grow up you have to drink beer." - Arnold Schwarzenegger' );

