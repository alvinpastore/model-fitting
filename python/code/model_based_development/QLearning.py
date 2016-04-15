from ReinforcementLearningModel import ReinforcementLearningModel


class QLearning(ReinforcementLearningModel):

    def update_Q(self, state, next_state, alpha, gamma, k, nStates, nAction):
        td_error = (self.reward + (gamma * max(self.Q[next_state])) - self.Q[state][self.action])
        self.Q[state][self.action] += + alpha * td_error
