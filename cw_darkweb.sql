CREATE TABLE `darkweb_accounts` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`name` TINYTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`rating` INT(11) NULL DEFAULT '0',
	`citizenId` TINYTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`sales` INT(11) NULL DEFAULT '0',
	`purchases` INT(11) NULL DEFAULT '0',
	`moneyHeld` INT(11) NULL DEFAULT '0',
	`status` TINYTEXT NULL DEFAULT 'OK' COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `citizenId` (`citizenId`(255)) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=14
;
