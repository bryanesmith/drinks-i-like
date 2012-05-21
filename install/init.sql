USE `drinks_i_like`;

-- Just one table.
DROP TABLE IF EXISTS `drink`;

CREATE TABLE `drink` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY( `id` )
);

-- Test data.
INSERT INTO `drink`( `title`, `description` ) VALUES ( 'milk', '"Baby mammals drink milk, and you sir, are a baby mammal." - Mark Rippetoe' );

