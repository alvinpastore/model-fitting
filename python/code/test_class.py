import numpy as np
class test_class:
	
	A = np.array([0,0])
	
	def __init__(self,a):
		self.A = a
	
	def set_A(self,a):
		self.A = a	

	def get_A(self):
		return self.A


def some_fun(var,var2):
	var[0] = var2[0]

if __name__ == '__main__':
	b = np.array([10,10])

	tc = test_class(b)

	c = tc.get_A()
	d = tc.A

	print 'c before',c
	print 'd before',d

	tc.set_A([15,40])

	print 'c after',c
	print 'd after',d

	some_fun(tc.A,np.array([100,100]))

	print 'c after2',c
	print 'd after2',d
