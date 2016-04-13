
from ReinforcementLearningModel import ReinforcementLearningModel


class QLearning(ReinforcementLearningModel):

    def update_Q(self, state, next_state, action, reward, alpha, gamma):
        td_error = (reward + (gamma * max(self.Q[next_state])) - self.Q[state][action])
        # state is the linear index of the current state
        self.Q[state][action] += + alpha * td_error
