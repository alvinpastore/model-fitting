from __future__ import division
import time
import numpy as np
import matplotlib.pyplot as plt
from QLearning import QLearning
from Dyna import Dyna
from Sarsa import Sarsa
import RLEnvironment as Env


def plot_figure_update(s, ep, tr, alg, step):
    ax.clear()
    ax.plot(s[1], s[0], 'xr', markersize=30, color='red')
    ax.imshow(world, interpolation='nearest', cmap=plt.get_cmap('Blues'))
    ax.set_title('Trial: ' + str(tr) + ' - Episode: ' + str(ep) + " - " + str(alg) + " - " + str(step))
    ax.get_xaxis().set_ticks(range(cols))
    ax.get_yaxis().set_ticks(range(rows))
    plt.draw()
    plt.pause(0.0001)

start_time = time.time()

PLOTS = False
PLOT_TRAJECTORIES = False

# RL setup
episodes = 50
trials = 300
epsilon = 0.05
alpha = 0.1
gamma = 0.99
k = 15          # number of states to update for dyna
initial_Q = 0   # optimism in the face of uncertainty (initialise qvalues high)
INITIAL_POSITION_RANDOM = True

# world
rows = 5
cols = 6
nStates = rows * cols
world = np.zeros((rows, cols))
world[rows-1, cols-1] = 100
win_state = np.array([rows-1, cols-1])
nActions = 4  # west, south, east, north

steps = {'mb': [], 'ql': [], 'ss': []}

if PLOTS:
    plt.ion()
    plt.close('all')

    fig = plt.figure()
    ax = fig.add_subplot(111)
    plt.show()

for trial in range(trials):
    trial_time = time.time()

    counter_mb = []
    counter_ql = []
    counter_ss = []

    MB = Dyna(nActions, nStates, initial_Q)
    QL = QLearning(nActions, nStates, initial_Q)
    SS = None#Sarsa(nActions, nStates, initial_Q)

    initial_position_log = {}
    for episode in range(episodes):

        if INITIAL_POSITION_RANDOM:
            init_rand_state = Env.randomise_initial_state(cols, rows)
        else:
            init_rand_state = np.array([0, 0])

        if str(init_rand_state) in initial_position_log.keys():
            initial_position_log[str(init_rand_state)] += 1
        else:
            initial_position_log[str(init_rand_state)] = 1

        if MB:
            ''' MB '''
            step_counter = 0
            MB.set_current_state(np.copy(init_rand_state))

            while not Env.is_final_state(MB.current_state, win_state):
                step_counter += 1

                # if episode > 30:
                #     MB.print_Q()
                #     raw_input()

                if np.random.rand() < epsilon:
                    MB.set_action(int(np.floor(np.random.rand() * 4)))
                else:
                    action = MB.pick_random_best_action(MB.Q[Env.linearize(MB.current_state, cols)])
                    MB.set_action(action)

                MB.set_next_state(Env.get_next_state(MB.action, MB.current_state))

                # get_reward moves the agent back if it hits the walls
                # no idea how. tried to replicate but could not
                MB.set_reward(Env.get_reward(MB.next_state, MB.current_state, world))

                state_lin = Env.linearize(MB.current_state, cols)
                next_state_lin = Env.linearize(MB.next_state, cols)

                MB.update_model(state_lin, next_state_lin, MB.action, alpha, MB.reward)
                MB.update_Q(state_lin, MB.action, alpha, gamma, k, nStates, nActions)

                MB.set_current_state(MB.next_state)
                # MB.print_Q()

                if PLOTS:
                    plot_figure_update(MB.current_state, episode, trial, 'model based', step_counter)

            counter_mb.append(step_counter)
            ''' MB END '''

        if QL:
            ''' QL '''
            step_counter = 0
            QL.set_current_state(np.copy(init_rand_state))

            while not Env.is_final_state(QL.current_state, win_state):

                step_counter += 1

                if np.random.rand() < epsilon:
                    QL.set_action(int(np.floor(np.random.rand() * 4)))
                else:
                    action = QL.pick_random_best_action(QL.Q[Env.linearize(QL.current_state, cols)])
                    QL.set_action(action)

                QL.set_next_state(Env.get_next_state(QL.action, QL.current_state))

                QL.set_reward(Env.get_reward(QL.next_state, QL.current_state, world))

                state_lin = Env.linearize(QL.current_state, cols)
                next_state_lin = Env.linearize(QL.next_state, cols)

                QL.update_Q(state_lin, next_state_lin, QL.action, QL.reward, alpha, gamma)

                QL.set_current_state(QL.next_state)

                if PLOTS:
                    plot_figure_update(QL.current_state, episode, trial, 'qlearning', step_counter)

            counter_ql.append(step_counter)

            ''' QL END '''

        if SS:
            ''' SS '''
            step_counter = 0
            SS.set_current_state(np.copy(init_rand_state))

            while not Env.is_final_state(SS.current_state, win_state):

                step_counter += 1

                if np.random.rand() < epsilon:
                    SS.set_action(int(np.floor(np.random.rand() * 4)))
                else:
                    action = SS.pick_random_best_action(SS.Q[Env.linearize(SS.current_state, cols)])
                    SS.set_action(action)

                SS.set_next_state(Env.get_next_state(SS.action, SS.current_state))

                SS.set_reward(Env.get_reward(SS.next_state, SS.current_state, world))

                state_lin = Env.linearize(SS.current_state, cols)
                next_state_lin = Env.linearize(SS.next_state, cols)

                SS.update_Q(state_lin, next_state_lin, SS.action, SS.reward, alpha, gamma)

                SS.set_current_state(SS.next_state)

                if PLOTS:
                    plot_figure_update(SS.current_state, episode, trial, 'sarsa', step_counter)

            counter_ss.append(step_counter)

            ''' SS END '''

        # TODO bug changing the first time the episode is half the episodes and stays the same onwards
        # if episode == episodes/2:
        #    [world, win_state] = Env.change_goal(world)

    # store counter for nth trial
    steps['mb'].append(counter_mb)
    steps['ql'].append(counter_ql)
    steps['ss'].append(counter_ss)
    print 'trial {0} : {1:.3f} sec(s)'.format(trial, time.time() - trial_time)
