from __future__ import division
import numpy as np
import matplotlib.pyplot as plt
from QLearning import QLearning
from ModelBased import ModelBased

def linearize(t, c):
    return int(c * t[0] + t[1])

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

#TODO check if these assignments work (now the states are attributes of the class)
def get_reward(next_state,state):
    # hitting walls
    if next_state[0] < 0 or next_state[0] > rows - 1:
        reward = -10
        next_state[0] = state[0]
    elif next_state[1] < 0 or next_state[1] > cols - 1:
        reward = -10
        print 'hit wall, '
        print 'state= {0}, next= {1}, but next is now old'.format(state[1],next_state[1])
        print 'reward = -10'
        raw_input()
        next_state[1] = state[1]
    # not hitting walls
    else:
        if is_upper_triangle(next_state):
            if np.random.rand() < 0.1: # 1/10 dont move
                return -1

        reward = world[next_state[0]][next_state[1]]

    return reward

def is_upper_triangle(state):
    if state[0] < state[1]:
        return True

PLOTS = False

# RL setup
episodes = 100
trials = 100
epsilon = 0.01
alpha = 0.2
gamma = 0.9
initial_Q = 5   # optimism in the face of uncertainty (initialise qvalues high)

# world
rows = 10
cols = 10
nStates = rows*cols
world = np.zeros((rows,cols))
world[rows-1,cols-1] = 100
win_state = np.array([rows-1,cols-1])
nActions = 4 # north south west east

steps = {'mb':[],'ql':[]}

if PLOTS:
    plt.ion()
    plt.close('all')

    # figure and step counter
    fig = plt.figure()
    ax = fig.add_subplot(111)
    plt.show()

for trial in range(trials):
    print 'trial',trial

    counter_mb = []
    counter_ql = []

    QL = QLearning(nActions,nStates,initial_Q)
    MB = ModelBased(nActions,nStates,initial_Q)

    for episode in range(episodes):

        ''' MB '''
        step_counter = 0
        init_rand_state = randomise_initial_state(cols,rows)
        MB.set_current_state(np.copy(init_rand_state))
        #print 'random initial state',state
        #print 'episode MB', episode

        # keep playing until final state is reached
        while not (MB.current_state[0] == win_state[0] and MB.current_state[1] == win_state[1]):
            step_counter += 1
            #print 'current state',state

            if np.random.rand() < epsilon:
                MB.set_action(int(np.floor(np.random.rand() * 4)))
                #print 'picked random action'
            else:
                MB.set_action(int(MB.Q[linearize(MB.current_state, cols)].index(max(MB.Q[linearize(MB.current_state, cols)]))))
                #print 'picked best action'

            #print 'action',action

            # using action to move to next state
            MB.set_next_state(get_next_state(MB.action,MB.current_state))

            temp = MB.get_current_state()
            print 'cur',temp
            temp2 = MB.get_next_state()
            print 'nex',temp2

            #print 'next_state',next_state
            MB.set_reward(get_reward(MB.next_state,MB.current_state))
            print 'MB cur',MB.get_current_state()
            print 'MB nex',MB.get_next_state()
            print
            if MB.reward == -10:
                print 'get_next_state output',get_next_state(MB.action,MB.current_state)
                print 'action',MB.action
                print 'current state before function ',temp
                print 'next state before function ',temp2
                print 'current state after function ', MB.current_state
                print 'next state after function ',MB.next_state
                raw_input()
            #print 'reward',reward

            # get linear indexes
            state_lin = linearize(MB.current_state, cols)
            next_state_lin = linearize(MB.next_state, cols)

            # Update Reward function, Transition Probabilities and Q Values
            sum_trans_max_Q = MB.update_model(state_lin,MB.action,next_state_lin,alpha,MB.reward)
            MB.update_Q(state_lin,MB.action,gamma,sum_trans_max_Q)
            # move to next state
            MB.set_current_state(MB.next_state)

            # print
            # for q in Q_mb:
            #     print '{0:.3f}\t{1:.3f}\t{2:.3f}\t{3:.3f}'.format(q[0],q[1],q[2],q[3])

            if PLOTS:
                #update figure
                ax.clear()
                ax.plot(MB.current_state[1],MB.current_state[0],'xr',markersize=20,color='red')
                ax.imshow(world, interpolation='nearest')
                ax.set_title('Episode: ' + str(episode))
                ax.get_xaxis().set_ticks(range(cols))
                ax.get_yaxis().set_ticks(range(rows))
                plt.draw()
                plt.pause(0.01)

        counter_mb.append(step_counter)
        ''' MB END '''

        ''' QL '''
        step_counter = 0
        #print 'random initial state',state
        #print 'episode QL', episode
        QL.set_current_state(np.copy(init_rand_state))

        # keep playing until final state is reached
        while not (QL.current_state[0] == win_state[0] and QL.current_state[1] == win_state[1]):
            step_counter += 1
            #print 'current state',state

            if np.random.rand() < epsilon:
                QL.set_action(int(np.floor(np.random.rand() * 4)))
                #print 'picked random action'
            else:
                QL.set_action(int(QL.Q[linearize(QL.current_state, cols)].index(max(QL.Q[linearize(QL.current_state, cols)]))))
                #print 'picked best action'

            #print 'action',action

            # using action to move to next state
            QL.set_next_state(get_next_state(QL.action,QL.current_state))
            #print 'next_state',next_state

            QL.set_reward(get_reward(QL.next_state,QL.current_state))
            #print 'reward',reward

            # get linear indexes
            state_lin = linearize(QL.current_state, cols)
            next_state_lin = linearize(QL.next_state, cols)

            # Update Reward function, Transition Probabilities and Q Values
            TD_error = (QL.reward + (gamma * max(QL.Q[next_state_lin])) - QL.Q[state_lin][QL.action])
            QL.update_Q(state_lin, QL.action, alpha, TD_error)

            # move to next state
            QL.set_current_state(QL.next_state)

            #print
            #for q in Q_ql:
            #   print '{0:.3f}\t{1:.3f}\t{2:.3f}\t{3:.3f}'.format(q[0],q[1],q[2],q[3])

            if PLOTS:
                #update figure
                ax.clear()
                ax.plot(QL.current_state[1],QL.current_state[0],'xr',markersize=20,color='yellow')
                ax.imshow(world, interpolation='nearest')
                ax.set_title('Episode: ' + str(episode))
                ax.get_xaxis().set_ticks(range(cols))
                ax.get_yaxis().set_ticks(range(rows))
                plt.draw()
                plt.pause(0.01)

        counter_ql.append(step_counter)

        ''' QL END '''
    # store counter for nth trial
    steps['mb'].append(counter_mb)
    steps['ql'].append(counter_ql)

# print 'average steps q-learning',sum(counter_ql) / episodes
# print 'average steps model based',sum(counter_mb) / episodes
if PLOTS:
    plt.waitforbuttonpress()

plt.plot(np.arange(episodes),[sum(i)/episodes for i in zip(*steps['mb'])],color='red',label='Model Based')
plt.plot(np.arange(episodes),[sum(i)/episodes for i in zip(*steps['ql'])],color='yellow',label='Q-learning')
plt.plot(np.arange(episodes),np.ones(episodes)*((rows/2) + (cols/2) -1),color='black',label='average min steps')
plt.legend()
plt.show()
