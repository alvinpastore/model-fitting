import numpy as np

class QLearning:

    Q = []
    current_state = np.array([0,0])
    next_state = np.array([0,0])
    action = 0
    reward = 0

    def __init__(self,n_actions,n_states,initial_Q):
       self.Q = [[initial_Q for x1 in xrange(n_actions)] for x2 in xrange(n_states)]

    def set_current_state(self,current_state):
        self.current_state = current_state

    def set_next_state(self,next_state):
        self.next_state = next_state

    def set_action(self,action):
        self.action = action

    def set_reward(self,reward):
        self.reward = reward

    def update_Q(self,state,action,alpha,TD_error):
        # state is the linear index of the current state
        self.Q[state][action] += + alpha * TD_error