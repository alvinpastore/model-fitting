import numpy as np

class ModelBased:

    Q = []
    R = []
    T = []
    current_state = np.array([0,0])
    next_state = np.array([0,0])
    action = 0
    reward = 0

    def __init__(self,n_actions,n_states, initial_Q):
        self.Q = [[initial_Q for x1 in xrange(n_actions)] for x2 in xrange(n_states)]
        self.R = [ [0 for x1 in xrange(n_actions)] for x2 in xrange(n_states)]
        self.T = [[[0 for x0 in xrange(n_states)]  for x1 in xrange(n_actions)] for x2 in xrange(n_states)]

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

    def get_reward(self):
        return self.reward

    def update_Q(self,state,action,gamma,sum_transitions_max_Q):
        # state is the linear index of the current state
        self.Q[state][action] = self.R[state][action] + (gamma * sum_transitions_max_Q)

    def update_model(self,state,action,next_state,alpha,reward):
        # state and next_state are the linear index of each state
        self.R[state][action] += alpha * (reward - self.R[state][action])
        self.T[state][action][next_state] += alpha * (1 - self.T[state][action][next_state])
        sum_transitions_max_Q = 0

        for state_t in xrange(len(self.T[state][action])):
            self.T[state][action][state_t] += alpha * (0 - self.T[state][action][state_t])
            sum_transitions_max_Q += self.T[state][action][state_t] * max(self.Q[next_state])
        return sum_transitions_max_Q