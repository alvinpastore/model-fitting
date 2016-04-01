from __future__ import division
import numpy as np
import matplotlib.pyplot as plt



def linearise(t,c):
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

def get_reward(next_state,state):
    # hitting walls
    if next_state[0] < 0 or next_state[0] > rows - 1:
        reward = -1
        next_state[0] = state[0]
    elif next_state[1] < 0 or next_state[1] > cols - 1:
        reward = -1
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
episodes = 50
trials = 500
epsilon = 0.01
alpha = 0.3
gamma = 0.9

# world
rows = 10
cols = 15
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

    # optimism in the face of uncertainty (initialise qvalues high)
    # Q = np.ones((nStates,nActions)) * 10
    Q_ql = [[10.0 for x1 in xrange(nActions)] for x2 in xrange(nStates)]
    Q_mb = [[10.0 for x1 in xrange(nActions)] for x2 in xrange(nStates)]
    R = [ [0 for x1 in xrange(nActions)] for x2 in xrange(nStates)]
    T = [[[0 for x1 in xrange(nStates)]  for x2 in xrange(nActions)] for x3 in xrange(nStates)]

    for episode in range(episodes):

        ''' MB '''
        step_counter = 0
        state_mb = randomise_initial_state(cols,rows)
        state_ql = np.copy(state_mb)

        #print 'random initial state',state
        #print 'episode MB', episode

        # keep playing until final state is reached
        while not (state_mb[0] == win_state[0] and state_mb[1] == win_state[1]):
            step_counter += 1
            #print 'current state',state

            if np.random.rand() < epsilon:
                action_mb = int(np.floor(np.random.rand() * 4))
                #print 'picked random action'
            else:
                action_mb = int(Q_mb[linearise(state_mb, cols)].index(max(Q_mb[linearise(state_mb, cols)])))
                #print 'picked best action'

            #print 'action',action

            # using action to move to next state
            next_state_mb = get_next_state(action_mb,state_mb)

            #print 'next_state',next_state
            reward_mb = get_reward(next_state_mb,state_mb)

            #print 'reward',reward

            # get linear indexes
            state_mb_lin = linearise(state_mb,cols)
            next_state_mb_lin = linearise(next_state_mb,cols)

            # Update Reward function, Transition Probabilities and Q Values
            R[state_mb_lin][action_mb] += alpha * (reward_mb - R[state_mb_lin][action_mb])
            T[state_mb_lin][action_mb][next_state_mb_lin] += alpha * (1 - T[state_mb_lin][action_mb][next_state_mb_lin])
            sum_transitions_max_Q = 0

            for state_t in xrange(len(T[state_mb_lin][action_mb])):

                T[state_mb_lin][action_mb][state_t] += alpha * (0 - T[state_mb_lin][action_mb][state_t])
                sum_transitions_max_Q += T[state_mb_lin][action_mb][state_t] * max(Q_mb[next_state_mb_lin])

            Q_mb[state_mb_lin][action_mb] = R[state_mb_lin][action_mb] + (gamma * sum_transitions_max_Q)

            # move to next state
            state_mb = next_state_mb

            # print
            # for q in Q_mb:
            #     print '{0:.3f}\t{1:.3f}\t{2:.3f}\t{3:.3f}'.format(q[0],q[1],q[2],q[3])

            if PLOTS:
                #update figure
                ax.clear()
                ax.plot(state_mb[1],state_mb[0],'xr',markersize=20,color='red')
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

        # keep playing until final state is reached
        while not (state_ql[0] == win_state[0] and state_ql[1] == win_state[1]):
            step_counter += 1
            #print 'current state',state

            if np.random.rand() < epsilon:
                action_ql = int(np.floor(np.random.rand() * 4))
                #print 'picked random action'
            else:
                action_ql = int(Q_ql[linearise(state_ql, cols)].index(max(Q_ql[linearise(state_ql, cols)])))
                #print 'picked best action'

            #print 'action',action

            # using action to move to next state
            next_state_ql = get_next_state(action_ql,state_ql)

            #print 'next_state',next_state
            reward_ql = get_reward(next_state_ql,state_ql)

            #print 'reward',reward

            # get linear indexes
            state_ql_lin = linearise(state_ql,cols)
            next_state_ql_lin = linearise(next_state_ql,cols)

            # Update Reward function, Transition Probabilities and Q Values
            TD_error = (reward_ql + (gamma * max(Q_ql[next_state_ql_lin])) - Q_ql[state_ql_lin][action_ql])
            Q_ql[state_ql_lin][action_ql] += + alpha * TD_error

            # move to next state
            state_ql = next_state_ql


            #print
            #for q in Q_ql:
            #   print '{0:.3f}\t{1:.3f}\t{2:.3f}\t{3:.3f}'.format(q[0],q[1],q[2],q[3])

            if PLOTS:
                #update figure
                ax.clear()
                ax.plot(state_ql[1],state_ql[0],'xr',markersize=20,color='yellow')
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
plt.legend()
plt.show()
plt.waitforbuttonpress()


