import numpy as np

class ReinforcementLearningModel:

    ACTION_TOLERANCE = 0.1 #qvalue difference tolerance in selecting an action (check pick_random_best_action)
    Q = []
    current_state = np.array([0,0])
    next_state = np.array([0,0])
    action = 0
    reward = 0

    def __init__(self,n_actions,n_states,initial_Q):
       self.Q = [[initial_Q for x1 in xrange(n_actions)] for x2 in xrange(n_states)]

    def set_current_state(self,current_state):
        self.current_state = current_state

    def get_current_state(self):
        return self.current_state

    def set_next_state(self,next_state):
        self.next_state = next_state

    def get_next_state(self):
        return self.next_state

    def set_action(self,action):
        self.action = action

    def get_action(self):
        return self.action

    def set_reward(self,reward):
        self.reward = reward

    def update_Q(self):
        #TODO override
        pass

    def print_Q(self):
        i = 0
        print
        print 'Q'
        print '\t left \t down \t right \t up'
        for q in self.Q:
            print str(i)+'\t {0:.3f}\t{1:.3f}\t{2:.3f}\t{3:.3f}'.format(q[0],q[1],q[2],q[3])
            i+=1

    # finds the occurrences of the max in a list
    # and returns the index of one of them, randomly
    # if the q_value of an action converges to a value which is higher than the other values
    # and there is very low exploration epsilon, then that action will be picked always (deadlock)
    def pick_random_best_action(self,actions):
        m = max(actions)
        # allow for some tolerance to avoid deadlocks
        if m >= 0:
            #m -= m/10
            m -= self.ACTION_TOLERANCE
        else:
            #m += m/10
            m += - self.ACTION_TOLERANCE
        # print 'm',m
        best_acts = [act_i for act_i,act in enumerate(actions) if act >= m]
        # print 'q',actions
        # print 'b',best_acts
        # print
        #print 'picked action '+str(best_acts[int(np.floor(np.random.rand() * len(best_acts)))])
        return best_acts[int(np.floor(np.random.rand() * len(best_acts)))]

