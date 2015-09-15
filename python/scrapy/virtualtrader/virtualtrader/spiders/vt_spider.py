# coding=utf-8
from scrapy.selector import HtmlXPathSelector
from scrapy.contrib.spiders import CrawlSpider, Rule
from scrapy.selector import Selector
from virtualtrader.items import VirtualtraderItem
from virtualtrader.settings import *
from scrapy.contrib.linkextractors.sgml import SgmlLinkExtractor
from HTMLParser import HTMLParser
from MySQLdb import escape_string
import re
#datetime
import pytz
from datetime import datetime

'''
Local VARIABLE
'''
cursor = CONN.cursor()

months = {'Jan':'1','Feb':'2','Mar':'3','Apr':'4','May':'5','Jun':'6','Jul':'7','Aug':'8','Sep':'9','Oct':'10','Nov':'11','Dec':'12'}

'''
INSERT INTO DATABASE
'''
def insert_table(datas):
    #sql = "INSERT INTO %s (`name`, `date`, `type`, `stock`, `volume`, `price`, `total`) VALUES ('%s', '%s', '%s', '%s', '%d', '%f', '%f')" % (SQL_TABLE,

    sql = "INSERT INTO %s (name, date, type, stock, volume, price, total) VALUES ('%s', '%s', '%s', '%s', '%d', '%f', '%f')" % (SQL_TABLE,
    escape_string(datas['name']),
    escape_string(datas['date']),
    escape_string(datas['type']),
    escape_string(datas['stock']),
    datas['volume'],
    datas['price'],
    datas['total']
    )
    #print sql
    if cursor.execute(sql):
        #print "Inserted ",datas['name']
        a = 1
        #return True
    else:
        print "Something wrong"
        
'''
Convert date in SQL format
weird inconsistency. if a month is in previous year but todays date is not yet in that month the date is showed as for case 3 (should be shown as case2)
'''
def datify(dateString):
    if ":" in dateString:   #case1 hh:mm 
        year    = str(datetime.now(pytz.utc).year) 
        month   = str(datetime.now(pytz.utc).month)
        day     = str(datetime.now(pytz.utc).day)
        hhmm    = dateString
    elif "'" in dateString: #case2 May'13 (where 13 is the year)
        dateString = dateString.split("'")
        year    = "20"+dateString[1]
        month   = str(months[dateString[0].strip(" ")])
        day     = "01"
        hhmm    = "12:00"
    else:                   #case3 20 May (where 20 is the day)
        dateString = dateString.split(" ")
        month = months[dateString[1]]
        if int(month) <= int(datetime.now(pytz.utc).month):
            year = str(datetime.now(pytz.utc).year)
        else:
            year = str(datetime.now(pytz.utc).year)[:-1]+str(int(str(datetime.now(pytz.utc).year)[3])-1)
        day = dateString[0]
        hhmm = "12:00"
        
    date = year + "-" + month + "-" + day + " " + hhmm
    return date

'''
CrawlSpider
'''
class VTSpider(CrawlSpider):
    parser = HTMLParser()
    name = "vt"
    allowed_domains = ["virtualtrader.co.uk"]
    urlFile = open("urlFile_nohist.txt","r")
    start_urls=[]
    for line in urlFile:
        start_urls.append("http://virtualtrader.co.uk/"+line.rstrip("\n"))
    #start_urls = [
        #"http://virtualtrader.co.uk/vtrader/111;1;0/ranking.aspx","http://virtualtrader.co.uk/default.aspx"
        #"http://virtualtrader.co.uk/vtrader/portfolio/548172/Deb/history.aspx"#http://virtualtrader.co.uk/vtrader/111;172;0/ranking.aspx last
    #]

    rules = (
        # Extract links matching the page url
        # and follow links from them 
        Rule(SgmlLinkExtractor(
                #allow=('111;\d;0/ranking\.aspx',),
                #restrict_xpaths=('//a[@id="ctl00_MiddleContent_PortfolioRanking_linkNext1"]',
                #'//a[@id="ctl00_HeaderContent_ctl00_DynamicControl_5_repMenu_ctl04_linkMainItem"]')), 
                
                restrict_xpaths=(u'//a[contains(text(),"»")]','//a[@id="ctl00_MiddleContent_PortfolioTabs_linkHistory"]',)),
                #&raquo; &#187; #» #\xc2\xbb  #u'//a[contains(text(),"»")]',
                
            callback='parse_item', follow=True),
        )
        
    items = []

    def parse_item(self, response):
        
        #self.log('Hi, this is an item page! %s' % response.url)
        sel = Selector(response)
        name = sel.xpath("//div[@id='MiddleContent']/h1/text()").extract()[0].strip().replace("\n","")
        
        
        #self.log("Name %s" % name)
        
        # wrong solution - works if one name contains it all
        #filePath = "transactions/"+name+".txt"
        #transFile = open(filePath,"a")
        #transFile.write()
        #transFile.close()
        #if name not in self.items:
        #    item = VirtualtraderItem()
        #    item['name'] = name
        #    self.items.append(item)
        
        p = re.compile('<.*?>')
        
        rows=sel.xpath("//tr[contains(@id,'TransactionRow')]").extract()
        for row in rows:
            item = VirtualtraderItem()
            item['name'] = str(name)
            
            row = p.sub("",row)
            row=  row.split("\n")
            
            item['date']    = datify(str(row[0].strip("\t").strip(" ").strip("\r")))
            item['type']    = str(row[1].strip("\t").strip(" ").strip("\r"))
            item['stock']   = str(row[2].strip("\t").strip(" ").strip("\r"))
            vol = row[3].strip("\t").strip(" ").strip("\r")
            item['volume'] = 0 if not vol else int(vol)
            #print  item['volume']
            price = row[4].strip("\t").strip(" ").strip("\r")
            item['price'] = 0 if not price else float(price)
            #print  item['price']
            item['total'] = float(row[5].strip("\t").strip(" ").strip("\r").replace(",",""))
            #print  item['total']
            #raw_input("")
            self.items.append(item)
            insert_table(item)
        
        #print self.items
        #raw_input("continue")
        #return self.items
        #self.log("Inserted %s" % name)

        CONN.commit()
        
        
        
        #Individual investor url extraction
        ''' 
        urlFile = open("urlFile.txt","a")
        
        self.log('Hi, this is an item page! %s' % response.url)
        sel = Selector(response)
        print "----------------------------------just visited",response.url
        transactions_urls = sel.xpath('//td[@class="Name"]/a/@href').extract()
        for raw_url in transactions_urls:
            url = raw_url[:-5] + "/history.aspx"
            print url
            urlFile.write(url+"\n")
            
            #remove '.aspx'
        #    raw_input("ASD")
        urlFile.close()
        '''
        
        
        
        # Various useful lines
        ''' 
        for url in toCrawl:
            #swap current url from toCrawl to crawled
            toCrawl.remove(url)
            crawled.append(url)
            #retrieve next page in ranking
            toCrawl.append(sel.xpath('//a[@id="ctl00_MiddleContent_PortfolioRanking_linkNext1"]/@href').extract())

        names = sel.xpath('//td[@class="Name"]/a/text()').extract()
        urls = sel.xpath
        items = []
        for n in names:
            #print n
            item = VirtualtraderItem()
            item['name'] = n
            items.append(item)
            print item
        
        
        return items
        '''
