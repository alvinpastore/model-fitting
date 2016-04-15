from ReinforcementLearningModel import ReinforcementLearningModel


class Sarsa(ReinforcementLearningModel):

    def update_Q(self, state, next_state, alpha, gamma, k, nStates, nAction):
        next_action = self.pick_random_best_action(self.Q[next_state])
        td_error = self.reward + (gamma * self.Q[next_state][next_action]) - self.Q[state][self.action]
        self.Q[state][self.action] += + alpha * td_error