if PLOTS:
    plt.waitforbuttonpress()

if MB:
    plt.plot(np.arange(episodes), [sum(i)/trials for i in zip(*steps['mb'])], color='red', label='Model Based')
if QL:
    plt.plot(np.arange(episodes), [sum(i)/trials for i in zip(*steps['ql'])], color='green', label='Q-learning')
if SS:
    plt.plot(np.arange(episodes), [sum(i)/trials for i in zip(*steps['ss'])], color='blue', label='Sarsa')


print 'elapsed time', time.time() - start_time
if INITIAL_POSITION_RANDOM:
    avg_steps = ((rows / 2) + (cols / 2) - 1)
else:
    avg_steps = rows - 1 + cols - 1
print 'avg steps to winning state', avg_steps

# for k,v in initial_position_log.iteritems():
#    print str(k) + " " + str(v)

plt.plot(np.arange(episodes), np.ones(episodes)*avg_steps, color='black', label='average min steps')
# plt.ylim([0, 400])
plt.title(" Rand Init: {0} \t Env stochastic penalty: {1} \n"
          " Eps: {2} - k: {3} - Episodes: {4} - Trials: {5} \n"
          " World Size {6}x{7}".
          format(INITIAL_POSITION_RANDOM, Env.STOCHASTIC_PENALTY_PROB, epsilon, k, episodes, trials, rows, cols))

plt.legend()
plt.show()


if PLOT_TRAJECTORIES:
    if MB:
        for trajectory in steps['mb']:
            plt.plot(np.arange(episodes), trajectory, color='red', label='Model Based')
    if QL:
        for trajectory in steps['ql']:
            plt.plot(np.arange(episodes), trajectory, color='green', label='Q-learning')
    if SS:
        for trajectory in steps['ss']:
            plt.plot(np.arange(episodes), trajectory, color='blue', label='Sarsa')

    plt.plot(np.arange(episodes), np.ones(episodes)*((rows/2) + (cols/2) - 1), color='black', label='average min steps')
    plt.show()
