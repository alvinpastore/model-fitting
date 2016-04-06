class Person(object):
	legs = 0
	def __init__(self,legs):
		self.legs = legs
	
	def sleep(self):
		print 'sleep'
		
	def details(self):
		print 'legs',self.legs
	
class Man(Person):
	eyes = 0
	
	def __init__(self,legs,eyes):
		super(Man,self).__init__(2)
		self.eyes = eyes
	
	def details(self):
		super(Man,self).details()
		print 'eyes',self.eyes
		

if __name__  == '__main__':
	p = Person(2)
	p.sleep()
	print'person'
	p.details()
	m = Man(2,3)
	m.sleep()
	print 'man'
	m.details()

	
	