-- MySQL dump 10.13  Distrib 5.6.36-82.0, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: raptor
-- ------------------------------------------------------
-- Server version 5.6.36-82.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!50112 SELECT COUNT(*) INTO @is_rocksdb_supported FROM INFORMATION_SCHEMA.SESSION_VARIABLES WHERE VARIABLE_NAME='rocksdb_bulk_load' */;
/*!50112 SET @save_old_rocksdb_bulk_load = IF (@is_rocksdb_supported, 'SET @old_rocksdb_bulk_load = @@rocksdb_bulk_load', 'SET @dummy_old_rocksdb_bulk_load = 0') */;
/*!50112 PREPARE s FROM @save_old_rocksdb_bulk_load */;
/*!50112 EXECUTE s */;
/*!50112 SET @enable_bulk_load = IF (@is_rocksdb_supported, 'SET SESSION rocksdb_bulk_load = 1', 'SET @dummy_rocksdb_bulk_load = 0') */;
/*!50112 PREPARE s FROM @enable_bulk_load */;
/*!50112 EXECUTE s */;
/*!50112 DEALLOCATE PREPARE s */;

--
-- Table structure for table `http`
--

DROP TABLE IF EXISTS `http`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `http` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `hit_http` int(10) unsigned NOT NULL DEFAULT '0',
  `file` int(11) unsigned NOT NULL,
  `count_user` int(11) unsigned NOT NULL,
  `file_size` bigint(20) unsigned NOT NULL DEFAULT '0',
  `d_down` date NOT NULL,
  `d_req` date NOT NULL,
  `requested_size` bigint(20) unsigned NOT NULL DEFAULT '0',
  `thread_usage` smallint(8) unsigned NOT NULL DEFAULT '0',
  `percent` varchar(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=TokuDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `http`
--

LOCK TABLES `http` WRITE;
/*!40000 ALTER TABLE `http` DISABLE KEYS */;
/*!40000 ALTER TABLE `http` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `raptor`
--

DROP TABLE IF EXISTS `raptor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `raptor` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `file` varchar(767) NOT NULL,
  `domain` varchar(255) NOT NULL,
  `ext` varchar(10) NOT NULL,
  `ip` varchar(30) NOT NULL,
  `init_size` int(10) unsigned NOT NULL DEFAULT '0',
  `last_status` datetime NOT NULL,
  `d_down` date NOT NULL,
  `downloaded` datetime NOT NULL,
  `d_req` date NOT NULL,
  `requested_size` int(22) unsigned NOT NULL DEFAULT '0',
  `last_request` datetime NOT NULL,
  `thread_usage` int(8) unsigned NOT NULL DEFAULT '0',
  `range_size` varchar(6200) NOT NULL DEFAULT '',
  `part_position` varchar(3000) NOT NULL DEFAULT '',
  `file_size` int(11) NOT NULL DEFAULT '0',
  `num_range` int(9) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `file_domain` (`file`,`domain`)
) ENGINE=TokuDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `raptor`
--

LOCK TABLES `raptor` WRITE;
/*!40000 ALTER TABLE `raptor` DISABLE KEYS */;
/*!40000 ALTER TABLE `raptor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ssl`
--

DROP TABLE IF EXISTS `ssl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ssl` (
  `id_ssl` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(20) NOT NULL,
  `count_files` int(11) unsigned NOT NULL,
  `file_size` bigint(20) unsigned NOT NULL,
  `eco_size` bigint(20) unsigned NOT NULL,
  `hits` int(11) unsigned NOT NULL,
  `date_ssl` date NOT NULL,
  PRIMARY KEY (`id_ssl`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ssl`
--

LOCK TABLES `ssl` WRITE;
/*!40000 ALTER TABLE `ssl` DISABLE KEYS */;
/*!40000 ALTER TABLE `ssl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `idUser` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `loginUser` varchar(15) NOT NULL,
  `passUser` varchar(60) NOT NULL,
  `idprofile` int(11) NOT NULL,
  `emailUser` varchar(50) NOT NULL,
  PRIMARY KEY (`idUser`),
  UNIQUE KEY `loginUsers` (`loginUser`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'admin','21232f297a57a5a743894a0e4a801fc3',1,'admin@admin.com'),(2,'user','81dc9bdb52d04dc20036dbd8313ed055',2,'user@user.com');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_mk`
--

DROP TABLE IF EXISTS `user_mk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_mk` (
  `id_mk` int(6) NOT NULL AUTO_INCREMENT,
  `ip_mk` varchar(20) NOT NULL,
  `user_mk` varchar(22) NOT NULL,
  `pass_mk` varchar(22) NOT NULL,
  PRIMARY KEY (`id_mk`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_mk`
--

LOCK TABLES `user_mk` WRITE;
/*!40000 ALTER TABLE `user_mk` DISABLE KEYS */;
INSERT INTO `user_mk` VALUES (1,'0.0.0.0','admin','');
/*!40000 ALTER TABLE `user_mk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_profile`
--

DROP TABLE IF EXISTS `user_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_profile` (
  `idProfile` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `codeProfi` varchar(10) NOT NULL,
  `nameProfi` varchar(10) NOT NULL,
  `descProfi` varchar(250) NOT NULL,
  `dateProfi` date NOT NULL,
  PRIMARY KEY (`idProfile`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_profile`
--

LOCK TABLES `user_profile` WRITE;
/*!40000 ALTER TABLE `user_profile` DISABLE KEYS */;
INSERT INTO `user_profile` VALUES (1,'1','admin','','0000-00-00'),(2,'2','invitado','','0000-00-00');
/*!40000 ALTER TABLE `user_profile` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-09-29 12:38:21
