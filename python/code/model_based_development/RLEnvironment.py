import numpy as np


WALL_PENALTY = 10
STOCHASTIC_PENALTY = 5
STOCHASTIC_ENV = False

def linearize(t, c):
    return int(c * t[0] + t[1])

# position anywhere except last row and column (to avoid being positioned on the final state)
def randomise_initial_state(c,r):
    return np.array([np.random.randint(r-1),np.random.randint(c-1)])

def get_next_state(action,state):
    if action == 0:
        next_state = [state[0],state[1]-1]      # go left (west)
    elif action == 1:
        next_state = [state[0]+1,state[1]]      # go down (south)
    elif action == 2:
        next_state = [state[0], state[1]+1]     # go right (east)
    elif action == 3:
        next_state = [state[0]-1, state[1]]     # go up (north)
    return next_state

#TODO these assignments work! don't know why
def get_reward(next_state,state,world):
    # hitting walls
    if next_state[0] < 0 or next_state[0] > world.shape[0] - 1: #rows
        reward = - WALL_PENALTY
        next_state[0] = state[0]
    elif next_state[1] < 0 or next_state[1] > world.shape[1] - 1:  #cols
        reward = - WALL_PENALTY
        next_state[1] = state[1]
    # not hitting walls
    else:
        if STOCHASTIC_ENV and is_upper_triangle(next_state):
           if np.random.rand() < 0.2: # 1/10 dont move
               return - STOCHASTIC_PENALTY
        reward = world[next_state[0]][next_state[1]]
    return reward

def is_upper_triangle(state):
    if state[0] < state[1]:
        return True


def is_final_state(curr_state,final_state):
    return curr_state[0] == final_state[0] and curr_state[1] == final_state[1]

def change_goal(world):
    rows = world.shape[0]
    cols = world.shape[1]
    world[rows-1,cols-1] = 0
    world[rows-1,0] = 100
    win_state = np.array([rows-1,0])
    return [world,win_state]