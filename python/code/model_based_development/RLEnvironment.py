import numpy as np


class RLEnvironment:

    WALL_PENALTY = 0
    STOCHASTIC_PENALTY = 0
    STOCHASTIC_PENALTY_PROB = 0.0
    rows = 0
    cols = 0
    world = None
    win_state = None
    nStates = 0

    def __init__(self, wall_penalty, stochastic_penalty, stochastic_penalty_probability, world_file, win_reward):
        self.WALL_PENALTY = wall_penalty
        self.STOCHASTIC_PENALTY = stochastic_penalty
        self.STOCHASTIC_PENALTY_PROB = stochastic_penalty_probability
        self.read_world_file(world_file, win_reward)
        self.nStates = self.rows * self.cols

    def read_world_file(self, world_file, win_reward):
        world_structure = []
        with open(world_file, 'r') as wf:
            for row in wf:
                world_structure.append(row)

        cols = len(world_structure[0])
        if not all(len(row) == cols for row in world_structure):
            print 'World File Bad Format: columns numbers are not consistent'
        else:
            self.cols = cols - 1    # accounting for newline character
            self.rows = len(world_structure)

        self.world = np.zeros((self.rows, self.cols))

        for row in world_structure:
            for elem in row:
                if elem == 'O':
                    self.win_state = np.array([world_structure.index(row), row.index(elem)])
                    self.world[world_structure.index(row), row.index(elem)] = win_reward

    def linearize(self, t, c):
        return int(c * t[0] + t[1])

    # position anywhere except last row and column (to avoid being positioned on the final state)
    def randomise_initial_state(self, c, r):
        return np.array([np.random.randint(r-1), np.random.randint(c-1)])

    def get_next_state(self, action, state):
        if action == 0:
            next_state = [state[0], state[1]-1]      # go left (west)
        elif action == 1:
            next_state = [state[0]+1, state[1]]      # go down (south)
        elif action == 2:
            next_state = [state[0], state[1]+1]     # go right (east)
        elif action == 3:
            next_state = [state[0]-1, state[1]]     # go up (north)
        return next_state

    # TODO these assignments DO work! don't know why
    def get_reward(self, next_state, state, world):
        # hitting walls
        if next_state[0] < 0 or next_state[0] > world.shape[0] - 1:  # rows
            reward = - self.WALL_PENALTY
            next_state[0] = state[0]
        elif next_state[1] < 0 or next_state[1] > world.shape[1] - 1:  # cols
            reward = - self.WALL_PENALTY
            next_state[1] = state[1]
        # not hitting walls
        else:
            if self.STOCHASTIC_PENALTY_PROB and self.is_upper_triangle(next_state):
                if np.random.rand() < self.STOCHASTIC_PENALTY_PROB:
                    next_state[0] = state[0]
                    next_state[1] = state[1]
                    # print 'penalty'
                    # return - STOCHASTIC_PENALTY
            reward = world[next_state[0]][next_state[1]]
        return reward

    def is_upper_triangle(self, state):
        if state[0] < state[1]:
            return True

    def is_final_state(self, curr_state, final_state):
        return curr_state[0] == final_state[0] and curr_state[1] == final_state[1]

    def change_goal(self, world):
        rows = world.shape[0]
        cols = world.shape[1]
        world[rows-1, cols-1] = 0
        world[rows-1, 0] = 100
        win_state = np.array([rows-1, 0])
        return [world, win_state]
