from ReinforcementLearningModel import ReinforcementLearningModel

class Sarsa(ReinforcementLearningModel):

    def update_Q(self,state, next_state, action, reward, alpha, gamma):
        next_action = self.pick_random_best_action(self.Q[next_state])
        TD_error = reward + (gamma * next_action) - self.Q[state][action]
        # state is the linear index of the current state
        self.Q[state][action] += + alpha * TD_error