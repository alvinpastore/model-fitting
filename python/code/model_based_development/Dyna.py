from ReinforcementLearningModel import ReinforcementLearningModel
import random


class Dyna(ReinforcementLearningModel):

    R = []
    T = []

    def __init__(self, n_actions, n_states, initial_q):
        self.Q = [[initial_q for x1 in xrange(n_actions)] for x2 in xrange(n_states)]
        self.R = [[0 for x1 in xrange(n_actions)] for x2 in xrange(n_states)]
        self.T = [[[0 for x0 in xrange(n_states)] for x1 in xrange(n_actions)] for x2 in xrange(n_states)]

    def update_Q(self, state, next_state, alpha, gamma, k, nStates, nActions):

        # Update model of the world first
        self.update_model(state, next_state, self.action, alpha, self.reward)

        # Q-Values update for experienced state-action pair
        # state is the linear index of the current state
        sum_transitions_max_q = self.calculate_sum_transitions_max_q(state, self.action, alpha)
        self.Q[state][self.action] = self.R[state][self.action] + (gamma * sum_transitions_max_q)

        # Dyna update of k random state-action pairs
        for i in range(k):
            s_rand = random.randrange(nStates)
            a_rand = random.randrange(nActions)
            # print 'updating pair {0},{1}'.format(s_rand,a_rand)

            # update that couple using T(s_rand,a_rand,all_landing states)*max(Q[landing_state])
            sum_transitions_max_q = self.calculate_sum_transitions_max_q(s_rand, a_rand, alpha)
            self.Q[s_rand][a_rand] = self.R[s_rand][a_rand] + (gamma * sum_transitions_max_q)

    def calculate_sum_transitions_max_q(self, state, action, alpha):
        sum_transitions_max_q = 0
        for state_t in xrange(len(self.T[state][action])):
            self.T[state][action][state_t] += alpha * (0 - self.T[state][action][state_t])
            sum_transitions_max_q += self.T[state][action][state_t] * max(self.Q[state_t])
        return sum_transitions_max_q

    def update_model(self, state, next_state, action, alpha, reward):
        # state and next_state are the linear index of each state

        # update the Reward function R(s,a)
        self.R[state][action] += alpha * (reward - self.R[state][action])
        # update the Transition Probability of the tuple T(s,a,s_t+1)
        self.T[state][action][next_state] += alpha * (1 - self.T[state][action][next_state])
        # decay the T(s,a,s') for all s'
        self.calculate_sum_transitions_max_q(state, action, alpha)

    def print_model(self):
        print 'R'
        print ' \t left \t down \t right \t up'
        i = 0
        for r in self.R:
            print str(i)+' \t {0:.3f}\t{1:.3f}\t{2:.3f}\t{3:.3f}'.format(r[0], r[1], r[2], r[3])
            i += 1

        # TODO finish implementing trans prob print
        print
        print 'T'
        for T in self.T:
            for t in T:
                s = ""
                for value in t:
                    s += ' {0:.3f}'.format(value)
            print s