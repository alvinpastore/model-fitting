from ReinforcementLearningModel import ReinforcementLearningModel

class ModelBased(ReinforcementLearningModel):

    R = []
    T = []

    def __init__(self,n_actions,n_states, initial_Q):
        self.Q = [[initial_Q for x1 in xrange(n_actions)] for x2 in xrange(n_states)]
        self.R = [ [0 for x1 in xrange(n_actions)] for x2 in xrange(n_states)]
        self.T = [[[0 for x0 in xrange(n_states)]  for x1 in xrange(n_actions)] for x2 in xrange(n_states)]


    def update_Q(self,state,action,gamma,sum_transitions_max_Q):
        # state is the linear index of the current state
        self.Q[state][action] = self.R[state][action] + (gamma * sum_transitions_max_Q)

    def update_model(self,state,next_state,action,alpha,reward):
        # state and next_state are the linear index of each state
        self.R[state][action] += alpha * (reward - self.R[state][action])
        self.T[state][action][next_state] += alpha * (1 - self.T[state][action][next_state])
        sum_transitions_max_Q = 0

        for state_t in xrange(len(self.T[state][action])):
            self.T[state][action][state_t] += alpha * (0 - self.T[state][action][state_t])
            sum_transitions_max_Q += self.T[state][action][state_t] * max(self.Q[state_t])
        return sum_transitions_max_Q

    def print_model(self):
        print 'R'
        print ' \t left \t down \t right \t up'
        i =0
        for r in self.R:
            print str(i)+' \t {0:.3f}\t{1:.3f}\t{2:.3f}\t{3:.3f}'.format(r[0],r[1],r[2],r[3])
            i+=1

        #TODO finish implementing trans prob print
        print
        print 'T'
        for T in self.T:
            for t in T:
                s = ""
                for value in t:
                    s += ' {0:.3f}'.format(value)
            print s