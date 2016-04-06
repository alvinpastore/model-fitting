from __future__ import division
import numpy as np
import matplotlib.pyplot as plt
from QLearning import QLearning
from ModelBased import ModelBased
import RLEnvironment as Env

def plot_figure_update(s):
    #update figure
    ax.clear()
    ax.plot(s[1],s[0],'xr',markersize=20,color='red')
    ax.imshow(world, interpolation='nearest')
    ax.set_title('Episode: ' + str(episode))
    ax.get_xaxis().set_ticks(range(cols))
    ax.get_yaxis().set_ticks(range(rows))
    plt.draw()
    plt.pause(0.01)

PLOTS = True

# RL setup
episodes = 60
trials = 200
epsilon = 0.01 # too low exploration can result in deadlocks (check pick_random_best_action() in ReinforcementLearningModel class)
alpha = 0.5
gamma = 0.6
initial_Q = 0  # optimism in the face of uncertainty (initialise qvalues high)

# world
rows = 3
cols = 4
nStates = rows * cols
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

    QL = None#QLearning(nActions,nStates,initial_Q)
    MB = ModelBased(nActions,nStates,initial_Q)
    #TODO SS sarsa
    pos = {}
    for episode in range(episodes):
        init_rand_state = Env.randomise_initial_state(cols,rows)

        if str(init_rand_state) in pos.keys():
            pos[str(init_rand_state)] += 1
        else:
            pos[str(init_rand_state)] = 1

        if MB:
            ''' MB '''
            step_counter = 0
            MB.set_current_state(np.copy(init_rand_state))

            # keep playing until final state is reached
            while not Env.is_final_state(MB.current_state,win_state):
                step_counter += 1

                # print 'current position',MB.get_current_state()
                # print 'current Q value',MB.Q[Env.linearize(MB.current_state,cols)]

                if np.random.rand() < epsilon:
                    # pick a random action
                    MB.set_action(int(np.floor(np.random.rand() * 4)))
                    #print 'random action'
                else:
                    # pick one of the best actions at random
                    action = MB.pick_random_best_action(MB.Q[Env.linearize(MB.current_state,cols)])
                    MB.set_action(action)

                # if MB.get_action() == 0:
                #     print 'left'
                # elif MB.get_action() == 1:
                #     print 'down'
                # elif MB.get_action() == 2:
                #     print 'right'
                # elif MB.get_action() == 3:
                #     print 'up'

                # using action to move to next state
                MB.set_next_state(Env.get_next_state(MB.action, MB.current_state))

                # get_reward moves the agent back if it hits the walls
                # no idea how. tried to replicate but could not
                MB.set_reward(Env.get_reward(MB.next_state, MB.current_state, world))

                # get linear indexes
                state_lin = Env.linearize(MB.current_state, cols)
                next_state_lin = Env.linearize(MB.next_state, cols)

                # Update Reward function, Transition Probabilities and Q Values
                sum_trans_max_Q = MB.update_model(state_lin, next_state_lin, MB.action, alpha, MB.reward)
                MB.update_Q(state_lin, MB.action, gamma, sum_trans_max_Q)

                #MB.print_model()
                #MB.print_Q()
                # raw_input()

                # move to next state
                MB.set_current_state(MB.next_state)

                if PLOTS:
                    plot_figure_update(MB.current_state)

            counter_mb.append(step_counter)
            ''' MB END '''

        if QL:
            ''' QL '''
            step_counter = 0
            QL.set_current_state(np.copy(init_rand_state))

            # keep playing until final state is reached
            while not Env.is_final_state(QL.current_state,win_state):

                step_counter += 1

                # pick action according to policy
                if np.random.rand() < epsilon:
                    QL.set_action(int(np.floor(np.random.rand() * 4)))
                else:
                    # pick one of the best actions at random
                    action = QL.pick_random_best_action(QL.Q[Env.linearize(QL.current_state,cols)])
                    QL.set_action(action)

                # using action to move to next state
                QL.set_next_state(Env.get_next_state(QL.action,QL.current_state))

                # get reward
                QL.set_reward(Env.get_reward(QL.next_state,QL.current_state,world))

                # get linear indexes
                state_lin = Env.linearize(QL.current_state, cols)
                next_state_lin = Env.linearize(QL.next_state, cols)

                # Update Reward function, Transition Probabilities and Q Values
                QL.update_Q(state_lin, next_state_lin, QL.action, QL.reward, alpha, gamma)

                # QL.print_Q()
                # raw_input()

                # move to next state
                QL.set_current_state(QL.next_state)

                if PLOTS:
                    plot_figure_update(QL.current_state)

            counter_ql.append(step_counter)

            ''' QL END '''
    # store counter for nth trial
    steps['mb'].append(counter_mb)
    steps['ql'].append(counter_ql)

if PLOTS:
    plt.waitforbuttonpress()
if MB:
    plt.plot(np.arange(episodes),[sum(i)/episodes for i in zip(*steps['mb'])],color='red',label='Model Based')
if QL:
    plt.plot(np.arange(episodes),[sum(i)/episodes for i in zip(*steps['ql'])],color='green',label='Q-learning')

plt.plot(np.arange(episodes),np.ones(episodes)*((rows/2) + (cols/2) -1),color='black',label='average min steps')
plt.legend()
plt.show()

print 'avg steps to winning state',((rows/2) + (cols/2) -1)

for k,v in pos.iteritems():
    print str(k) + " " + str(v)