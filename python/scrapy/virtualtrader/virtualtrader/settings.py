# Scrapy settings for virtualtrader project
#
# For simplicity, this file contains only the most important settings by
# default. All the other settings are documented here:
#
#     http://doc.scrapy.org/en/latest/topics/settings.html
#
import sys
import MySQLdb

# SCRAPY SETTINGS
BOT_NAME = 'virtualtrader'
SPIDER_MODULES = ['virtualtrader.spiders']
NEWSPIDER_MODULE = 'virtualtrader.spiders'

# SQL DATABASE SETTINGS
SQL_DB = "virtualtrader"
SQL_TABLE = "transactions"
SQL_HOST = "localhost"
SQL_USER = "root"
SQL_PASSWD = "root"

# connect to MySQL server
try:
    CONN = MySQLdb.connect(host=SQL_HOST,
                            user=SQL_USER,
                            passwd=SQL_PASSWD,
                            db=SQL_DB)
except MySQLdb.Error, e:
    print "Error %d: %s" % (e.args[0], e.args[1])
    sys.exit(1)


# Crawl responsibly by identifying yourself (and your website) on the user-agent
#USER_AGENT = 'virtualtrader (+http://www.yourdomain.com)'
